create or replace package timeline_pkg as
--pragma serially_reusable;
	/**
	 * Sends timeline into external sys.
	 * Requires unlocked instance.
	 * Throws no_data_found exception if requirements unmatched.
	 * Asynchronous.
	 * Sends update/timeline message.
	 * Locks instance.
	 */
	procedure send(p_id in nvarchar2, p_details in xmltype default null, p_callback in varchar2 default null);

	/**
	 * Updates timeline with response from external sys.
	 * Callback.
	 * Unlocks instance.
	 */
	procedure send_finish(p_id in nvarchar2, p_payload in xmltype);

	/**
	 * Requests timeline from external sys.
	 * Requires unlocked instance.
	 * Throws no_data_found exception if requirements unmatched.
	 * Accepts additional callback.
	 * Asynchronous.
	 * Sends read/timeline message.
	 * Locks instance.
	 */
	procedure receive(p_id in nvarchar2, p_callback in varchar2 default null, p_syncing in number default 0);

	/**
	 * Updates timeline with response from external sys.
	 * Callback.
	 * Unlocks instance.
	 */
	procedure receive_finish(p_id in nvarchar2, p_payload in xmltype, do_save in boolean default true);

	/**
	 * Publishes timeline into next version within external sys.
	 * Requires unlocked instance.
	 * Throws no_data_found exception if requirements unmatched.
	 * Accepts publishing comments.
	 * Asynchronous.
	 * Sends execute/publish message.
	 * Locks instance.
	 */
	procedure publish(p_id in nvarchar2, p_comments in nvarchar2 default null, p_baseline_type_id  in nvarchar2 default null, p_callback in varchar2 default null);

	/**
	 * Finishes publishing.
	 * Updates timeline with response from external sys.
	 * Saves publishing comments.
	 * Callback.
	 * Unlocks instance.
	 * Requests published version from external sys via receive() call.
	 */
	procedure publish_finish(p_id in nvarchar2, p_payload in xmltype);

	/**
	 * Updates timeline with data from xml.
	 */
	procedure save(p_payload in xmltype);

	/**
	 * Discards running activities for the timeline.
	 * Unlocks instance.
	 * Closes related messages.
	 */
	procedure unlock(p_id in nvarchar2);

	/**
	 * Returns xml representation of the timeline.
	 */
	function xml(p_id in nvarchar2, p_full in number default 1) return xmltype;

	/**
	 * Returns summary of timeline.
	 */
	function get_summary(p_id in nvarchar2) return nvarchar2;

	/**
	 * Returns subject of timeline.
	 */
	function get_subject(p_id in nvarchar2) return nvarchar2;

	/**
	 * Refresh all unlocked timelines from P6.
	 */
	procedure receive;

	/**
	 * Update D3 decision date in P6.
	 * p_id - timeline Id, e.g.: 905-2155-RAW
	 * p_d3_date format, e.g.: 2014-06-17T08:00:00
	 */
	procedure update_decisionDate(p_id in nvarchar2, p_decisionDateType in nvarchar2, p_decisionDate in nvarchar2);
	procedure update_decisiondate_finish(p_id in nvarchar2, p_payload in xmltype, p_decisiondate in nvarchar2);

	/**
	 * Summarize selected timeline and then do ReadTimeline for updating the table TIMELINE
	 * p_id - timeline Id, e.g.: 905-2155-RAW
	 */
	procedure summarize(p_id in nvarchar2, p_callback in varchar2 default null);
	procedure summarize_finish(p_id in nvarchar2, p_payload in xmltype);
	--Summarize JOB for the Timelines that were not summarized yet or the summarization was dane long long time ago
	procedure summarize_loop(p_pending_loop in number, p_payload in xmltype default null);

	/**
	 * Delete all redundant baselines (as defined in UC-P2-71)
	 */
	procedure delete_redundant_baselines(p_id in nvarchar2);



	--refresh=merge, timeline_wbs table based on tampline_wbs_vw after data was changed at table: timeline
	procedure merge_timeline_wbs(p_timeline_id in nvarchar2 default null);
	procedure merge_timeline_wbs_category(p_timeline_id in nvarchar2 default null);
	procedure merge_timeline_activity(p_timeline_id in nvarchar2 default null);
	procedure merge_timeline_expense(p_timeline_id in nvarchar2 default null);

	procedure refresh_materialized_data
	(
		p_timeline_id in timeline.id%type,
		p_project_id in project.id%type,
		p_payload in xmltype
	)
	;

