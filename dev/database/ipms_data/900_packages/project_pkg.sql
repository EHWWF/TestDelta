create or replace package project_pkg as
--pragma serially_reusable;
	/**
	 * Sends project into external sys.
	 * Requires unlocked instance.
	 * Throws no_data_found exception if requirements unmatched.
	 * Asynchronous.
	 * Sends create/project (if sync_date is null) or update/project message.
	 * Locks instance.
	 */
	procedure send(p_id in nvarchar2, p_callback in varchar2 default null);

	/**
	 * Updates project with response from external sys.
	 * Callback.
	 * Unlocks instance.
	 * Updates timelines, if any included in the payload.
	 */
	procedure send_finish(p_id in nvarchar2, p_payload in xmltype);
	--For having dedicated the same procedure call but with the falg that TOP must be copied from predecessor: PROMIS-533
	procedure send_finish_top(p_id in nvarchar2, p_payload in xmltype);

	/**
	 * Relocates project.
	 * Resets lead flag.
	 * Requires unlocked instance.
	 * Throws no_data_found exception if requirements unmatched.
	 * Asynchronous.
	 * Sends move/project message.
	 * Locks instance.
	 */
	procedure move(p_id in nvarchar2, p_program_id in nvarchar2, p_callback in varchar2 default null);

	/**
	 * Completes project relocation.
	 * Callback.
	 * Unlocks instance.
	 */
	procedure move_finish(p_id in nvarchar2, p_payload in xmltype);

	/**
	 * Requests project from external sys.
	 * Requires unlocked instance.
	 * Throws no_data_found exception if requirements unmatched.
	 * Asynchronous.
	 * Sends read/project message.
	 * Locks instance.
	 */
	procedure receive(p_id in nvarchar2, p_with_plan in number default 0, p_callback in varchar2 default null);

	/**
	 * Updates project with response from external sys.
	 * Callback.
	 * Unlocks instance.
	 * Updates timelines, if any included in the payload.
	 */
	procedure receive_finish(p_id in nvarchar2, p_payload in xmltype, p_copy_top in varchar2 default null);

	/**
	 * Initiates project id assignment process.
	 * Requires unlocked instance.
	 * Throws no_data_found exception if requirements unmatched.
	 * Asynchronous.
	 * Sends execute/identify message.
	 * Locks instance.
	 */
	procedure identify(p_id in nvarchar2);

	/**
	 * Updates project with response from external sys.
	 * Callback.
	 * Unlocks instance.
	 * Updates timelines, if any included in the payload.
	 */
	procedure identify_bpm_finish(p_id in nvarchar2, p_payload in xmltype);

	/**
	 * Sets project as lead.
	 * Resets previous lead within program.
	 */
	procedure lead(p_id in nvarchar2);

	/**
	 * Deletes project from external sys.
	 * Requires unlocked instance without current timeline and costs.
	 * Throws no_data_found exception if requirements unmatched.
	 * Asynchronous.
	 * Sends delete/project message.
	 */
	procedure delete(p_id in nvarchar2, p_callback in varchar2 default null);

	/**
	 * Discards running activities for the project.
	 * Unlocks instance.
	 * Discards timelines.
	 * Closes related messages.
	 */
	procedure unlock(p_id in nvarchar2);

	/**
	 * Returns xml representation of the project.
	 */
	function xml(p_id in nvarchar2, p_full in number default 1) return xmltype;

	/**
	 * Updates project with data from xml.
	 * Updates timelines, if any presented in xml.
	 */
	procedure save(p_payload in xmltype);

	/**
	 * Returns summary of project.
	 */
	function get_summary(p_id in nvarchar2) return nvarchar2;

	/**
	 * Returns subject of project.
	 */
	function get_subject(p_id in nvarchar2) return nvarchar2;

	/**
	 * Updates project data according to specified rules.
	 * Throws no_data_found exception if current project phase can not be determined.
	 * Throws too_many_rows exception if current project phase can not be determined.
	 */
	procedure adjust(p_id in nvarchar2);

	/**
	 * Calculates current project phase.
	 */
	function get_current_phase(p_id in nvarchar2) return nvarchar2;

	/**
	 * Release Development project to PIDT. Only projects that have <<prj.pidt_release_date is not null>>
	 * are released to PIDT
	 */
	procedure release_2pidt(p_id in nvarchar2);

	--**************************************************************************
	--* Procedure exposed for QPLAN_PKG package
	--*
	procedure send_message
	(
		p_id in nvarchar2,
		p_payload in xmltype,
		p_callback varchar2,
		p_is_syncing number default 0
	)
	;

