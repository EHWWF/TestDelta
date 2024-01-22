create or replace package audit_pkg as

	/**
	* Starts collecting changes for provided unique Sys Job Id.
	*/
	procedure audit_project_changes(p_sys_job_id in nvarchar2);

	/**
	* Starts DB job and then send email notifications
	* Jos start emediatly after IMPORT job
	*/
	procedure run_project_audit_job;

	/**
	* Starts sys job for monitoring data changes related with PIDT->RDControlling
	* Jos start emediatly after IMPORT job
	*/
	procedure pidt_audit_job(p_html_table out nvarchar2);


	procedure release_all_changes_to_qplan;

	procedure release_prj_to_qplan_finish(p_log_record_id in nvarchar2, p_payload in xmltype);

end;
/
create or replace package body audit_pkg as

	--**************************************************************************
	--* Type=MAIN
	procedure audit_project_changes(p_sys_job_id in nvarchar2)
	as
		v_record_type nvarchar2(11):= 'IPMS';
	begin
		insert into project_audit(project_id, prj_update_user_id, details, change_comment, sys_job_id, create_date, record_type, parent_id)
		with decision_milestones as (
			select
				tm.project_id,
				xmlagg(
							xmlelement("MILESTONE",
												xmlattributes(tm.milestone_code as "CODE", ml.name as "NAME", tm.plan_date as "PLAN", tm.actual_date as "ACHIEVED")
												)
							order by tm.timeline_id, tm.milestone_code
							) xmlval
			from milestone_vw tm
			join milestone ml on (ml.code = tm.milestone_code)
			where tm.timeline_type_code = 'CUR'
			and ml.type_code IN('DEC','DEC-SAMD')-- PROMIS- 604
			and ml.is_active = 1
			group by tm.project_id
		),
		development_milestones as (
			select
				tm.project_id,
				xmlagg(
							xmlelement("MILESTONE",
													xmlattributes(tm.milestone_code as "CODE", ml.name as "NAME", tm.plan_date as "PLAN", tm.actual_date as "ACHIEVED")
													)
							order by tm.timeline_id, tm.milestone_code
							) xmlval
			from milestone_vw tm
			join milestone ml on (ml.code = tm.milestone_code)
			where tm.timeline_type_code = 'CUR'
			and ml.type_code = 'DEV'
			and ml.is_active = 1
			group by tm.project_id
		),
		regional_milestones as (
			select
				tm.project_id,
				xmlagg(
							xmlelement("MILESTONE",
													xmlattributes(tm.milestone_code as "CODE", ml.name as "NAME", tm.plan_date as "PLAN", tm.actual_date as "ACHIEVED")
													)
							order by tm.timeline_id, tm.milestone_code
							) xmlval
			from milestone_vw tm
			join milestone ml on (ml.code = tm.milestone_code)
			where tm.timeline_type_code = 'CUR'
			and ml.type_code = 'REG'
			and ml.is_active = 1
			group by tm.project_id
		),
		new_glimpse as (
			-- creating new glimpse from project current data
			select
				p.id project_id,
				nvl(p.update_user_id, p.create_user_id) cwid,
				xmlelement("PROJECT",
									xmlattributes(
										p.state_code as "STATE",
										nvl(p.priority_code, '') as "PRIORITY",
										nvl(p.phase_code, '') as "PHASE",
										decode(p.is_active,1,'ACTIVE','INACTIVE') as "IS_ACTIVE"
									),
									xmlelement("DECISIONS", (select xmlval from decision_milestones where project_id = p.id)),
									xmlelement("DEVELOPMENT", (select xmlval from development_milestones where project_id = p.id)),
									xmlelement("REGIONAL", (select xmlval from regional_milestones where project_id = p.id))
				) details
			from project p
		)
		select
			newg.project_id,
			newg.cwid,
			newg.details,
			trim(
				case when oldg.create_date is null then
					case when trunc(sysdate) - trunc(p.create_date) < 2 then 'Project created. ' else 'Started monitoring project data changes. ' end
				else
					case when nvl(extractvalue(newg.details, '/PROJECT/@STATE'), '-') = nvl(extractvalue(oldg.details, '/PROJECT/@STATE'), '-') then '' else 'Status changed. ' end ||
					case when nvl(extractvalue(newg.details, '/PROJECT/@PRIORITY'), '-') = nvl(extractvalue(oldg.details, '/PROJECT/@PRIORITY'), '-') then '' else 'Priority changed. ' end ||
					case when nvl(extractvalue(newg.details, '/PROJECT/@PHASE'), '-') = nvl(extractvalue(oldg.details, '/PROJECT/@PHASE'), '-') then '' else 'Phase changed. ' end ||
					case when nvl(extractvalue(newg.details, '/PROJECT/@IS_ACTIVE'), '-') = nvl(extractvalue(oldg.details, '/PROJECT/@IS_ACTIVE'), '-') then '' else 'Active/Inactive changed. ' end ||
					case when extract(xmldiff(xmltype(extract(newg.details, '/PROJECT/DECISIONS').getstringval()), xmltype(extract(oldg.details, '/PROJECT/DECISIONS').getstringval())), '/*/*') is null then '' else 'Decision Milestones changed. ' end ||
					case when extract(xmldiff(xmltype(extract(newg.details, '/PROJECT/DEVELOPMENT').getstringval()), xmltype(extract(oldg.details, '/PROJECT/DEVELOPMENT').getstringval())), '/*/*') is null then '' else 'Development Milestones changed. ' end ||
					case --Regional, added later on top, thus, checking if null
							when extract(oldg.details, '/PROJECT/REGIONAL').getstringval() is null then 'Regional Milestones monitoring started. '
							when extract(xmldiff(xmltype(extract(newg.details, '/PROJECT/REGIONAL').getstringval()), xmltype(nvl(extract(oldg.details, '/PROJECT/REGIONAL').getstringval(),'<REGIONAL></REGIONAL>'))), '/*/*') is null then ''
							else 'Regional Milestones changed. '
					end
				end) change_comment,
			p_sys_job_id,
			sysdate create_date,
			v_record_type record_type,
			oldg.id parent_id
		from new_glimpse newg
		join project p on (p.id = newg.project_id)
		left join project_audit oldg on (oldg.project_id = newg.project_id and oldg.record_type = v_record_type)
		where oldg.create_date is null
		or oldg.create_date = (select max(create_date) from project_audit where project_id = newg.project_id and record_type = v_record_type)
		and extract(xmldiff(oldg.details, newg.details), '/*/*') is not null
		--and newg.project_id = '29-12' --TODO: just for testing
		;

	exception when others then
		notice_pkg.catch('error', 'Auditing project changes failed->audit_project_changes!');
	end;

	--**************************************************************************
	--*
	procedure run_project_audit_job
	as
		v_sys_job_id number;
	begin
		select message_id_seq.nextval into v_sys_job_id from dual;

		audit_pkg.audit_project_changes(v_sys_job_id);
		notify_pkg.collected_changes(v_sys_job_id);

	end;

	--**************************************************************************
	--*
	procedure release_all_changes_to_qplan
	as
		v_record_id nvarchar2(20);
		v_sys_job_id number;
		v_callback varchar2(200);
	begin
		select message_id_seq.nextval into v_sys_job_id from dual;
		for r in (
			with
				prj as (
					select
						id,
						nvl(update_user_id, create_user_id) cwid,
						qplan_release_date,
						nvl(update_date, create_date) as master_data_change_date,
						(select max(nvl(update_date, create_date)) from timeline where project_id = p.id) as timeline_change_date,
						(select max(nvl(update_date, create_date)) from costs_probability where project_id = p.id) as project_ptr_change_date,
						(select max(nvl(update_date, create_date)) from costs_probability where project_id is null) as default_ptr_change_date
					from project p
					where is_syncing=0
						and code is not null
						and area_code is not null
						and (area_code !='D1' --PROMIS-691
                        or area_code !='SAMD') --PROMIS 604
						--and area_code in ('PRE-POT','D2-PRJ')
						and program_id != 'RBIN' --skip deleted projects
				),
				prj_audit_log as (
					select
						project_id,
						pa.details,
						pa.create_date as event_date,
						row_number() over(partition by pa.project_id order by pa.create_date desc) as rowno
					from project_audit pa
					where pa.record_type='FPS'
				)
			select
				prj.*, prja.event_date, prja.details as last_glimpse,
				nvl2(prj.qplan_release_date, 'update', 'creation') as operation
			from prj
				left join prj_audit_log prja on prja.project_id = prj.id and prja.rowno=1
			where 1 = 1
			/*
			 * Disable checking for required data. QuickPlan will report back if something is missing.
			 * That way QuickPlan can evolve without the need to change ProMIS

				and (
					qplan_release_date is null
					and
					not exists (select * from qplan_master_data_vw md where md.project_id=prj.id and element_is_blocking = 1)

					or
					qplan_release_date is not null
				)
			*/
				and (
					prja.event_date is null

					or
					prja.event_date < prj.master_data_change_date
					or
					prja.event_date < prj.timeline_change_date
					or
					prja.event_date < prj.project_ptr_change_date
					or
					prja.event_date < prj.default_ptr_change_date
				)
				and (
					prja.details is null
					or
					xmldiff(sys_xmlgen(prja.details.extract('/*/*')), sys_xmlgen(qplan_pkg.xml(prj.id).extract('/*/*'))).existsNode('/*/*') = 1
				)
		)
		loop

			insert
			into project_audit
				(project_id, details, change_comment, sys_job_id, record_type, prj_update_user_id, create_date)
			values
				(r.id, qplan_pkg.xml(r.id), 'Requested Project '||r.operation, v_sys_job_id, 'FPS', r.cwid, sysdate)
			returning id into v_record_id;

			qplan_pkg.release(r.id, r.last_glimpse, get_text('audit_pkg.release_prj_to_qplan_finish(''%1'', :1);', varchar2_table_typ(v_record_id)));

		end loop;

	end;

	--**************************************************************************
	--*
	procedure release_prj_to_qplan_finish(p_log_record_id in nvarchar2, p_payload in xmltype) as
		v_msgid nvarchar2(20);
		v_log_msg clob;
		v_severity nvarchar2(20);
	begin

		if message_pkg.is_complete(p_payload) = 1
		then
			v_log_msg := 'Response: OK';
			v_severity := 'INFO';
		elsif message_pkg.is_error(p_payload) = 1
		then
			v_log_msg := 'Response: Error';
			v_log_msg := v_log_msg || ' ' || p_payload.extract('//*:error/*:code/text()', message_pkg.xmlns_ipms).getStringVal();
			v_log_msg := v_log_msg || ' ' || p_payload.extract('//*:error/*:description/text()',  message_pkg.xmlns_ipms).getStringVal();
			v_severity := 'ERROR';
		else
			return;
		end if;


		update project_audit
		set change_comment = change_comment || '. '|| v_log_msg, severity_code = v_severity
		where id = p_log_record_id;

	end;

	--**************************************************************************
	--*
	procedure pidt_audit_job(p_html_table out nvarchar2) as
		v_iii pls_integer:=0;
	begin

		/* find differences from the last time and create HTML table*/

		for rr in (
			select
					'<tr><td>'||nvl(code,id)||'</td><td>'||name||'</td><td>'||area_code||'</td><td>'||proposed_sbe||'</td><td>' main_part,
					case when state_code in ('ELSE') and pap_state_code in ('Completed','Completed') then 'Project Resumed on '||prj_update_date||'. ' end ||
					case when state_code in ('Completed') and pap_state_code in ('ELSE','Terminated') then 'Project Completed on '||pap_finishing_date||'. ' end ||
					case when state_code in ('Terminated') and pap_state_code in ('ELSE','Completed') then 'Project Terminated on '||prj_termination_date||'. ' end ||
					case when pap_pidt_release_date is null and prj_pidt_release_date is not null then 'Project released to PIDT on '||prj_pidt_release_date||'. ' end as desc_part
			--into p_html_table
			from
			(
				select
					prj.id,
					prj.code,
					prj.name,
					prj.area_code,
					--ta.name therapeutic_area_name,
					--nvl2(sbe.name, 'SBE proposal: ' || sbe.name, '') proposed_sbe,
					sbe.name proposed_sbe, --just name is needed, the column already states what is inside ;)
                    to_char(prj.update_date,'yyyy-mm-dd') prj_update_date,
					decode(prj.state_code,'5','Terminated','6','Completed','ELSE') state_code,
					to_char(prj.pidt_release_date,'yyyy-mm-dd') prj_pidt_release_date,
					pap.create_date pap_create_date,
					pap.state_code pap_state_code,
					nvl(to_char(pap.finishing_date, 'yyyy-mm-dd'),'-date was not provided-') pap_finishing_date,
					nvl(to_char(prj.termination_date, 'yyyy-mm-dd'),'-date was not provided-') prj_termination_date,
					pap.pidt_release_date pap_pidt_release_date

				from project prj
				--left outer join therapeutic_area ta on (prj.ta_code=ta.code)
				left join project_audit_pidt pap on (prj.id=pap.project_id)
				left join strategic_business_entity sbe on sbe.code = nvl(prj.sbe_code,prj.proposed_sbe_code)--NVL: CUC-416
				where prj.state_code is not null
				and prj.area_code in ('PRE-POT','POST-POT','D2-PRJ', 'SAMD') --PROMIS 604
				and prj.id in (select project_id from
					(
						with project_audit_pidt_old as
						(select
							project_id,
							state_code,
							finishing_date,
							pidt_release_date
						from
							(
								select
									id project_id,
									decode(state_code,'5','Terminated','ELSE') state_code,
									termination_date finishing_date,
									pidt_release_date
								from project
								where state_code is not null
								and area_code in ('PRE-POT','POST-POT','D2-PRJ', 'SAMD') --PROMIS 604
								and state_code not in ('6')

								union all

								select
									prj.id project_id,
									'Completed' state_code,
									timeline.termination_date finishing_date,
									prj.pidt_release_date
								from project prj
								left outer join (
											select
												project_id,
												nvl(nvl(nvl(actual_start,actual_finish), plan_start),plan_finish) termination_date
											from timeline_activity
											where timeline_type_code = 'CUR'
											and milestone_code ='Compl'
											) timeline on (prj.id=timeline.project_id)
								where prj.state_code='6'
								and area_code in ('PRE-POT','POST-POT','D2-PRJ', 'SAMD')--PROMIS 604
							)
						),project_audit_pidt_new as
						(
						select
							project_id,
							to_char(state_code) state_code,
							finishing_date,
							pidt_release_date
						from project_audit_pidt
						)

						(
							select * from project_audit_pidt_old
							minus
							select * from project_audit_pidt_new
						)
						union all
						(
							select * from project_audit_pidt_new
							minus
							select * from project_audit_pidt_old
						)
					)
				)
			)
			)
		loop
			if rr.desc_part is not null then
			/*
			* else -> Means that project is newly created and description is missing
			* (easier to implement this here with if-then then using having count in the select statment
			*/
				v_iii := v_iii+1;
				p_html_table:=p_html_table||rr.main_part||rr.desc_part||'</td></tr>';
			end if;
		end loop;



		/* purge table */
		delete from project_audit_pidt;



		/* create new GLIMPSE */
		insert into project_audit_pidt(project_id,state_code,finishing_date,pidt_release_date)
		select
			id project_id,
			decode(state_code,'5','Terminated','ELSE') state_code,
			termination_date finishing_date,
			pidt_release_date
		from project
		where state_code is not null
		and state_code not in ('6')
		and area_code in ('PRE-POT','POST-POT','D2-PRJ', 'SAMD') --PROMIS 604

		union all

		select
			prj.id project_id,
			'Completed' state_code,
			timeline.termination_date finishing_date,
			prj.pidt_release_date
		from project prj
		left outer join (
					select
						project_id,
						nvl(nvl(nvl(actual_start,actual_finish), plan_start),plan_finish) termination_date
					from timeline_activity
					where timeline_type_code = 'CUR'
					and milestone_code ='Compl'
					) timeline on (prj.id=timeline.project_id)
		where prj.state_code='6'
		and prj.area_code in ('PRE-POT','POST-POT','D2-PRJ', 'SAMD'); --PROMIS 604

	exception
		when others then
			notice_pkg.catch('audit_pkg.pidt_audit_job', 'Auditing project changes failed->pidt_audit_job!');
			p_html_table:='<tr><td>Error while creating contend for email notification</td></tr><tr><td>'||sqlerrm||'</td></tr>';
	end;

end;
/