end;
/
create or replace package body timeline_pkg as
--pragma serially_reusable;
	/*************************************************************************/
	function get_project_id(p_id in nvarchar2) return nvarchar2 as
		v_res timeline.project_id%type;
	begin
		select project_id into v_res from timeline where id = p_id;
		return v_res;
	end get_project_id;

	/*************************************************************************/
	function get_summary(p_id in nvarchar2) return nvarchar2 as
		v_info nvarchar2(100);
	begin
		select 'Timeline['||id||','||nvl(code,'-')||']'
		into v_info
		from timeline
		where id=p_id;

		return v_info;

	exception when no_data_found then
		return 'Timeline['||nvl(p_id,'-')||']';
	end;

	/*************************************************************************/
	function get_subject(p_id in nvarchar2) return nvarchar2 as
	begin
		return 'timeline:'||p_id;
	end;

	/*************************************************************************/
	procedure send_message(p_id in nvarchar2, p_payload in xmltype, p_callback varchar2, p_syncing in number default 0 ) as
		msgid nvarchar2(20);
		subject nvarchar2(50);
	begin
		/* check status */
		select get_subject(tl.id)
		into subject
		from timeline tl
		where tl.id=p_id
		and tl.is_syncing=p_syncing;

		--adding to subject more action info
		if p_callback like 'begin timeline_pkg.publish_finish(%' then
			subject:='publish:'||subject;
		elsif p_callback like 'begin timeline_pkg.receive_finish(%' then
			subject:='read:'||subject;
		elsif p_callback like 'begin timeline_pkg.summarize_finish(%' then
			subject:='summarize:'||subject;
		elsif p_callback like 'begin baseline_pkg.read_baselines_finish(%' then
			subject:='delete:baselines:'||p_id;
		end if;

		/* send request */
		msgid := message_pkg.send(subject, p_payload, p_callback);

		/* mark as in sync */
		update timeline set is_syncing=1, sync_id=msgid where id=p_id and is_syncing<>1;
	end;

	/*************************************************************************/
	procedure unlock(p_id in nvarchar2) as
	begin
		update timeline set is_syncing=0 where id=p_id and is_syncing<>0;
	end;

	/*************************************************************************/
	procedure send(p_id in nvarchar2, p_details in xmltype default null, p_callback in varchar2 default null)
	as
		v_payload xmltype;
		v_where nvarchar2(99):='timeline_pkg.send';
	begin
		/* setup request */
		select
			appendchildxml(
				message_pkg.xml('<update '||message_pkg.xmlns_ipms_soa ||' p6CreateUser="'||configuration_pkg.get_config_value('P6USER')||'" componentName="ReadTimeline"/>'),
				'/*', nvl(p_details,xml(tl.id)), message_pkg.xmlns_ipms_soa
			) as payload
		into v_payload
		from timeline tl
		where tl.id=p_id;

		/* send request */
		send_message(p_id, v_payload,
			get_text('begin timeline_pkg.send_finish(''%1'',:1);%2 end;',
			varchar2_table_typ(p_id, p_callback)));

		notice_pkg.debug(get_subject(p_id), get_summary(p_id)||' send.');
		log_pkg.log(v_where, 'timeline_id='||p_id, 'Send.');
	end;

	/*************************************************************************/
	procedure receive(p_id in nvarchar2, p_callback in varchar2 default null, p_syncing in number default 0)
	as
		v_where nvarchar2(222) := 'timeline_pkg.receive';
		v_par nvarchar2(4000):='p_id='||p_id||';p_syncing='||p_syncing||';p_callback='||p_callback;
		payload xmltype;
		v_is_syncing number(1);
	begin
		/* setup the request */
		select
			message_pkg.xml(
				'<read '||message_pkg.xmlns_ipms_soa||'>'||
					xml(tl.id, 0)||
				'</read>'
			) as payload, tl.is_syncing
		into payload, v_is_syncing
		from timeline tl
		where tl.id=p_id;

		if v_is_syncing = p_syncing then --could happen that another transaction is blocking
		/* send request */
			send_message(p_id, payload,
			get_text('begin timeline_pkg.receive_finish(''%1'',:1);%2 end;', varchar2_table_typ(p_id, p_callback)), p_syncing);

			--notice_pkg.debug(get_subject(p_id), get_summary(p_id)||' receive.');
			log_pkg.slog(v_where, v_par, 'Receive.');
		end if;
	end;

	/*************************************************************************/
	procedure send_finish(p_id in nvarchar2, p_payload in xmltype) as
	begin
		receive_finish(p_id, p_payload, false);
	end;

	/*************************************************************************/
	procedure receive_finish(p_id in nvarchar2, p_payload in xmltype, do_save in boolean default true)
	as
		v_prj_id project.id%type;
		v_type_code timeline.type_code%type;
		v_project_id timeline.project_id%type;
		v_plan_reference_date date;
		v_goal_status nvarchar2(22);
		v_ref_date_type nvarchar2(11);
		v_where nvarchar2(99):='timeline_pkg.receive_finish';
		v_par nvarchar2(4000) := 'p_id='||p_id;
		v_rowcount number:=0;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);
		v_type nvarchar2(99);

	begin
		log_pkg.steps(null, v_step_start, v_steps_result);

		--validate response
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		log_pkg.steps('a',v_step_start,v_steps_result);
		-- stop sync
		update timeline set is_syncing=0
		where id=p_id
		returning project_id,type_code,project_id
		into v_prj_id, v_type_code, v_project_id;

		v_par := v_par||';prj_id='||v_prj_id;

		v_rowcount := sql%rowcount;
		log_pkg.steps('b'||v_rowcount,v_step_start,v_steps_result);

		--update with data from soa
		if do_save then
			save(p_payload);
			log_pkg.steps('c',v_step_start,v_steps_result);
    	end if;		

    	if v_prj_id is not null then
			--Update/calculate generic timeline
			begin
				generic_timelines_pkg.calculate_generic_timeline(v_prj_id);
				select count(1) into v_rowcount
				from generic_timeline
				where project_id=v_prj_id;
				log_pkg.steps('d'||v_rowcount,v_step_start,v_steps_result);
			exception when others then
				--generally <when others> should be not used, but until CALCULATION is not stable ...
				log_pkg.catch(v_where, v_par, v_steps_result || ';error=calculate_generic_timeline');
			end;

			if v_type_code = 'CUR' then --PROMIS-84 -> update goal status
				--check if the GOAL recalculation is set to
				--After each Raw plan publication in the "Goal Tracking" phase, re-calculate...

					--at first check if this TIMELINE=PROJECT has some REF to any GOAL
					for rr in (select *
									from goal
									where project_id=v_project_id
									and plan_reference is not null --study_element_id
									--and study_id is not null
									)
					loop
						goal_pkg.update_ref_date_after_st(--Just calculate, NO Update goes here
							rr.id,
							rr.project_id,
							rr.plan_reference,
							rr.study_id,
							rr.target_date,
							v_plan_reference_date,--in out
							v_goal_status,--in out
							v_ref_date_type--in out
							);

								if configuration_pkg.get_config_value('GOAL_TRACK')='1' then--FULL update
									if v_plan_reference_date is null then
										--means: unset
										v_goal_status:='1';--1=default=null
									end if;

									--If new status 3 but before was 4 or 5 then dont change status
									--PROMISIII-175
									if v_goal_status='3' and rr.status in ('4','5') then null; else
										update goal
										set
											plan_reference_date=v_plan_reference_date,
											status=nvl(decode(is_manual_status,0,v_goal_status,status),'1'),
											ref_date_type=v_ref_date_type
										where id=rr.id
										and (
											nvl(plan_reference_date,sysdate)<>nvl(v_plan_reference_date,sysdate)
											or
											nvl(status,'#')<>nvl(v_goal_status,'#')
											or
											nvl(ref_date_type,'#')<>nvl(v_ref_date_type,'#')
											);
									end if;
									v_type:='Full.';

								else --only date update
									update goal
									set
										plan_reference_date=v_plan_reference_date,
										--status=nvl(v_goal_status,'1'),
										ref_date_type=v_ref_date_type
									where id=rr.id
									and (
											nvl(plan_reference_date,sysdate)<>nvl(v_plan_reference_date,sysdate)
											or
											nvl(ref_date_type,'#')<>nvl(v_ref_date_type,'#')
										);
									v_type:='Semi.';

									--Flag "manual user status" needs to be reset in goal setup phase
									update goal set is_manual_status=0 where id=rr.id;

								end if;

								--log_pkg.log(v_where,'p_id='||p_id||';goal_id='||rr.id||';v_plan_reference_date='||v_plan_reference_date
								--||';v_ref_date_type='||v_ref_date_type||';v_goal_status='||v_goal_status,'Goal updated.'||v_type);
								--just to make sure, set to NULL for the next loop run
								v_plan_reference_date:=null;
								v_ref_date_type:=null;
								v_goal_status:=null;
								v_type:=null;
					end loop;

			end if;
		end if;

		log_pkg.steps('END.', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

	exception when others then
		log_pkg.steps('ERROR.', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
		notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
		raise;
	end;

	/*************************************************************************/
	procedure save(p_payload in xmltype)
	as
		v_timeline_id timeline.id%type;
		v_project_id project.id%type;
		v_where nvarchar2(99):='timeline_pkg.save';
		v_par nvarchar2(4000);
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);

	begin
		log_pkg.steps(null, v_step_start, v_steps_result);
		/* save data */
		merge into timeline tl
		using (
			select
				xt.*,
				to_number(decode(instr(xt.ltci_id,'.',1),0,xt.ltci_id,substr(xt.ltci_id,1,instr(xt.ltci_id,'.',1)-1))) as ltc_version, 
				to_number(decode(instr(xt.ltci_id,'.',1),0,null,substr(xt.ltci_id,instr(xt.ltci_id,'.',1)+1))) as ltc_process_id,
				get_date(start_date_str) as start_date,
				get_date(finish_date_str) as finish_date,
				get_date(last_summarized_date_str) as last_summarized_date,
				get_date(create_date_p6_str) as create_date_p6
			from
				xmltable(
					xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
					'//timeline' passing p_payload
					columns
						details xmltype path '.',
						id path '/timeline/@id',
						project_id path '/timeline/@projectId',
						reference_id path '/timeline/@referenceId',
						code path '/timeline/code',
						name path '/timeline/name',
						type_code path '/timeline/typeCode',
						start_date_str path '/timeline/startDate',
						finish_date_str path '/timeline/finishDate',
						last_summarized_date_str path '/timeline/lastSummarizedDate',
						create_date_p6_str path '/timeline/createDate',
						comments path '/timeline/comments',
						baseline_type_id path '/timeline/baselineTypeObjectId',
						ltci_id path '/timeline/ltcId'
				) xt
		) xs
		on (tl.id=xs.id)
		when matched then
			update set
				tl.code=utl_i18n.unescape_reference(xs.code),
				tl.name=utl_i18n.unescape_reference(xs.name),
				tl.comments=utl_i18n.unescape_reference(xs.comments),
				tl.start_date=xs.start_date,
				tl.finish_date=xs.finish_date,
				tl.sync_date=sysdate,
				tl.details=xs.details,
				tl.reference_id=xs.reference_id,
				tl.last_summarized_date=nvl(xs.last_summarized_date,tl.last_summarized_date),
				tl.baseline_type_id=nvl(xs.baseline_type_id,tl.baseline_type_id),
				tl.ltci_id=xs.ltc_version,
				tl.create_date_p6=xs.create_date_p6,
				tl.ltc_process_id=xs.ltc_process_id
		when not matched then
			insert
				(
					id,
					project_id,
					reference_id,
					code,
					name,
					type_code,
					start_date,
					finish_date,
					sync_date,
					comments,
					details,
					last_summarized_date,
					ltci_id,
					baseline_type_id,
					create_date_p6,
					ltc_process_id
				)
			values
				(
					xs.id,
					xs.project_id,
					xs.reference_id,
					utl_i18n.unescape_reference(xs.code),
					utl_i18n.unescape_reference(xs.name),
					xs.type_code,
					xs.start_date,
					xs.finish_date,
					sysdate,
					utl_i18n.unescape_reference(xs.comments),
					xs.details,
					xs.last_summarized_date,
					xs.ltc_version,
					xs.baseline_type_id,
					xs.create_date_p6,
					xs.ltc_process_id
				)
			--returning id into v_timeline_id
			-- returning is not working for MERGE ;)
			;


		begin
			select
				xt.id, xt.prjid
				into v_timeline_id, v_project_id
			from xmltable 
				(
				xmlnamespaces (default 'http://xmlns.bayer.com/ipms'),
				'//timeline' passing p_payload
				columns
					details xmltype path '.',
					id path '/timeline/@id',
					prjid path '/timeline/@projectId'
				) 
			xt;

			if v_timeline_id is not null then
				refresh_materialized_data(v_timeline_id,v_project_id,p_payload);
			end if;

		exception when others then
			log_pkg.log(v_where, v_par, sqlerrm);
		end;

		log_pkg.steps('END.', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

	exception when others then
		log_pkg.steps('ERROR.', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
		notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
		raise;
	end;

	/*************************************************************************/
	procedure publish
		(
			p_id in nvarchar2,
			p_comments in nvarchar2 default null,
			p_baseline_type_id in nvarchar2 default null,
			p_callback in varchar2 default null
		)
	as
		v_payload xmltype;
		v_where nvarchar2(222):='timeline_pkg.publish';
		v_par nvarchar2(4000):=
			'p_id='||p_id||
			--';p_comments='||p_comments||
			';p_baseline_type_id='||p_baseline_type_id
			--';p_callback='||p_callback
			;
		v_step_start timestamp:=systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:=systimestamp;
		v_msg_out nvarchar2(4000);
		v_rowcount number:=0;
		v_baseline_type_id nvarchar2(22):=p_baseline_type_id;
		v_baseline_old_type_id nvarchar2(22);
		v_baseline_old_target_type_id nvarchar2(22);
		v_baseline_type_name nvarchar2(99);
		v_count number;
		v_project_id nvarchar2(22);
		v_new_ltci_id number;
		--v_old_ltci_id number;
		v_current_ltci_id number;
		v_current_ltc_process_id number;
		v_ltc_process_id number;
		v_type_code nvarchar2(22);

	begin
		log_pkg.steps(null,v_step_start,v_steps_result);
		-- create request
		select
			updatexml(
			appendchildxml(
				message_pkg.xml('<publish '||message_pkg.xmlns_ipms_soa||'/>'),
				'/publish',
				xml(tl.id),
				message_pkg.xmlns_ipms_soa
				),
				'//timeline/comments','<comments '||message_pkg.xmlns_ipms||'><![CDATA['||p_comments||']]></comments>',
				message_pkg.xmlns_ipms
			) as payload,
			baseline_type_id,
			project_id,
			type_code,
			ltci_id,
			ltc_process_id
		into 
			v_payload,
			v_baseline_old_type_id,
			v_project_id,
			v_type_code,
			v_current_ltci_id,
			v_current_ltc_process_id
		from timeline tl
		where tl.id=p_id;

		begin
			select baseline_type_id--,ltci_id
			into v_baseline_old_target_type_id--,v_old_ltci_id
			from timeline
			where id = replace(replace(p_id,'-CUR','-APR'),'-RAW','-CUR');
		exception when others then
			v_baseline_old_target_type_id:=null;
			--v_old_ltci_id:=null;
		end;	

		if v_baseline_type_id is null and p_id like '%-RAW' then
			v_baseline_type_name :='Raw-Current Publication';
		else
			v_baseline_type_name :='Current-Approved Publication';
		end if;

		v_baseline_type_name :=upper(replace(v_baseline_type_name,' '));

		if v_baseline_type_id is null and v_baseline_type_name is not null then
			begin
				select id into v_baseline_type_id
				from baseline_type
				where upper(replace(name,' '))=v_baseline_type_name;

			exception when others then
				v_baseline_type_id:=null;--ToDo !!!
			end;
		end if;

		if v_baseline_type_id is not null then
			select
				insertxmlafter(
					v_payload,
					'//timeline/comments',
					xmltype('<baselineTypeObjectId '||message_pkg.xmlns_ipms||'>'||v_baseline_type_id||'</baselineTypeObjectId>'),
					message_pkg.xmlns_ipms
			)
			into v_payload from dual;

			select
				insertxmlafter(
					v_payload,
					'//timeline/baselineTypeObjectId',
					xmltype('<baselineOldTypeObjectId '||message_pkg.xmlns_ipms||'>'||v_baseline_old_type_id||'</baselineOldTypeObjectId>'),
					message_pkg.xmlns_ipms
			)
			into v_payload from dual;

			select
				insertxmlafter(
					v_payload,
					'//timeline/baselineOldTypeObjectId',
					xmltype('<baselineOldTargetTypeObjectId '||message_pkg.xmlns_ipms||'>'||nvl(v_baseline_old_target_type_id,v_baseline_old_type_id)||'</baselineOldTargetTypeObjectId>'),
					message_pkg.xmlns_ipms
			)
			into v_payload from dual;

			--baseline_type_id is not being stored in the Plpan, so, after ReadTimeline it will not be taken. Thus, it is better to do Update ASAP
			update timeline set baseline_type_id=v_baseline_type_id where id=p_id and nvl(baseline_type_id,'###') <> v_baseline_type_id;
		end if;

		------------------------------------------------------------------------
		log_pkg.steps('a' || v_rowcount, v_step_start, v_steps_result);
		------------------------------------------------------------------------
		--New LTC ID generation must be applied only for RAW, bcause only RAW start new Timeline, else it just copy-paste from the past
		------------------------------------------------------------------------
		if v_type_code='RAW' then
		---Check if LTC data must be submited to ipms_repo at all, means, chcek if that project exists in any LTC processes ESTIMATION
			for tt in (
				select 
					ltcprj.project_id,
					ltcprj.ltc_process_id,
					ltce.update_date as max_ltc_update_date
				from ipms_data.ltc_project ltcprj
				join ipms_data.ltc_estimate ltce on (ltcprj.id=ltce.ltc_project_id)
				where ltcprj.project_id=v_project_id
				order by ltce.update_date desc
			)
			loop
				v_ltc_process_id:=tt.ltc_process_id;
				exit;
			end loop;
	
			if v_ltc_process_id is not null then--means that we have the most recent process id for that project
				if v_current_ltc_process_id is null or nvl(v_current_ltc_process_id,-1)<>v_ltc_process_id then 
					--for sure must be new ID generated because Process ID is diff or never generated before
					select timestamp_to_scn(sysdate) into v_new_ltci_id from dual;
				else
					--check IPMS_REPO if for that concrete proces id and for ltc id data set is diff
					v_count:=ipms_repo.ltc_pkg.get_ltc_diff_count(v_current_ltci_id,v_current_ltc_process_id,v_project_id);
					if v_count>0 then --we have differences
						select timestamp_to_scn(sysdate) into v_new_ltci_id from dual;
					end if;
				end if;
			end if;
	
			if v_new_ltci_id is not null then
				select
					insertxmlafter(
						v_payload,
						'//timeline/baselineOldTargetTypeObjectId',
						--use the same field LTCI_ID for new SCN along with Process Id, because one project could be located in many processes
						xmltype('<ltcId '||message_pkg.xmlns_ipms||'>'||v_new_ltci_id||'.'||v_ltc_process_id||'</ltcId>'),
						message_pkg.xmlns_ipms
				)
				into v_payload from dual;
				
				insert into ipms_repo.promis_task(id,ltc_process_id,project_id,ltc_tag_id) 
				values (v_new_ltci_id,v_ltc_process_id,v_project_id,null);
			end if;
		end if;
		------------------------------------------------------------------------

		--send request to queue
		send_message(p_id, v_payload,
			get_text('begin timeline_pkg.publish_finish(''%1'',:1);%2 end;', varchar2_table_typ(p_id, p_callback)));


		v_msg_out := ';'||v_msg_out ||'v_new_ltci_id='||v_new_ltci_id||';v_ltc_process_id='||v_ltc_process_id;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

	exception when others then
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
		notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
		raise;
	end;

	/*************************************************************************/
	procedure publish_finish(p_id in nvarchar2, p_payload in xmltype) 
	as
		v_where nvarchar2(222):='timeline_pkg.publish_finish';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_prj_id project.id%type;
		v_stage nvarchar2(1000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		v_count number:=-1;
		v_id nvarchar2(100);
	begin
		--validate response
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;
		log_pkg.steps(null,v_step_start,v_steps_result);

		--check stage
		v_stage := message_pkg.get_stage(p_payload);

		if v_stage = 'publish' then

			-- Set baseline type as it is provided only in publishing response
			update timeline set baseline_type_id=extractvalue(p_payload,'//timeline/baselineTypeObjectId', message_pkg.xmlns_ipms) where id=p_payload.extract('//timeline/@id', message_pkg.xmlns_ipms).getstringval();
			log_pkg.steps('a',v_step_start,v_steps_result);

		else
			--stop sync
			update timeline set is_syncing=0 where id=p_id and is_syncing<>0;
			log_pkg.steps('b',v_step_start,v_steps_result);
	
			--read source
			timeline_pkg.receive(p_id);
			log_pkg.steps('c',v_step_start,v_steps_result);
	
			--read target
			v_prj_id := get_project_id(p_id);
			v_id := p_payload.extract('//timeline/@id', message_pkg.xmlns_ipms).getstringval();
			if v_id is not null then
				--create timeline when missing
				select count(1) 
				into v_count
				from timeline where id=v_id;
	
				if v_count = 0 then
					save(p_payload);
				end if;
				timeline_pkg.receive(v_id,case when v_prj_id is not null then 'begin project_pkg.adjust('''||v_prj_id||'''); end;' else null end);
			else
				v_stage:=v_stage||';ERROR=missing-ID.';
			end if;
		end if;

		v_stage:=';count='||v_count||';stage='||v_stage;
		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_stage);

	exception when others then
		log_pkg.CATCH('ERROR', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_stage);
		raise;
	end;

	/*************************************************************************/
	function xml(p_id in nvarchar2, p_full in number default 1) return xmltype as
		payload xmltype;
	begin
		/* create xml for timeline */
		select
			xmltype(
				'<timeline id="'||tl.id||'" programId="'||decode(tl.type_code,'SND',snd.program_id,prj.program_id)||'" projectId="'||decode(tl.type_code,'SND',snd.id,prj.id)||'" referenceId="'||tl.reference_id||'" '||message_pkg.xmlns_ipms||'>'||
					decode(p_full,0,'',get_element('name',tl.name))||
					get_element('typeCode',tl.type_code)||
					decode(p_full,0,'',get_element('startDate',get_char_date(tl.start_date)))||
					decode(p_full,0,'',get_element('finishDate',get_char_date(tl.finish_date)))||
					decode(p_full,0,'',get_element('comments','<![CDATA['||tl.comments||']]>', 0))||
					--decode(p_full,0,'',get_element('baselineTypeObjectId',tl.baseline_type_id))||
				'</timeline>'
			)
		into payload
		from timeline tl
			left join project prj on prj.id=tl.project_id
			left join program_sandbox snd on snd.snd_timeline_id=tl.id and tl.type_code='SND'
		where tl.id=p_id;

		return payload;
	end;

	/*************************************************************************/
	procedure receive as
		v_where nvarchar2(99):='timeline_pkg.receive';
	begin
		log_pkg.log(v_where, 'TODO', 'MONITOR USAGE!!!');--TODO, if not used, then delete this procedure with COM-MIT
		for tl in (select id from timeline where is_syncing=0)
		loop
			receive(tl.id);
			commit;
		end loop;
	end;

	/*************************************************************************/
	procedure update_decisionDate(p_id in nvarchar2, p_decisionDateType in nvarchar2, p_decisionDate in nvarchar2) as
	v_payload xmltype;
	v_milestonetype nvarchar2(10):='D3';
	v_decisionDate nvarchar2(200);
	v_type nvarchar2(100);
	begin
	--From TIMELINE take only Activities that are: D3 and delete all TIME (date) fields
	select
		deleteXML(
			deleteXML(
				deleteXML(
					deleteXML(
							xmltype(
									tl.details.extract('/timeline/activities/activity[milestoneCode="'||v_milestonetype||'"]',
									message_pkg.xmlns_ipms).getstringval()
									),
									'/activity/planStart', message_pkg.xmlns_ipms
								),
							'/activity/planFinish', message_pkg.xmlns_ipms
							),
						'/activity/actualStart', message_pkg.xmlns_ipms
					),
				'/activity/actualFinish', message_pkg.xmlns_ipms
				),
	tl.details.extract('/timeline/activities/activity[milestoneCode="'||v_milestonetype||'"]/type/text()',
	message_pkg.xmlns_ipms).getstringval()

	into v_payload, v_type
		from timeline tl
		where tl.id=p_id
	and existsNode(tl.details, '/timeline/activities/activity[milestoneCode="'||v_milestonetype||'"]', message_pkg.xmlns_ipms)=1;

	--check rules and add accordigly decision date
	v_decisionDate := '<XREPLACEX '||message_pkg.xmlns_ipms||'>'||p_decisionDate||'</XREPLACEX>';
	if v_type like 'Start%' then
		if p_decisionDateType = 'plan' then
			v_decisionDate := replace(v_decisionDate,'XREPLACEX','planStart');
		else
			v_decisionDate := replace(v_decisionDate,'XREPLACEX','actualStart');
		end if;
	else -- Finish
		if p_decisionDateType = 'plan' then
			v_decisionDate := replace(v_decisionDate,'XREPLACEX','planFinish');
		else
			v_decisionDate := replace(v_decisionDate,'XREPLACEX','actualFinish');
		end if;
	end if;

	--preapare the final PAYLOAD for P6 request
	select
		appendchildxml(
			message_pkg.xml('<update '||message_pkg.xmlns_ipms_soa||' componentName="ReadTimeline"/>'),
			'/*',
			appendchildxml(xml(p_id),
				'/*',
				INSERTXMLAFTER(xmltype('<activities '||message_pkg.xmlns_ipms||'>'||v_payload||'</activities>'),
							'/activities/activity/functions',
							xmltype(v_decisionDate)
							,message_pkg.xmlns_ipms
							)
				,message_pkg.xmlns_ipms
				)
			,message_pkg.xmlns_ipms_soa
		) as payload
		into v_payload
		from timeline tl
		where tl.id=p_id;

		/* send request */
		send_message(p_id, v_payload,
		get_text('begin timeline_pkg.update_decisiondate_finish(''%1'',:1,''%2''); end;', varchar2_table_typ(p_id,p_decisionDate)));

		notice_pkg.debug(get_subject(p_id), get_summary(p_id)||' decision date send.');
		log_pkg.log(get_subject(p_id), get_summary(p_id), 'Send.');

	exception when no_data_found then
		notice_pkg.catch('error', 'D3 milestone was not found for '||p_id||' when running - Update Decision Date.');
	end;

	/*************************************************************************/
	procedure update_decisionDate_finish(p_id in nvarchar2, p_payload in xmltype, p_decisionDate in nvarchar2) as
	begin
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		/* stop sync */
		update timeline set is_syncing=0 where id=p_id;

		/* read TIMELINE source from P6 */
		timeline_pkg.receive(p_id);

		update timeline set comments='The following D3 date '||p_decisionDate||' applied during project transition.' where id=p_id;

		notice_pkg.information(get_subject(p_id), get_summary(p_id)||' decision date synchronized.');
	end;

	/*************************************************************************/
	procedure summarize(p_id in nvarchar2, p_callback in varchar2 default null) as
		v_payload xmltype;
		v_is_syncing number(1);
	begin
		/* setup the request */
		select
			message_pkg.xml(
				'<summarize '||message_pkg.xmlns_ipms_soa||' bounded="false">'||
					xml(tl.id, 0)||
				'</summarize>'
			) as payload, tl.is_syncing
		into v_payload, v_is_syncing
		from timeline tl
		where tl.id=p_id;

		if v_is_syncing = 0 then --could happen that another transaction is blocking
		/* send request */
			send_message(p_id, v_payload,
			get_text('begin timeline_pkg.summarize_finish(''%1'',:1);%2 end;', varchar2_table_typ(p_id, p_callback)));

			notice_pkg.debug(get_subject(p_id), get_summary(p_id)||' summarize receive.');
		end if;
	end;

	/*************************************************************************/
	procedure summarize_finish(p_id in nvarchar2, p_payload in xmltype) as
	begin
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		/* stop sync */
		update timeline set is_syncing=0 where id=p_id and is_syncing<>0;

		notice_pkg.information(get_subject(p_id), get_summary(p_id)||' summarized.');

		/* read source */
		timeline_pkg.receive(p_id);

	end;

	/*************************************************************************/
	procedure summarize_loop(p_pending_loop in number, p_payload in xmltype) as
		v_max_loop pls_integer:=500; --it is just in case, if LOOP will have an issue with Existing.
		v_pending_loop number:=nvl(p_pending_loop,1);
	begin
		if p_payload is null or message_pkg.is_complete(p_payload)=1 or message_pkg.is_error(p_payload)=1 then
		 --empty p_payload can be when starting as a JOB
		 if to_number(to_char(SYSDATE,'hh24'))>19 or to_number(to_char(SYSDATE,'hh24'))<6 then --sumarrization could run only during not working hours: 19.00 -> 6.00 (Note. job_pkg runs from 20.00-5.00
			if v_pending_loop<v_max_loop then
				--take the next best candidate and run Summarization
				for rr in (
					select tl.id
					from timeline tl
						left join project prj on prj.id=tl.project_id
						left join program_sandbox snd on snd.snd_timeline_id=tl.id and tl.type_code='SND'
					where tl.is_syncing=0
					and nvl(tl.last_summarized_date,sysdate-999)<sysdate-7
					and nvl(tl.sync_date,sysdate-999)<sysdate-1
					and decode(tl.type_code,'SND',snd.program_id,prj.program_id) is not null
					and tl.reference_id is not null
					order by nvl(tl.sync_date,sysdate-999)
				)
				loop
					dbms_lock.sleep(10);--wait a bit of sec, dont make too big load at SOA
					v_pending_loop:=v_pending_loop+1;
					timeline_pkg.summarize(rr.id,'begin timeline_pkg.summarize_loop('''||v_pending_loop||''',:1); end;');
					exit;
				end loop;
			end if;
		 end if;
		end if;

	exception when others then
		log_pkg.log('timeline_pkg.summarize_loop', 'OTHERS;p_pending_loop='||p_pending_loop, sqlerrm);
	end;

	/*************************************************************************/
	procedure merge_timeline_wbs(p_timeline_id in nvarchar2) as
		v_rowcount number:=0;
		v_count_view number;
		v_count_tab number;
		----
		v_where nvarchar2(222):='timeline_pkg.merge_timeline_wbs';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		v_log_txt nvarchar2(222);
		----
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);--null=BEGIN
		-- Remove things that do not exist anymore
		delete from timeline_wbs dest
		where timeline_id=p_timeline_id
			and not exists(
				select *
				from timeline_wbs_src_vw
				where timeline_id=dest.timeline_id and decode(wbs_id, dest.wbs_id, 1)=1
			);

		v_rowcount := v_rowcount + sql%rowcount;

		-- Update / insert things that differ
		merge into timeline_wbs dest
		using (
			select timeline_id, timeline_type_code, wbs_id, parent_wbs_id, root_wbs_id, study_id, code, name, start_date, finish_date, study_phase, sequence_number, placeholder, project_id, sandbox_id
			from timeline_wbs_src_vw
			where timeline_id=p_timeline_id
			minus
			select timeline_id, timeline_type_code, wbs_id, parent_wbs_id, root_wbs_id, study_id, code, name, start_date, finish_date, study_phase, sequence_number, placeholder, project_id, sandbox_id
			from timeline_wbs
			where timeline_id=p_timeline_id
		) diff on (diff.timeline_id=dest.timeline_id and decode(diff.wbs_id, dest.wbs_id, 1)=1)
		when matched then
			update set
				dest.project_id = diff.project_id,
				dest.sandbox_id = diff.sandbox_id,
				dest.timeline_type_code = diff.timeline_type_code,
				dest.parent_wbs_id = diff.parent_wbs_id,
				dest.root_wbs_id = diff.root_wbs_id,
				dest.study_id = diff.study_id,
				dest.code = diff.code,
				dest.name = diff.name,
				dest.start_date = diff.start_date,
				dest.finish_date = diff.finish_date,
				dest.study_phase = diff.study_phase,
				dest.sequence_number = diff.sequence_number,
				dest.placeholder = diff.placeholder,
				update_date = sysdate
		when not matched then
			insert (project_id, sandbox_id, timeline_id, timeline_type_code, wbs_id, parent_wbs_id, root_wbs_id, study_id,code, name, start_date, finish_date, study_phase, sequence_number, placeholder, create_date)
			values (diff.project_id, diff.sandbox_id, diff.timeline_id, diff.timeline_type_code, diff.wbs_id, diff.parent_wbs_id, diff.root_wbs_id, diff.study_id, diff.code, diff.name, diff.start_date, diff.finish_date, diff.study_phase, diff.sequence_number, diff.placeholder, sysdate);

		v_rowcount := v_rowcount + sql%rowcount;

		-- LOG controlling checks
		if p_timeline_id is null then

			select count(1) into v_count_tab from timeline_wbs;

			select count(1) into v_count_view from timeline_wbs_src_vw;

			log_pkg.steps('a',v_step_start,v_steps_result);
			v_log_txt:=v_log_txt||'count_view='||v_count_view||';count_tab='||v_count_tab;
		end if;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'timeline_id='||p_timeline_id||';rowcount='||v_rowcount||';'||v_log_txt,v_steps_result);

	exception when others then
		log_pkg.catch(v_where,'timeline_id='||p_timeline_id||';rowcount='||v_rowcount||';'||v_log_txt,v_steps_result);
		--raise;
	end;

	/*************************************************************************/
	procedure merge_timeline_wbs_category(p_timeline_id in nvarchar2) as
		v_rowcount number := 0;
		v_count_view number;
		v_count_tab number;
		----
		v_where nvarchar2(222):='timeline_pkg.merge_timeline_wbs_category';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		v_log_txt nvarchar2(222);
		----
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);--null=BEGIN
		-- Remove things that do not exist anymore
		delete from timeline_wbs_category dest
		where timeline_id=p_timeline_id
			and not exists(
				select *
				from timeline_wbs_category_vw
				where timeline_id=dest.timeline_id and decode(wbs_id, dest.wbs_id, 1)=1
			);

		v_rowcount := v_rowcount + sql%rowcount;


		-- Update / insert things that differ
		merge into timeline_wbs_category dest
		using (
			select timeline_id, wbs_id, category_name, category_object_id
			from timeline_wbs_category_vw
			where timeline_id=p_timeline_id
			minus
			select timeline_id, wbs_id, category_name, category_object_id
			from timeline_wbs_category
			where timeline_id=p_timeline_id
		) diff on (diff.timeline_id=dest.timeline_id and decode(diff.wbs_id, dest.wbs_id, 1)=1)
		when matched then
			update set
				dest.category_name = diff.category_name,
			  dest.category_object_id = diff.category_object_id
		when not matched then
			insert (dest.timeline_id, dest.wbs_id, dest.category_name, dest.category_object_id)
			values (diff.timeline_id, diff.wbs_id, diff.category_name, diff.category_object_id);

		v_rowcount := v_rowcount + sql%rowcount;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'timeline_id='||p_timeline_id||';rowcount='||v_rowcount||';'||v_log_txt,v_steps_result);

	exception when others then
		log_pkg.catch(v_where,'timeline_id='||p_timeline_id||';rowcount='||v_rowcount||';'||v_log_txt,v_steps_result);
		--raise;
	end;

	/*************************************************************************/
	procedure merge_timeline_activity(p_timeline_id in nvarchar2) as
		v_rowcount number:=0;
		v_count_view number;
		v_count_tab number;
		----
		v_where nvarchar2(222):='timeline_pkg.merge_timeline_activity';
        v_par nvarchar2(4000) := 'p_timeline_id=' || p_timeline_id;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
        v_msg_out nvarchar2(4000);
		----
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);--null=BEGIN
		merge into timeline_activity dest
		using (
			select
				max(decode (seq, 1, project_id)) project_id,
				timeline_id,
				max(decode (seq, 1, timeline_type_code)) timeline_type_code,
				activity_id,
				parent_wbs_id,
				max(decode (seq, 1, study_element_id)) study_element_id,
				max(decode (seq, 1, study_id)) study_id,
				max(decode (seq, 1, type)) type,
				max(decode (seq, 1, integration_type)) integration_type,
				max(decode (seq, 1, code)) code,
				max(decode (seq, 1, name)) name,
				max(decode (seq, 1, milestone_code)) milestone_code,
				max(decode (seq, 1, phase_code)) phase_code,
				max(decode (seq, 1, create_user)) create_user,
				max(decode (seq, 1, plan_start)) plan_start,
				max(decode (seq, 1, plan_finish)) plan_finish,
				max(decode (seq, 1, actual_start)) actual_start,
				max(decode (seq, 1, actual_finish)) actual_finish,
				sum(decode (seq, 1, srccnt, dstcnt)) iud
			from (
				select
					project_id,timeline_id,timeline_type_code,activity_id,parent_wbs_id,study_element_id,study_id,type,
					integration_type,code,name,milestone_code,phase_code,create_user,plan_start,plan_finish,actual_start,
					actual_finish,
					srccnt, dstcnt,row_number() over (partition by timeline_id,activity_id,parent_wbs_id order by dstcnt nulls last) seq
				from (
					select
						project_id,timeline_id,timeline_type_code,activity_id,parent_wbs_id,study_element_id,study_id,type,
						integration_type,code,name,milestone_code,phase_code,create_user,plan_start,plan_finish,actual_start,
						actual_finish
						,count (src) srccnt, count (dst) dstcnt
					from (
						select project_id,timeline_id,timeline_type_code,activity_id,parent_wbs_id,study_element_id,study_id,type,
								integration_type,code,name,milestone_code,phase_code,create_user,plan_start,plan_finish,actual_start,
								actual_finish, 1 src, to_number (null) dst
						from
							(
								select
									tl.project_id,
									tl.id as timeline_id,
									tl.type_code timeline_type_code,
									xt.activity_id,
									xt.parent_wbs_id,
									xt.study_element_id,
									xt.study_id,
									xt.type,
									xt.integration_type,
									xt.code,
									xt.name,
									xt.milestone_code,
									xt.phase_code,
									xt.create_user,
									get_date(xt.plan_start_str) as plan_start,
									get_date(xt.plan_finish_str) as plan_finish,
									get_date(xt.actual_start_str) as actual_start,
									get_date(xt.actual_finish_str) as actual_finish
								from
									timeline tl,
									xmltable(
										xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
										'/timeline/activities/activity' passing tl.details
										columns
											activity_id path '/activity/@id',
											parent_wbs_id path '/activity/@wbsId',
											study_element_id path '/activity/@studyElementId',
											study_id path '/activity/@studyId',
											type path '/activity/type',
											functions xmltype path '/activity/functions',
											integration_type path '/activity/integrationType',
											plan_start_str path '/activity/planStart',
											plan_finish_str path '/activity/planFinish',
											actual_start_str path '/activity/actualStart',
											actual_finish_str path '/activity/actualFinish',
											code path '/activity/code',
											name path '/activity/name',
											milestone_code path '/activity/milestoneCode',
											phase_code path '/activity/phaseCode',
											create_user path '/activity/createUser'
									) xt
								where tl.details is not null
								)
						where timeline_id = nvl(p_timeline_id, timeline_id)

						union all

						select project_id,timeline_id,timeline_type_code,activity_id,parent_wbs_id,study_element_id,study_id,type,
								integration_type,code,name,milestone_code,phase_code,create_user,plan_start,plan_finish,actual_start,
								actual_finish, to_number(null) src, 2 dst
						from timeline_activity
						where timeline_id = nvl(p_timeline_id, timeline_id)
					)
					group by project_id,timeline_id,timeline_type_code,activity_id,parent_wbs_id,study_element_id,study_id,type,
								integration_type,code,name,milestone_code,phase_code,create_user,plan_start,plan_finish,actual_start,
								actual_finish
					having count (src) <> count (dst)
				)
			)
			group by timeline_id,activity_id,parent_wbs_id
		) diff
		ON (dest.timeline_id = diff.timeline_id and dest.activity_id = diff.activity_id and nvl(dest.parent_wbs_id,'###') = nvl(diff.parent_wbs_id,'###'))
		WHEN MATCHED
		THEN
			 UPDATE SET
				  dest.project_id = diff.project_id
				 ,dest.timeline_type_code = diff.timeline_type_code
				 ,dest.study_element_id = diff.study_element_id
				 ,dest.study_id = diff.study_id
				 ,dest.type = diff.type
				 ,dest.integration_type = diff.integration_type
				 ,dest.code = diff.code
				 ,dest.name = diff.name
				 ,dest.milestone_code = diff.milestone_code
				 ,dest.phase_code = diff.phase_code
				 ,dest.create_user = diff.create_user
				 ,dest.plan_start = diff.plan_start
				 ,dest.plan_finish = diff.plan_finish
				 ,dest.actual_start = diff.actual_start
				 ,dest.actual_finish = diff.actual_finish
				 ,update_date=sysdate
			 DELETE
					WHERE (diff.iud = 0)
		WHEN NOT MATCHED
		then
			 insert (project_id,timeline_id,timeline_type_code,activity_id,parent_wbs_id,study_element_id,study_id,type,
						integration_type,code,name,milestone_code,phase_code,create_user,plan_start,plan_finish,actual_start,
						actual_finish,create_date)
			 values (diff.project_id,diff.timeline_id,diff.timeline_type_code,diff.activity_id,diff.parent_wbs_id,diff.study_element_id,diff.study_id,diff.type,
						diff.integration_type,diff.code,diff.name,diff.milestone_code,diff.phase_code,diff.create_user,diff.plan_start,diff.plan_finish,diff.actual_start,
						diff.actual_finish,sysdate);
		------------------------------------------------------------------------
		v_rowcount := sql%rowcount;
		log_pkg.steps('a'||v_rowcount,v_step_start,v_steps_result);
		------------------------------------------------------------------------
	
		if p_timeline_id is null then -- LOG controlling checks
			select count(1) into v_count_tab from timeline_activity;

			select count(1) into v_count_view from
				timeline tl,
				xmltable(
					xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
					'/timeline/activities/activity' passing tl.details
					columns
						activity_id path '/activity/@id',
						parent_wbs_id path '/activity/@wbsId',
						study_element_id path '/activity/@studyElementId',
						study_id path '/activity/@study_id',
						type path '/activity/type',
						functions xmltype path '/activity/functions',
						integration_type path '/activity/integrationType',
						plan_start_str path '/activity/planStart',
						plan_finish_str path '/activity/planFinish',
						actual_start_str path '/activity/actualStart',
						actual_finish_str path '/activity/actualFinish',
						code path '/activity/code',
						name path '/activity/name',
						milestone_code path '/activity/milestoneCode',
						phase_code path '/activity/phaseCode',
						create_user path '/activity/createUser'
				) xt
			where tl.details is not null;

		v_msg_out:=v_msg_out||';count_view='||v_count_view||';count_tab='||v_count_tab;
		------------------------------------------------------------------------
		v_rowcount := sql%rowcount;
		log_pkg.steps('b'||v_rowcount,v_step_start,v_steps_result);
		------------------------------------------------------------------------
			
		else
		
			merge into timeline_activity ta
				using (
					select 
						timeline_id,
						wbs_id, 
						min(root_study_wbs_id) root_study_wbs_id --in case two studies exists in the same node take older one that has lower sys id
					from (
					select
						tws.timeline_id,
						tws.wbs_id,
						connect_by_root tws.wbs_id root_study_wbs_id
					from timeline_wbs tws
					left join study st on (st.id=tws.study_id and st.project_id=tws.project_id)
					where tws.timeline_id=p_timeline_id
					start with st.id is not null and tws.timeline_id=p_timeline_id
					connect by prior tws.wbs_id=tws.parent_wbs_id and tws.timeline_id=p_timeline_id
					) group by timeline_id, wbs_id
				  ) tw on (ta.parent_wbs_id=tw.wbs_id and ta.timeline_id = tw.timeline_id)
			when matched then update set ta.root_study_wbs_id=tw.root_study_wbs_id
			;
		------------------------------------------------------------------------
		v_rowcount := sql%rowcount;
		log_pkg.steps('c'||v_rowcount,v_step_start,v_steps_result);
		------------------------------------------------------------------------

			--if still root_study_wbs_id is null then update it using parent_wbs_id if it is study wbs node
			update timeline_activity ta set ta.root_study_wbs_id=ta.parent_wbs_id
			where ta.activity_id in 
				(
					select ta.activity_id 
					from timeline_activity ta
					join timeline_wbs tws on (tws.wbs_id=ta.parent_wbs_id)
					where ta.root_study_wbs_id is null 
					and tws.study_id is not null
					and ta.timeline_id=p_timeline_id
				) 
			and ta.root_study_wbs_id is null
			and ta.timeline_id=p_timeline_id
			;
		------------------------------------------------------------------------
		v_rowcount := sql%rowcount;
		log_pkg.steps('d'||v_rowcount,v_step_start,v_steps_result);
		------------------------------------------------------------------------

		end if;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where,v_par,v_steps_result||';'||v_msg_out);

	exception when others then
		log_pkg.scatch(v_where,v_par,v_steps_result||';'||v_msg_out);
		--raise;
	end;

	/***************************************************************************************************************/
	procedure merge_timeline_expense(p_timeline_id in nvarchar2) as
		v_rowcount number:=0;
		v_count_view number;
		v_count_tab number;
		----
		v_where nvarchar2(222):='timeline_pkg.merge_timeline_expense';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		v_log_txt nvarchar2(222);
		----
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);--null=BEGIN

		-- Remove things that do not exist anymore
		delete from timeline_expense dest
		where timeline_id=p_timeline_id
			and not exists(
				select *
				from timeline_expense_vw
				where timeline_id=dest.timeline_id and decode(wbs_id, dest.wbs_id, 1)=1 and function_code=dest.function_code and cost_type_code=dest.cost_type_code
			);

		v_rowcount := v_rowcount + sql%rowcount;

		-- Update / insert things that differ
		merge into timeline_expense dest
		using (
			select timeline_id, wbs_id, function_code, cost_type_code, cost_type, code, plan_cost, comments, timeline_type_code, project_id
			from timeline_expense_vw
			where timeline_id=p_timeline_id
			minus
			select timeline_id, wbs_id, function_code, cost_type_code, cost_type, code, plan_cost, comments, timeline_type_code, project_id
			from timeline_expense
			where timeline_id=p_timeline_id
		) diff on (diff.timeline_id=dest.timeline_id and decode(diff.wbs_id, dest.wbs_id, 1)=1 and diff.function_code=dest.function_code and diff.cost_type_code=dest.cost_type_code)
		when matched then
			update set
				dest.cost_type = diff.cost_type,
				dest.plan_cost = diff.plan_cost,
				dest.comments = diff.comments,
				dest.timeline_type_code = diff.timeline_type_code,
				dest.project_id = diff.project_id,
				update_date = sysdate
		when not matched then
			insert (timeline_id, wbs_id, function_code, cost_type_code, cost_type, code, plan_cost, comments, timeline_type_code, project_id, create_date)
			values (diff.timeline_id, diff.wbs_id, diff.function_code, diff.cost_type_code, diff.cost_type, diff.code, diff.plan_cost, diff.comments, diff.timeline_type_code, diff.project_id, sysdate);

		v_rowcount := v_rowcount + sql%rowcount;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'timeline_id='||p_timeline_id||';rowcount='||v_rowcount||';'||v_log_txt,v_steps_result);

	exception when others then
		log_pkg.catch(v_where,'timeline_id='||p_timeline_id||';rowcount='||v_rowcount||';'||v_log_txt,v_steps_result);
		--raise;
	end;

	/***************************************************************************************************************/
	procedure delete_redundant_baselines(p_id in nvarchar2)
	is
		v_payload xmltype;
		v_msgid nvarchar2(20);
		v_where nvarchar2(99):='timeline_pkg.delete_redundant_baselines';
	begin

		select
			xmlElement("delete",
				xmlAttributes(message_pkg.nsuri_ipms_soa as "xmlns"),
				xmlElement("baselines",
					xmlattributes(message_pkg.nsuri_ipms as "xmlns",
						tl.id as "timelineId"
					)
				)
			)
		into v_payload
		from timeline tl
		where tl.id=p_id;

		--v_msgid := message_pkg.send('delete:baselines:'||p_id, v_payload, null);

		send_message(p_id, v_payload,
			get_text('begin baseline_pkg.read_baselines_finish(''%1'',:1);%2 end;', varchar2_table_typ(p_id, null)));

	exception when others then
		notice_pkg.catch(v_where, 'p_id='||p_id);
		raise;
	end;

	/***************************************************************************************************************/
	procedure refresh_materialized_data
	(
		p_timeline_id in timeline.id%type,
		p_project_id in project.id%type,
		p_payload in xmltype
	)
	is
		v_where nvarchar2(222):='timeline_pkg.refresh_materialized_data';
        v_par nvarchar2(4000) := 'p_timeline_id='||p_timeline_id||';p_project_id='||p_project_id;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
        v_msg_out nvarchar2(4000);

	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		timeline_pkg.merge_timeline_wbs(p_timeline_id);
		timeline_pkg.merge_timeline_wbs_category(p_timeline_id);
		timeline_pkg.merge_timeline_activity(p_timeline_id);
		timeline_pkg.merge_timeline_expense(p_timeline_id);
		baseline_pkg.read_baselines_finish(p_timeline_id,p_payload);
		project_activities_pkg.timeline_merge(p_project_id);

		log_pkg.steps('END.', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

	exception when others then
		log_pkg.steps('ERROR.', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
		notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
		raise;
	end;

end;
/