end;
/
create or replace package body project_pkg
as
--pragma serially_reusable;
	/*************************************************************************/
	function get_summary(p_id in nvarchar2) return nvarchar2 as
		v_info nvarchar2(100);
	begin
		select 'Project['||id||','||nvl(code,'-')||'].'
		into v_info
		from project
		where id=p_id;

		return v_info;

	exception when no_data_found then
		return 'Project ERROR['||nvl(p_id,'-')||'].';
	end;

	/*************************************************************************/
	function get_subject(p_id in nvarchar2) return nvarchar2 as
	begin
		return 'project:'||p_id;
	end;

	/*************************************************************************/
	procedure send_message
	(
		p_id in nvarchar2,
		p_payload in xmltype,
		p_callback varchar2,
		p_is_syncing number default 0
	)
	as
		msgid nvarchar2(20);
		subject nvarchar2(50);
		v_code nvarchar2(50);
		v_area nvarchar2(50);
	begin
		/* check status */
		select get_subject(id),decode(code,null,null,':'||code),decode(area_code,null,null,':'||area_code)
		into subject,v_code,v_area
		from project
		where id=p_id
		and is_syncing=nvl(p_is_syncing,is_syncing);

		/* send request */
		msgid := message_pkg.send(substr(subject||v_code||v_area,1,50), p_payload, p_callback);

		/* mark as in sync */
		update project set is_syncing=1, sync_id=msgid where id=p_id;

	end;

	/*************************************************************************/
	procedure unlock(p_id in nvarchar2) as
	begin
		update project set is_syncing=0 where id=p_id and is_syncing<>0;
	end;

	/*************************************************************************/
	procedure lead(p_id in nvarchar2) as
		prj project%rowtype;
	begin
		/* get project */
		select * into prj from project where id=p_id;

		/* drop old lead */
		update project set is_lead=0 where program_id=prj.program_id;

		/* set new lead */
		update project set is_lead=1 where id=prj.id;
	end;

	/*************************************************************************/
	procedure send(p_id in nvarchar2, p_callback in varchar2 default null)
	as
		payload xmltype;
		v_sync_date project.sync_date%type;
		v_predecessor_project_id project.predecessor_project_id%type;
		v_procedure varchar2(99);
	begin
		-- setup either create or update request
		select
			appendchildxml(
				message_pkg.xml(nvl2(sync_date,'<update','<create')||' '||message_pkg.xmlns_ipms_soa||' />'),
				'/*', xml(p_id), message_pkg.xmlns_ipms_soa
			) as payload,
			sync_date,
			predecessor_project_id
		into payload, v_sync_date, v_predecessor_project_id
		from project
		where id=p_id;

		if v_sync_date is null and v_predecessor_project_id is not null then
			v_procedure := 'send_finish_top';
		else
			v_procedure := 'send_finish';
		end if;

		--send request
		send_message(p_id, payload,
			get_text('begin project_pkg.'||v_procedure||'(''%1'',:1);%2 end;', varchar2_table_typ(p_id, p_callback)));



		notice_pkg.debug(get_subject(p_id), get_summary(p_id)||' send.');
		log_pkg.log(get_subject(p_id), get_summary(p_id), 'Send.');
	end;

	/*************************************************************************/
	procedure delete(p_id in nvarchar2, p_callback in varchar2 default null) as
		payload xmltype;
	begin
		/* setup request */
		select
			appendchildxml(
				message_pkg.xml('<delete '||message_pkg.xmlns_ipms_soa||'/>'),
				'/*',
				xml(p_id,0),message_pkg.xmlns_ipms_soa
			) as payload
		into payload
		from project
		where id=p_id;

		/* send request */
		send_message(p_id, payload, p_callback);

		notice_pkg.debug(get_subject(p_id), get_summary(p_id)||' delete.');
		log_pkg.log(get_subject(p_id), get_summary(p_id), 'Delete.');
	end;

	/*************************************************************************/
	procedure move
	(
		p_id in nvarchar2,
		p_program_id in nvarchar2,
		p_callback in varchar2 default null
	)
	as
		payload xmltype;
		v_old_program_id nvarchar2(4000);
	begin
		/* get old program id */
        select program_id into v_old_program_id from project where id = p_id;

		/* remove team member assignments */
		delete from team_member_project where project_id=p_id;

		/* update data */
		update project set program_id=p_program_id, is_lead=0
		where id=p_id;

		/* setup message */
		select
			appendchildxml(
				message_pkg.xml('<move '||message_pkg.xmlns_ipms_soa||'/>'),
				'/*',
				xml(p_id,0),message_pkg.xmlns_ipms_soa
			) as payload
		into payload
		from project
		where id=p_id;

		/* send request */
		send_message
		(
			p_id,
			payload,
			get_text('begin project_pkg.move_finish(''%1'',:1);%2 end;', varchar2_table_typ(p_id, p_callback)),
			null --means: do not check is_sync
		);

		notice_pkg.debug(get_subject(p_id), get_summary(p_id)||' move.');
		log_pkg.log(get_subject(p_id), get_summary(p_id), 'Move.');
	end;

	/*************************************************************************/
	procedure move_finish(p_id in nvarchar2, p_payload in xmltype) as
	begin
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		/* stop sync */
		update project set is_syncing=0,sync_date=sysdate where id=p_id;

		notice_pkg.information(get_subject(p_id), get_summary(p_id)||' moved.');
	end;

	/*************************************************************************/
	procedure receive(p_id in nvarchar2, p_with_plan in number default 0, p_callback in varchar2 default null) as
		payload xmltype;
		tlid timeline.id%type;
		tlid2 timeline.id%type;
	begin
		/* setup the request */
		select
			message_pkg.xml(
				'<read '||message_pkg.xmlns_ipms_soa||'>'||
					xml(prj.id, 0)||
				'</read>'
			) as payload,
			tl.id, tl2.id
		into payload, tlid, tlid2
		from project prj
		left join timeline tl on tl.project_id=prj.id and tl.type_code='RAW' and p_with_plan=1
		left join timeline tl2 on tl2.project_id=prj.id and tl2.type_code='CUR' and p_with_plan=1
		where prj.id=p_id;

		/* send request */
		if tlid is null then
			send_message(p_id, payload, get_text('begin project_pkg.receive_finish(''%1'',:1);%2 end;',
				varchar2_table_typ(p_id, p_callback)));
		elsif tlid is not null and tlid2 is not null then
			send_message(p_id, payload, get_text('begin project_pkg.receive_finish(''%1'',:1);timeline_pkg.receive(''%2'',%3); timeline_pkg.receive(''%4'',%3); end;',
				varchar2_table_typ(p_id, tlid, get_quoted(p_callback, 1),tlid2)));
		else
			send_message(p_id, payload, get_text('begin project_pkg.receive_finish(''%1'',:1);timeline_pkg.receive(''%2'',%3); end;',
				varchar2_table_typ(p_id, tlid, get_quoted(p_callback, 1))));
		end if;

		notice_pkg.debug(get_subject(p_id), get_summary(p_id)||' receive.');
	end;

	/*************************************************************************/
	procedure identify_bpm_finish(p_id in nvarchar2, p_payload in xmltype) as
	begin
		/* validate response */
		if message_pkg.is_reject(p_payload)=1 then
			/* stop sync */
			update project set is_syncing=0 where id=p_id;

			notice_pkg.warning(get_subject(p_id), get_summary(p_id)||' identify rejected.');
		elsif message_pkg.is_complete(p_payload)=1 then
			/* stop sync */
			update project set is_syncing=0 where id=p_id;

			/* update project with additional info */
			--send(p_id); --algis:2015-01-21: commenting Out this line added based on: CUC-249.
			--Dont see any reason to call UpdateProject since it is already done inside IdentifyBPM

			/* update with data from soa */
			save(p_payload);

			notice_pkg.information(get_subject(p_id), get_summary(p_id)||' identified.');
		end if;
	end;

	/*************************************************************************/
	procedure send_finish(p_id in nvarchar2, p_payload in xmltype) as
	begin
		receive_finish(p_id, p_payload);
	end;

	/*************************************************************************/
	procedure send_finish_top(p_id in nvarchar2, p_payload in xmltype) as
	begin
		receive_finish(p_id, p_payload, 'add_top');
	end;

	/*************************************************************************/
	procedure save(p_payload in xmltype) as
	begin
		/* save data */
		merge into project prj
		using (
			select
				xt.*
			from
				xmltable(
					xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
					'//project' passing p_payload
					columns
						id path '/project/@id',
						program_id path '/project/@programId',
						code path '/project/code',
						name path '/project/name'
				) xt
		) xs
		on (prj.id=xs.id)
		when matched then
			update set
				prj.name=utl_i18n.unescape_reference(xs.name),
				prj.code=utl_i18n.unescape_reference(xs.code),
				prj.sync_date=sysdate
		when not matched then
			insert(prj.id,prj.program_id,prj.name,prj.code,prj.sync_date)
			values(xs.id,xs.program_id,utl_i18n.unescape_reference(xs.name),utl_i18n.unescape_reference(xs.code),sysdate);

		/* save timelines */
		timeline_pkg.save(p_payload);
	end;

	/*************************************************************************/
	procedure receive_finish(p_id in nvarchar2, p_payload in xmltype, p_copy_top in varchar2 default null)
	as
		v_where nvarchar2(222) := 'project_pkg.receive_finish';
		v_par nvarchar2(4000) := 'p_id=' || p_id || ';p_copy_top=' || p_copy_top;
		v_msg_out nvarchar2(4000);
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;

		v_program_id project.program_id%type;
		v_predecessor_project_id project.predecessor_project_id%type;
		v_src_id program_top_version.id%type;
	begin
		--validate response
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		log_pkg.steps(null, v_step_start, v_steps_result);
		-- stop sync
		update project set is_syncing=0 where id=p_id
		returning program_id, predecessor_project_id
		into v_program_id, v_predecessor_project_id;

		if p_copy_top is not null and v_predecessor_project_id is not null then
			begin
				select id into v_src_id
				from program_top_version
				where project_id = v_predecessor_project_id
				and version = 'current'; --must be only one

					program_top_pkg.copy_version_to_current(v_src_id, v_program_id);

			exception when others then null; end;
		end if;

		-- update with data from soa
		save(p_payload);

		log_pkg.steps('END.', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

	exception when others then
		log_pkg.steps('ERROR.', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
		notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
		raise;

	end;

/*************************************************************************/
procedure identify(p_id in nvarchar2)
  as
    v_where nvarchar2(222) := 'project_pkg.identify';
    v_par   nvarchar2(4000) :=
    'p_id=' || p_id;
    begin

      update plan_assumption_request
      set sync_date = sysdate, status_code = 'FIN'
      where id = p_id;

      task_pkg.create_aid(p_id);

      -- stop_bpm(p_id); -- Use this line to stop real BPM process

      log_pkg.log(v_where, v_par);

      exception when others then
      notice_pkg.catch(v_where, v_par);
      raise;
    end;

	/*************************************************************************/
	procedure identify_bpm(p_id in nvarchar2, p_callback in varchar2 default null) as
		payload xmltype;
	begin
		/* create request for id */
		select
			appendchildxml(
				message_pkg.xml('<identify '||message_pkg.xmlns_ipms_soa||'/>'),
				'/identify', xml(p_id, 2), message_pkg.xmlns_ipms_soa
			) as payload
		into payload
		from project
		where id=p_id;

		/* send request */
		send_message(p_id, payload,
			get_text('begin project_pkg.identify_bpm_finish(''%1'',:1);%2 end;', varchar2_table_typ(p_id, p_callback)));

		notice_pkg.debug(get_subject(p_id), get_summary(p_id)||' identify.');
	end;

	/*************************************************************************/
	function xml(p_id in nvarchar2, p_full in number default 1) return xmltype as
		payload xmltype;
	begin
		/* generate xml representation */
		select
			xmltype(
				'<project id="'||id||'" programId="'||program_id||'" '||message_pkg.xmlns_ipms||'>'||
					decode(p_full,0,'',get_element('code',code))||
					decode(p_full,0,'',get_element('name',name))||
									   get_element('areaCode',area_code)||
					--decode(area_code,'D2-PRJ',get_element('templateCode','D2TMPL'),'')|| 
                    decode(area_code,'D2-PRJ',get_element('templateCode','D2TMPL'),'SAMD',get_element('templateCode','SAMD_TMPL'),'')||   -- PROMIS 604
					--templates apply only for D2, later will be probably for all project areas
					decode(p_full,2,'<roles programId="'||program_id||'">'
						||(select listagg('<role userId="'||user_id||'" roleId="'||utl_i18n.escape_reference(role_code)||'"/>','')
						within group(order by id)
						from user_role ur where ur.program_id=prj.program_id)||'</roles>','')||
				'</project>'
			)
		into payload
		from project prj
		where id=p_id;

		return payload;
	end;

	/*************************************************************************/
	procedure adjust(p_id in nvarchar2)
	as
		v_current_phase_code phase.code%type;
		v_phase_estimated_code project.phase_estimated_code%type;
		----
		v_where nvarchar2(222):='project_pkg.adjust';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		v_log_txt nvarchar2(222);
		----
		v_area_code project.area_code%type;
		v_prj_phase_code project.phase_code%type;
		v_count number;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		--check if phase calculation is not blocked by phase_estimated_code value.
		--PROMIS-693
		select phase_estimated_code, area_code, phase_code
		into v_phase_estimated_code, v_area_code, v_prj_phase_code
		from project where id=p_id;
        if v_area_code !='SAMD' then  ---- PROMIS 604
		if v_area_code = 'D2-PRJ' then --PROMIS-531; PCR - D1-PCC Section - Project Phases
			--"Lead Generation" (in case no "D2 Actual" date is available)
			--"Lead Optimization" (in case a "D2 Actual" date is available)
			--Means: simply, if <D2 Actual date exists in CUR> then <change to "Lead Optimization" - if phase is diff>
			if nvl(v_prj_phase_code,'###') = '15' then -- means already set to "Optimization" and do not change
				--15	Lead Optimization
				--14	Lead Generation
				null;
			else
				-- Check CUR Timeline if exists D2 actual dates
				select count(1) into v_count
				from timeline_activity
				where project_id=p_id
				and timeline_type_code='CUR'
				and milestone_code='D2'
				and nvl(actual_finish, actual_start) is not null;

				if v_count > 0 then
					update project prj set prj.phase_code= '15'
					where prj.id=p_id;
					v_log_txt:='Phase adjusted.'||v_count;
				end if;
			end if;
		else
			if v_phase_estimated_code is null then
				v_current_phase_code := get_current_phase(p_id => p_id);
				/* Set project phase only if it is higher than current phase */
				update project prj set prj.phase_code= v_current_phase_code
				where prj.id=p_id
					and (exists (select 1 from phase ph2
						where ph2.code=prj.phase_code and ph2.is_active = 1
							and (ph2.ordering < (select ph3.ordering from phase ph3
								where ph3.is_active=1 and ph3.code=v_current_phase_code)
								or ph2.ordering is null)
						or prj.phase_code is null));

				v_log_txt:='Phase adjusted.';
			else
				v_log_txt:='Phase NOT adjusted because Phase_Estimated_Code is:'||v_phase_estimated_code;
			end if;
		end if;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, get_summary(p_id)||v_log_txt, v_steps_result);
        
        end if; -- PROMIS 604
	exception when others then
		log_pkg.catch(v_where,get_summary(p_id)||v_log_txt,v_steps_result);
		raise;
	end adjust;


	/*************************************************************************/
	function get_current_phase(p_id in nvarchar2) return nvarchar2 as
		v_current_phase_code phase.code%type;
	begin
		/* Calculate current project phase */
		select ph3.code
		into v_current_phase_code
		from phase ph3
		where ph3.is_active=1 and nvl(ph3.ordering,'-1')=(
			select nvl(max(phase_ordering),'-1')
			from (
				select
					ph.*,
					/* find out last completed milestone*/
					max(case when ph.milestones_completed=ph.milestones_total then ph.phase_ordering else null end)
					over(partition by x) as last_completed,
					/* find out first planned milestone*/
					min(case when ph.milestones_planned>0 and milestones_completed<ph.milestones_total then ph.phase_ordering else null end)
					over(partition by x ) as first_planned
				from (
					select
						ml.phase_code,
						ph.ordering as phase_ordering,
						count(ml.milestone_code) as milestones_total,
						sum(nvl2(tla.plan_date,1,0)) as milestones_planned,
						sum(nvl2(tla.actual_date,1,0)) as milestones_completed
					from phase_milestone ml
					join phase ph on ph.code=ml.phase_code and ml.category='CF'
					left join milestone_vw tla on ml.milestone_code=tla.milestone_code and tla.project_id=p_id and tla.timeline_type_code='CUR'
					group by ml.phase_code,ph.ordering
					) ph
				/* fix for oracle bug */
				cross join (select 1 x from dual) fj
			)
			where
				last_completed is null and phase_ordering<first_planned
				or last_completed is not null and phase_ordering=last_completed);

		return v_current_phase_code;

	end get_current_phase;

	/*************************************************************************/
	procedure release_2pidt(p_id in nvarchar2) as
		v_msgid nvarchar2(50);
		v_callback nvarchar2(500):='begin null; end;';
		v_project nvarchar2(500);
		v_project_code nvarchar2(50);
	begin
		update project prj set prj.pidt_release_date=sysdate
		where prj.id=p_id and prj.pidt_release_date is null
		and (select is_pidt from project_area where code=prj.area_code)=1
		returning prj.id||'-'||prj.code||'-'||prj.name, prj.code into v_project, v_project_code;

		/* All email notification part is done on daily basis, after nightly data sanitization */


	end release_2pidt;

end;
/