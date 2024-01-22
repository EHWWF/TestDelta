create or replace package estimates_pkg
as
	/**
	* Initiates latest estimates process.
	* Requires unlocked process in status 'new'.
	* Throws no_data_found exception if requirements unmatched.
	* Asynchronous.
	* Sends execute/estimate message and locks instance.
	*/
	procedure starts(p_id in nvarchar2)
	;
	/**
	* Terminates latest estimates process.
	* Requires unlocked process in status 'new','run'
	* Throws no_data_found exception if requirements unmatched.
	* Asynchronous.
	* Sends terminate/estimate message and locks instance.
	*/
	procedure stop(p_id in nvarchar2)
	;
	/**
	* Restarts latest estimates process.
	* Requires unlocked process in status 'run'
	* Throws no_data_found exception if requirements unmatched.
	* Asynchronous.
	* Sends terminate/estimate message and locks instance.
	*/
	procedure restart(p_id in nvarchar2)
	;
	/**
	* Completes latest estimates process startup.
	* Unlocks instance.
	* Changes status into 'run'.
	* Initiates le setup for whole process.
	* Callback.
	*/
	procedure starts_bpm_finish
	(
		p_id in nvarchar2,
		p_payload in xmltype
	)
	;
	/**
	* Completes latest estimates termination.
	* Unlocks instance.
	* Changes status into 'fin'.
	* Callback.
	*/
	procedure stop_bpm_finish
	(
		p_id in nvarchar2,
		p_payload in xmltype
	)
	;
	/**
	* Completes latest estimates restart - starts new process.
	* Unlocks instance.
	* Callback.
	*/
	procedure restart_finish
	(
		p_id in nvarchar2,
		p_payload in xmltype
	)
	;
	/**
	* Initializes latest estimates for process or process program.
	* Synchronizes le rows according to costs and current plan data.
	* Requires unlocked instance.
	* Throws no_data_found exception if requirements unmatched.
	*/
	procedure setup
	(
		p_tag_id in nvarchar2,
		p_process_id in nvarchar2 default null,
		p_program_id in nvarchar2 default null,
		p_old_process_id in nvarchar2 default null --jira:PROMIS-466
	)
	;
	/**
	* Transfers latest estimates into costs table.
	* Deletes previous le rows for the same period.
	* Requires unlocked instance in status 'run'.
	* Throws no_data_found exception if requirements unmatched.
	*/
	procedure submit
	(
		p_process_id in nvarchar2,
		p_program_id in nvarchar2
	)
	;
	/**
	* Returns summary of le.
	*/
	function get_summary
	(
		p_tag_id in nvarchar2,
		p_process_id in nvarchar2 default null,
		p_program_id in nvarchar2 default null
	)
	return nvarchar2
	;
	/**
	* Returns subject of le.
	*/
	function get_subject
	(
		p_id in nvarchar2
	)
	return nvarchar2
	;
	/**
	* Returns latest forecast number and version as continuous string.
	*/
	function get_latest_fc_numbver return nvarchar2
	;
end;
/
create or replace package body  estimates_pkg
as
	/*************************************************************************/
	function get_summary
	(
		p_tag_id in nvarchar2,
		p_process_id in nvarchar2 default null,
		p_program_id in nvarchar2 default null
	)
	return nvarchar2
	as
		v_tag nvarchar2(200);
		v_process nvarchar2(200);
		v_program nvarchar2(200);
	begin
		if p_tag_id is not null then
			select 'LE Tag[' || id || ',' || name || ']'
			into v_tag
			from latest_estimates_tag
			where id = p_tag_id;
		end if;

		if p_process_id is not null then
			select 'LE Process[' || id || ',' || name || ']'
			into v_process
			from latest_estimates_process
			where id = p_process_id;
		end if;

		if p_program_id is not null then
			v_program := ' for ' || program_pkg.get_summary(p_program_id);
		end if;

		return v_tag || v_process || v_program;

	exception when no_data_found then
		return 'Estimates[' || nvl(p_process_id, '-') || ']';
	end;

	/*************************************************************************/
	function get_subject(p_id in nvarchar2)
	return nvarchar2
	as
	begin
		return 'estimate_le:' || p_id;
	end;

	/*************************************************************************/
	procedure send
	(
		p_id in nvarchar2,
		p_payload in xmltype,
		p_callback varchar2
	)
	as
		v_where nvarchar2(222) := 'estimates_pkg.send';
		v_par nvarchar2(4000) := 'p_id=' || p_id || ';p_callback=' || p_callback;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		msgid nvarchar2(20);
		subject nvarchar2(50);
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);
		/* check status */
		select get_subject(lep.id)
		into subject
		from latest_estimates_process lep
		where lep.id = p_id and lep.is_syncing = 0;

		/* send request */
		msgid := message_pkg.send(subject, p_payload, p_callback);

		/* mark busy */
		update latest_estimates_process
		set is_syncing = 1, sync_id = msgid
		where id = p_id;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result);

	exception when others then
		notice_pkg.catch(v_where, v_par || ';' || v_steps_result);
		raise;
	end;

	/*************************************************************************/
	procedure starts(p_id in nvarchar2)
	as
		l_tag_id latest_estimates_tag.id%type;
		v_where nvarchar2(222) := 'estimates_pkg.starts';
		v_par nvarchar2(4000) := 'p_id=' || p_id;
	begin
		update latest_estimates_process
		set sync_date = sysdate, status_code = 'RUN'
		where id = p_id
		returning let_id into l_tag_id;

		setup(l_tag_id, p_id, null);

		task_pkg.create_le(p_id);

		--start_bpm(p_id);  -- Use this line when want to use real BPM process. Comment everything else in this procedure.

		log_pkg.log(v_where, v_par);

	exception when others then
		notice_pkg.catch(v_where, v_par);
		raise;
	end;

	/*************************************************************************/
	procedure start_bpm
	(
		p_id in nvarchar2,
		p_callback in varchar2 default null
	)
	as
		payload xmltype;
		v_where nvarchar2(222) := 'estimates_pkg.starts_bpm';
		v_par nvarchar2(4000) := 'p_id=' || p_id || ';p_callback=' || p_callback;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;

	begin
		log_pkg.steps(null, v_step_start, v_steps_result);
		-- setup the request
		select message_pkg.xml(
			'<estimate ' || message_pkg.xmlns_ipms_soa || ' componentName="EstimateCosts">' ||
				'<process id="' || p_id || '" ' || message_pkg.xmlns_ipms || '>' ||
				get_element('name', lep.name) ||
				get_element('terminationDate', get_char_date(lep.termination_date)) ||
				get_element('tag', let.name) ||
				get_element('processName', lep.name) ||
				--PROMIS-571, BPM is not able to get name from recordType.name, thus, adding dedicated XML element.
				'</process>' ||
				'<programs ' || message_pkg.xmlns_ipms || '/>' ||
			'</estimate>')
			into payload
		from latest_estimates_process lep
		join latest_estimates_tag let on (lep.let_id = let.id)
		where lep.id = p_id and lep.status_code in ('NEW', 'RUN');

		-- collect programs
		for prg in (
			select lep.program_id
			from latest_estimates_project_vw lep --join project pj on pj.id=lep.project_id
			where lep.process_id = p_id
			group by lep.program_id
		)
		loop
			payload := payload.appendchildxml('//programs', program_pkg.xml(prg.program_id, 2), message_pkg.xmlns_ipms);
		end loop;

		-- send request
		send(p_id, payload,
		get_text('begin estimates_pkg.starts_bpm_finish(''%1'',:1);%2 end;', varchar2_table_typ(p_id, p_callback)));

		-- change status
		update latest_estimates_process
		set status_code = 'PLAN'
		where id = p_id;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result);

	exception when others then
		notice_pkg.catch(v_where, v_par || ';' || v_steps_result);
		raise;
	end;

	/*************************************************************************/
	procedure stop(p_id in nvarchar2)
	as
		l_let_id latest_estimates_tag.id%type;
		v_where nvarchar2(222) := 'estimates_pkg.stop';
		v_par nvarchar2(4000) := 'p_id=' || p_id;
	begin
		-- update data
		update latest_estimates_process
		set sync_date = sysdate, status_code = 'FIN'
		where id = p_id
		returning let_id into l_let_id;

		update latest_estimates_tag let
		set let.is_meeting_allowed = 1
		where id = l_let_id
		and let.is_meeting_allowed = 0;

		task_pkg.revoke_le(p_id);
		--stop_bpm(p_id); -- Use this line when want to use real BPM process. Comment everything else in this procedure.
		log_pkg.log(v_where, v_par);

	exception when others then
		notice_pkg.catch(v_where, v_par);
		raise;
	end;

	/*************************************************************************/
	procedure stop_bpm
	(
		p_id in nvarchar2,
		p_callback in varchar2 default null
	)
	as
		v_msg_id latest_estimates_process.sync_id%type;
		v_where nvarchar2(222) := 'estimates_pkg.stop_bpm';
		v_par nvarchar2(4000) := 'p_id=' || p_id || ';p_callback=' || p_callback;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		l_let_id latest_estimates_tag.id%type;
		v_msg nvarchar2(999);
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);

		select sync_id
		into v_msg_id
		from latest_estimates_process
		where id = p_id
		and status_code in ('RUN', 'NEW');

		if v_msg_id is not null then
			-- does not make sense to terminate without knowing msg ID
			v_msg_id := message_pkg.terminate(v_msg_id, 'EstimateCosts',
						get_text('begin estimates_pkg.stop_bpm_finish(''%1'',:1);%2 end;',
						varchar2_table_typ(p_id, p_callback)));

			if v_msg_id is not null then -- do not update to NULL if something went wrong with BPM termination
				update latest_estimates_process
				set is_syncing = 1, sync_id = v_msg_id
				where id = p_id;
			else
				v_msg := ';ERROR. Missing MSG ID after message_pkg.terminate !';
			end if;
		else
			v_msg := ';ERROR. Missing MSG ID !';
			--Nevertheless, the Termination, because it was started incorrectly
			update latest_estimates_process
			set sync_date = sysdate, is_syncing = 0, status_code = 'FIN'
			where id = p_id
			returning let_id into l_let_id;

			update latest_estimates_tag let
			set let.is_meeting_allowed = 1
			where id = l_let_id
			and let.is_meeting_allowed = 0;
		end if;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg);

	exception when others then
		notice_pkg.catch(v_where, v_par || ';' || v_steps_result || v_msg);
		raise;
	end;

	/*************************************************************************/
	procedure restart(p_id in nvarchar2)
	as
	begin
		stop(p_id);
		starts(p_id);
		--restart_bpm(p_id); -- Use this line when want to restart real BPM process
	end;

	/*************************************************************************/
	procedure restart_bpm
	(
		p_id in nvarchar2,
		p_callback in varchar2 default null
	)
	as
		v_msg_id latest_estimates_process.sync_id%type;
		v_where nvarchar2(222) := 'estimates_pkg.restart';
		v_par nvarchar2(4000) := 'p_id=' || p_id || ';p_callback=' || p_callback;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg nvarchar2(999);

	begin
		log_pkg.steps(null, v_step_start, v_steps_result);

		select sync_id
		into v_msg_id
		from latest_estimates_process
		where id = p_id
		and status_code = 'RUN';

		if v_msg_id is not null then
			-- does not make sense to terminate without knowing msg ID
			v_msg_id := message_pkg.terminate(v_msg_id, 'EstimateCosts',
			get_text('begin estimates_pkg.restart_finish(''%1'',:1);%2 end;',
			varchar2_table_typ(p_id, p_callback)));

			if v_msg_id is not null then
				-- do not update to NULL if something went wrong with BPM termination
				update latest_estimates_process
				set is_syncing = 1, sync_id = v_msg_id
				where id = p_id;
			else
				v_msg := ';ERROR. Missing MSG ID after message_pkg.terminate !';
			end if;

		else
			v_msg := ';ERROR. Missing MSG ID !';
		end if;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg);

	exception when others then
		notice_pkg.catch(v_where, v_par || ';' || v_steps_result || v_msg);
		raise;
	end;

	/*************************************************************************/
	procedure prefill
	(
		p_tag in latest_estimates_tag%rowtype,
		p_lep_id in latest_estimates_process.id%type default null,
		p_program_id in program.id%type default null,
		p_old_process_id in nvarchar2 default null
	)
	as
		l_lep latest_estimates_process%rowtype;
		v_rowcount number := 0;
		v_where nvarchar2(222) := 'estimates_pkg.prefill';
		v_par nvarchar2(4000) := 'p_tag.id=' || p_tag.id ||
								';p_lep_id=' || p_lep_id ||
								';p_program_id='|| p_program_id ||
                                ';p_old_process_id='|| p_old_process_id ;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_prefil_log nvarchar2(4000);
		v_start_data_collection latest_estimates_process.create_date%type;

	begin
		log_pkg.steps(null, v_step_start, v_steps_result);

		begin
			--below SQL is just for logging at sys_log table
			select
				';' ||
				decode(p_tag.is_prefill_prob, null, null, 'is_prefill_prob=' || p_tag.is_prefill_prob) ||
				decode(p_tag.cy_prob_prefill_code, null, null, ',cy_prob_prefill_code=' || p_tag.cy_prob_prefill_code) ||
				decode(p_tag.cy_prob_prefill_tag_id, null, null, ',cy_prob_prefill_tag_id=' || p_tag.cy_prob_prefill_tag_id) ||
				decode(p_tag.ny_prob_prefill_code, null, null, ',ny_prob_prefill_code=' || p_tag.ny_prob_prefill_code) ||
				decode(p_tag.ny_prob_prefill_tag_id, null, null,',ny_prob_prefill_tag_id=' || p_tag.ny_prob_prefill_tag_id)
			into v_prefil_log
			from dual;
		exception when others then
			null;
		end;

		--get date for started data collection
		select start_data_collection
		into v_start_data_collection
		from (
			select
				lep.create_date as start_data_collection,
				rank() over (partition by lep.let_id order by lep.let_id, lep.id ) as rnk
			from latest_estimates_process lep
			where lep.let_id = p_tag.id
		)
		where rnk = 1;

		if p_lep_id is not null then
			select lep.*
			into l_lep
			from latest_estimates_process lep
			where lep.id = p_lep_id;
		end if;

		--forecast costs - clear/prepare for prefilling
		if p_tag.is_prefill_prob = 1 then
			update latest_estimate set
				is_prefilled_cyp = 0,
				is_prefilled_nyp = 0
			where process_id in
			(
				select id
				from latest_estimates_process
				where let_id = p_tag.id
			);
		end if;

		--reset control flags
		update latest_estimates_tag
		set is_prefill_prob = 0
		where id = p_tag.id;
		v_rowcount := sql%rowcount;
		log_pkg.steps('a' || v_rowcount, v_step_start, v_steps_result);

		--update/prefill LE
		--cyd from LE - applied only on process start
		merge into latest_estimate trg
		using (
			select
				decode(lep.year, l_lep.year, le.estimate_det_curr_year, l_lep.year - 1, le.estimate_det_next_year,null) as estimate_cyd,
				le.comments_curr_year,
				le.development_phase_code,
				le.subtype_code,
				le.study_id,
				le.function_code,
				le.program_id,
				le.project_id,
				le.process_id
			from latest_estimates_process lep
			join latest_estimate le on (le.process_id = lep.id)
			where lep.id = l_lep.cy_det_prefill_lep_id
			and l_lep.cy_det_prefill_code = 'LE'
		) src
		on (
				trg.process_id = p_lep_id
			and l_lep.cy_det_prefill_code = 'LE'
			and src.program_id = trg.program_id
			and (src.program_id = p_program_id or p_program_id is null)
			and src.project_id = trg.project_id
			and nvl(src.function_code, '-') = nvl(trg.function_code, '-')
			and nvl(src.study_id, '-') = nvl(trg.study_id, '-')
			and nvl(src.subtype_code, '-') = nvl(trg.subtype_code, '-')
			and nvl(src.development_phase_code, '-') = nvl(trg.development_phase_code, '-')
		)
		when matched then
			update set
				trg.estimate_det_curr_year = src.estimate_cyd,
				trg.comments_curr_year = src.comments_curr_year,
				trg.is_prefilled_cyd = 1
			where trg.is_prefilled_cyd = 0
			and nvl(trg.subtype_code, 'X') != 'OEI'
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('b' || v_rowcount, v_step_start, v_steps_result);

		--analogically as for cyd now update/prefill LE
		--nyd from LE
		merge into latest_estimate trg
		using (
			select
				decode(lep.year, l_lep.year, le.estimate_det_next_year, l_lep.year + 1, le.estimate_det_curr_year,null) as estimate_nyd,
				le.comments_next_year,
				le.development_phase_code,
				le.subtype_code,
				le.study_id,
				le.function_code,
				le.program_id,
				le.project_id,
				le.process_id
			from latest_estimates_process lep
			join latest_estimate le on (le.process_id = lep.id)
			where lep.id = l_lep.ny_det_prefill_lep_id
			and l_lep.ny_det_prefill_code = 'LE'
		) src
		on (
				trg.process_id = p_lep_id
			and l_lep.ny_det_prefill_code = 'LE'
			and src.program_id = trg.program_id
			and (src.program_id = p_program_id or p_program_id is null)
			and src.project_id = trg.project_id
			and nvl(src.function_code, '-') = nvl(trg.function_code, '-')
			and nvl(src.study_id, '-') = nvl(trg.study_id, '-')
			and nvl(src.subtype_code, '-') = nvl(trg.subtype_code, '-')
			and nvl(src.development_phase_code, '-') = nvl(trg.development_phase_code, '-')
		)
		when matched then
			update set
				trg.estimate_det_next_year = src.estimate_nyd,
				trg.comments_next_year = src.comments_next_year,
				trg.is_prefilled_nyd = 1
			where trg.is_prefilled_nyd = 0
			and nvl(trg.subtype_code, 'X') != 'OEI'
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('c' || v_rowcount, v_step_start, v_steps_result);

		--update/prefill analogically - current year probabilistic
		--cyp from LE
		merge into latest_estimate trg
		using (
			select
				decode(p_tag.cy_prob_prefill_code,'xLEp',
					decode(lep.year, p_tag.year, le.estimate_prob_curr_year, p_tag.year - 1,le.estimate_prob_next_year, null)
					,'cLEd', le.estimate_det_curr_year) as estimate_cyp,
				le.development_phase_code,
				le.subtype_code,
				le.study_id,
				le.function_code,
				le.program_id,
				le.project_id,
				le.process_id
			from latest_estimates_process lep
			join latest_estimate le on (le.process_id = lep.id)
			where lep.let_id = p_tag.cy_prob_prefill_tag_id
			and p_tag.cy_prob_prefill_code = 'xLEp'
			or lep.let_id = p_tag.id --following line with OR need a review
			and p_tag.cy_prob_prefill_code = 'cLEd'
		) src
		on (
				1 = 1
			and p_tag.cy_prob_prefill_code in ('xLEp', 'cLEd')
			and (trg.program_id = p_program_id or p_program_id is null)
			and src.program_id = trg.program_id
			and src.project_id = trg.project_id
			and nvl(src.function_code, '-') = nvl(trg.function_code, '-')
			and nvl(src.study_id, '-') = nvl(trg.study_id, '-')
			and nvl(src.subtype_code, '-') = nvl(trg.subtype_code, '-')
			and nvl(src.development_phase_code, '-') = nvl(trg.development_phase_code, '-')
		)
		when matched then
			update set
				trg.estimate_prob_curr_year = src.estimate_cyp,
				trg.is_prefilled_cyp = 1
			where trg.is_prefilled_cyp = 0
			and nvl(trg.subtype_code, 'X') != 'OEI'
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('d' || v_rowcount, v_step_start, v_steps_result);

		--nyp from LE
		merge into latest_estimate trg
		using (
			select
				decode(p_tag.ny_prob_prefill_code,'xLEp',
					decode(lep.year, p_tag.year, le.estimate_prob_next_year, p_tag.year + 1,le.estimate_prob_curr_year, null),
					'cLEd', le.estimate_det_next_year) as estimate_nyp,
				le.development_phase_code,
				le.subtype_code,
				le.study_id,
				le.function_code,
				le.program_id,
				le.project_id,
				le.process_id
			from latest_estimates_process lep
			join latest_estimate le on (le.process_id = lep.id)
			where lep.let_id = p_tag.ny_prob_prefill_tag_id
			and p_tag.ny_prob_prefill_code = 'xLEp'
			or lep.let_id = p_tag.id -- "or" need review
			and p_tag.ny_prob_prefill_code = 'cLEd'
		) src
		on (
				1 = 1
			and p_tag.ny_prob_prefill_code in ('xLEp', 'cLEd')
			and (trg.program_id = p_program_id or p_program_id is null)
			and src.program_id = trg.program_id
			and src.project_id = trg.project_id
			and nvl(src.function_code, '-') = nvl(trg.function_code, '-')
			and nvl(src.study_id, '-') = nvl(trg.study_id, '-')
			and nvl(src.subtype_code, '-') = nvl(trg.subtype_code, '-')
			and nvl(src.development_phase_code, '-') = nvl(trg.development_phase_code, '-')
		)
		when matched then
			update set
				trg.estimate_prob_next_year = src.estimate_nyp,
				trg.is_prefilled_nyp = 1
			where trg.is_prefilled_nyp = 0
			and nvl(trg.subtype_code, 'X') != 'OEI'
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('e' || v_rowcount, v_step_start, v_steps_result);

		--Other External Costs are ALWAYS prefilled with forecast values. This exception is included in FCT prefill case.
		--copy cyd from FCT-deterministic (the same record) where still not prefilled after first analogical action at the beginning
		update latest_estimate trg set
			trg.estimate_det_curr_year = nvl(get_number(extractvalue(trg.details, '//costs/current/fct_det')), 0),
			trg.is_prefilled_cyd = 1
		where (l_lep.cy_det_prefill_code = 'FCT' or trg.subtype_code = 'OEI')
		and trg.process_id = p_lep_id
		and (trg.program_id = p_program_id or p_program_id is null)
		and trg.is_prefilled_cyd = 0
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('f' || v_rowcount, v_step_start, v_steps_result);

		--nyd from FCT
		update latest_estimate trg set
			trg.estimate_det_next_year = nvl(get_number(extractvalue(trg.details, '//costs/next/fct_det')), 0),
			trg.is_prefilled_nyd = 1
		where (l_lep.ny_det_prefill_code = 'FCT' or trg.subtype_code = 'OEI')
		and trg.process_id = p_lep_id
		and (trg.program_id = p_program_id or p_program_id is null)
		and trg.is_prefilled_nyd = 0
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('g' || v_rowcount, v_step_start, v_steps_result);

		--cyp from FCT  - applied only durint LE meeting start
		update latest_estimate trg set
			trg.estimate_prob_curr_year = nvl(get_number(extractvalue(trg.details, '//costs/current/fct_prob')), 0),
			trg.is_prefilled_cyp = 1
		where (
			p_tag.cy_prob_prefill_code = 'FCTp' or
			trg.subtype_code = 'OEI' and
			nvl(p_tag.cy_prob_prefill_code, 'X') <> 'cLEclc'
		)
		and trg.process_id in (
			select lep.id
			from latest_estimates_process lep
			where lep.let_id = p_tag.id
		)
		and (trg.program_id = p_program_id or p_program_id is null)
		and trg.is_prefilled_cyp = 0
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('h' || v_rowcount, v_step_start, v_steps_result);

		--nyp from FCT
		update latest_estimate trg set
			trg.estimate_prob_next_year = nvl(get_number(extractvalue(trg.details, '//costs/next/fct_prob')), 0),
			trg.is_prefilled_nyp = 1
		where (
			p_tag.ny_prob_prefill_code = 'FCTp' or
			trg.subtype_code = 'OEI' and
			nvl(p_tag.ny_prob_prefill_code, 'X') <> 'cLEclc'
		)
		and trg.process_id in (
			select lep.id
			from latest_estimates_process lep
			where lep.let_id = p_tag.id
		)
		and (trg.program_id = p_program_id or p_program_id is null)
		and trg.is_prefilled_nyp = 0
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('i' || v_rowcount, v_step_start, v_steps_result);

		--cyp from cLEclc
		update (
			select
				trg.id,
				trg.project_id,
				trg.study_id,
				trg.function_code,
				trg.subtype_code,
				trg.estimate_prob_curr_year,
				trg.estimate_det_curr_year,
				trg.is_prefilled_cyp,
				get_number(extractvalue(trg.details, '//costs/current/fct_prob')) as fct_prob,
				get_number(extractvalue(trg.details, '//costs/current/fct_det')) as fct_det,
				get_number(extractvalue(trg.details, '//costs/current/act_det')) as act_det,
				(
					select probability
					from (
						select
							prob.function_code,
							ts.study_id,
							tl.project_id,
							prob.probability / 100 as probability,
							row_number() over (partition by tl.project_id, ts.study_id, prob.function_code, prob.study_element_id order by prob.lag desc ) as rn_rule_priority
						from timeline tl
						join study_milestone_tmp tm on (tm.timeline_id = tl.id)
						join study_tmp ts on (ts.wbs_id = tm.wbs_id)
						join costs_probability prob on (prob.scope_code = 'EXT' and prob.study_element_id = tm.milestone_id)
						where tl.type_code = 'CUR'
						and (
							prob.rule_code = 'AFTER' and
							trunc(nvl(v_start_data_collection, p_tag.create_date), 'mm') >= trunc(nvl(tm.actual_date, tm.plan_date), 'mm') or
							prob.rule_code = 'BEFORE' and trunc(nvl(tm.actual_date, tm.plan_date), 'mm') >= add_months(trunc(nvl(v_start_data_collection, p_tag.create_date), 'mm'), prob.lag)
						)
					) pr
					where pr.project_id = trg.project_id
					and pr.function_code = trg.function_code
					and pr.study_id = trg.study_id
					and pr.rn_rule_priority = 1
				) as probability
			from latest_estimate trg
			where p_tag.cy_prob_prefill_code = 'cLEclc'
			and trg.process_id in (
				select lep.id
				from latest_estimates_process lep
				where lep.let_id = p_tag.id
			)
			and (trg.program_id = p_program_id or p_program_id is null)
			and trg.is_prefilled_cyp = 0
		)
		set estimate_prob_curr_year =
			case
				when
					function_code is not null
					and
					(study_id is null and subtype_code = 'OEC' or study_id is not null)
				then
					case
						when
							abs(fct_prob / nullif(fct_det, 0)) > 1
						then
							estimate_det_curr_year
						else
							(estimate_det_curr_year - nvl(act_det, 0)) * coalesce(probability, fct_prob / nullif(fct_det, 0), 1) + nvl(act_det, 0)
					end
			else
				estimate_det_curr_year
			end,
			is_prefilled_cyp = 1
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('j' || v_rowcount, v_step_start, v_steps_result);

		-- nyp from cLEclc
		update (
			select
				trg.id,
				trg.project_id,
				trg.study_id,
				trg.function_code,
				trg.subtype_code,
				trg.estimate_prob_next_year,
				trg.estimate_det_next_year,
				trg.is_prefilled_nyp,
				get_number(extractvalue(trg.details, '//costs/next/fct_prob')) as fct_prob,
				get_number(extractvalue(trg.details, '//costs/next/fct_det')) as fct_det,
				get_number(extractvalue(trg.details, '//costs/current/act_det')) as act_det,
				(
					select probability
					from (
						select
							prob.function_code,
							ts.study_id,
							tl.project_id,
							prob.probability / 100 as probability,
							row_number() over (partition by tl.project_id, ts.study_id, prob.function_code, prob.study_element_id order by prob.lag desc ) as rn_rule_priority
						from timeline tl
						join study_milestone_tmp tm on tm.timeline_id = tl.id
						join study_tmp ts on ts.wbs_id = tm.wbs_id
						join costs_probability prob on (prob.scope_code = 'EXT' and prob.study_element_id = tm.milestone_id)
						where tl.type_code = 'CUR'
						and (
							prob.rule_code = 'AFTER' and trunc(nvl(v_start_data_collection, p_tag.create_date), 'mm') >= trunc(nvl(tm.actual_date, tm.plan_date), 'mm')
							or
							prob.rule_code = 'BEFORE' and trunc(nvl(tm.actual_date, tm.plan_date), 'mm') >= add_months(trunc(nvl(v_start_data_collection, p_tag.create_date), 'mm'), prob.lag)
						)
					) pr
					where pr.project_id = trg.project_id
					and pr.function_code = trg.function_code
					and pr.study_id = trg.study_id
					and pr.rn_rule_priority = 1
				) as probability
			from latest_estimate trg
			where p_tag.ny_prob_prefill_code = 'cLEclc'
			and trg.process_id in (
				select lep.id
				from latest_estimates_process lep
				where lep.let_id = p_tag.id
			)
			and (trg.program_id = p_program_id or p_program_id is null)
			and trg.is_prefilled_nyp = 0
		)
		set estimate_prob_next_year =
			case
				when
					function_code is not null
					and
					(study_id is null and subtype_code = 'OEC' or study_id is not null)
				then
					case
						when
							abs(fct_prob / nullif(fct_det, 0)) > 1
						then
							estimate_det_next_year
						else
							estimate_det_next_year * coalesce(probability, fct_prob / nullif(fct_det, 0), 1)
					end
				else estimate_det_next_year
			end,
		is_prefilled_nyp = 1
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('k' || v_rowcount, v_step_start, v_steps_result);

		--cyp from NONE
		update latest_estimate trg set
			trg.estimate_prob_curr_year = 0,
			trg.is_prefilled_cyp = 1
		where p_tag.cy_prob_prefill_code is null
		and trg.process_id in (
			select lep.id
			from latest_estimates_process lep
			where lep.let_id = p_tag.id
		)
		and (trg.program_id = p_program_id or p_program_id is null)
		and trg.is_prefilled_cyp = 0
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('l' || v_rowcount, v_step_start, v_steps_result);

		--nyp from NONE
		update latest_estimate trg set
			trg.estimate_prob_next_year = 0,
			trg.is_prefilled_nyp = 1
		where p_tag.ny_prob_prefill_code is null
		and trg.process_id in (
			select lep.id
			from latest_estimates_process lep
			where lep.let_id = p_tag.id
		)
		and (trg.program_id = p_program_id or p_program_id is null)
		and trg.is_prefilled_nyp = 0
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('m' || v_rowcount, v_step_start, v_steps_result);

		if p_old_process_id is not null then
			--jira:PROMIS-466
			--based on provided old process ID take the old values and show them/prefill for user view at Excel
			--due to the case that p_lep_id could be null and performacen could be slow separate udpate must be implemented with dedicated if
			--if p_lep_id is null then
				merge into latest_estimate trg
				using (
					select
						decode(lep.year, nvl(l_lep.year,p_tag.year), le.estimate_det_curr_year, nvl(l_lep.year,p_tag.year) - 1, le.estimate_det_next_year, null) as estimate_det_curr_year,
						--le.estimate_det_curr_year,
						decode(lep.year, nvl(l_lep.year,p_tag.year), le.estimate_det_next_year, nvl(l_lep.year,p_tag.year) + 1, le.estimate_det_curr_year, null) as estimate_det_next_year,
						--le.estimate_det_next_year,
						le.development_phase_code,
						le.subtype_code,
						le.study_id,
						le.function_code,
						le.program_id,
						le.project_id,
						le.process_id
					from latest_estimates_process lep
					join latest_estimate le on (le.process_id = lep.id)
					where lep.id = p_old_process_id
				) src
				on (	trg.process_id in (select les.id from latest_estimates_process les where les.let_id = p_tag.id)--p_tag.id is always not null
					and trg.process_id = nvl(p_lep_id, trg.process_id) --in case p_lep_id is null
					and src.program_id = trg.program_id
					and (src.program_id = p_program_id or p_program_id is null)
					and src.project_id = trg.project_id
					and nvl(src.function_code, '-') = nvl(trg.function_code, '-')
					and nvl(src.study_id, '-') = nvl(trg.study_id, '-')
					and nvl(src.subtype_code, '-') = nvl(trg.subtype_code, '-')
					and nvl(src.development_phase_code, '-') = nvl(trg.development_phase_code, '-')
				)
				when matched then
					update set
						trg.estimate_det_old_curr_year = src.estimate_det_curr_year,
						trg.estimate_det_old_next_year = src.estimate_det_next_year,
						trg.is_prefilled_old = 1
					where trg.is_prefilled_old = 0
				;
			/*
			else
				merge into latest_estimate trg
				using (
					select
						le.estimate_det_curr_year,
						le.estimate_det_next_year,
						le.development_phase_code,
						le.subtype_code,
						le.study_id,
						le.function_code,
						le.program_id,
						le.project_id,
						le.process_id
					from latest_estimates_process lep
					join latest_estimate le on (le.process_id = lep.id)
					where lep.id = p_old_process_id
				) src
				on (	trg.process_id = p_lep_id
					and src.program_id = trg.program_id
					and (src.program_id = p_program_id or p_program_id is null)
					and src.project_id = trg.project_id
					and nvl(src.function_code, '-') = nvl(trg.function_code, '-')
					and nvl(src.study_id, '-') = nvl(trg.study_id, '-')
					and nvl(src.subtype_code, '-') = nvl(trg.subtype_code, '-')
					and nvl(src.development_phase_code, '-') = nvl(trg.development_phase_code, '-')
				)
				when matched then
					update set
						trg.estimate_det_old_curr_year = src.estimate_det_curr_year,
						trg.estimate_det_old_next_year = src.estimate_det_next_year,
						trg.is_prefilled_old = 1
					where trg.is_prefilled_old = 0
				;
			end if;
			*/
			v_rowcount := sql%rowcount;
			log_pkg.steps('n' || v_rowcount, v_step_start, v_steps_result);

			--analogically as for cyd now update/prefill LE
			--nyd from LE
			/*
			merge into latest_estimate trg
			using (
				select
					decode(lep.year, l_lep.year, le.estimate_det_next_year, l_lep.year + 1, le.estimate_det_curr_year,null) as estimate_nyd,
					le.comments_next_year,
					le.development_phase_code,
					le.subtype_code,
					le.study_id,
					le.function_code,
					le.program_id,
					le.project_id,
					le.process_id
				from latest_estimates_process lep
				join latest_estimate le on (le.process_id = lep.id)
				where lep.id = l_lep.ny_det_prefill_lep_id
				and l_lep.ny_det_prefill_code = 'LE'
			) src
			on (
					trg.process_id = p_lep_id
				and l_lep.ny_det_prefill_code = 'LE'
				and src.program_id = trg.program_id
				and (src.program_id = p_program_id or p_program_id is null)
				and src.project_id = trg.project_id
				and nvl(src.function_code, '-') = nvl(trg.function_code, '-')
				and nvl(src.study_id, '-') = nvl(trg.study_id, '-')
				and nvl(src.subtype_code, '-') = nvl(trg.subtype_code, '-')
				and nvl(src.development_phase_code, '-') = nvl(trg.development_phase_code, '-')
			)
			when matched then
				update set
					trg.estimate_det_next_year = src.estimate_nyd,
					trg.comments_next_year = src.comments_next_year,
					trg.is_prefilled_nyd = 1
				where trg.is_prefilled_nyd = 0
				and nvl(trg.subtype_code, 'X') != 'OEI'
			;
			v_rowcount := sql%rowcount;
			log_pkg.steps('c' || v_rowcount, v_step_start, v_steps_result);
			*/
		end if;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_prefil_log);

	exception when others then
		notice_pkg.catch(v_where, v_par || ';' || v_steps_result || v_prefil_log);
		raise;
	end;

	/*************************************************************************/
	procedure setup
	(
		p_tag_id in nvarchar2,
		p_process_id in nvarchar2 default null,
		p_program_id in nvarchar2 default null,
		p_old_process_id in nvarchar2 default null --jira:PROMIS-466
	)
	as
		v_tag latest_estimates_tag%rowtype;
		v_rowcount number := 0;
		v_where nvarchar2(222) := 'estimates_pkg.setup';
		v_par nvarchar2(4000) :=
								'p_tag_id=' || p_tag_id ||
								';p_process_id=' || p_process_id ||
								';p_program_id=' || p_program_id ||
                                ';p_old_process_id=' || p_old_process_id;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);

		select tag.*
		into v_tag
		from latest_estimates_tag tag
		where tag.id = p_tag_id;

        v_par := v_par || ';latest_estimates_tag.old_process_id='||v_tag.old_process_id;

		-- Don't do anything for tags that are frozen.
		if v_tag.is_frozen = 1 then
			return;
		end if;

		-- Recalculate forecast if needed
		if v_tag.is_forecast_prob = 1 then
			for prj in (select project_id
						from latest_estimates_project_vw
						where tag_id = v_tag.id
			)
			loop
				costs_pkg.forecast(prj.project_id);
			end loop;
		end if;

		-- reset recalculation control flag
		update latest_estimates_tag
		set is_forecast_prob = 0
		where id = v_tag.id
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('a', v_step_start, v_steps_result);

		--before this change normal, full insert into TMP table was used
		--but changing from normal (full) insert to loop makes the whole operation faster because project_id index is being used properly
		delete from costs_fps_le_tmp;
		v_rowcount := 0;

		for rr in (	select lep.project_id
					from latest_estimates_project_vw lep
					where lep.tag_id = p_tag_id
					and (p_process_id is null or lep.process_id = p_process_id)
					and (p_program_id is null or lep.program_id = p_program_id)
					group by lep.project_id
		)
		loop
			insert into costs_fps_le_tmp
			select *
			from costs_fps_le_vw vw
			where vw.project_id = rr.project_id;

			v_rowcount := v_rowcount + sql%rowcount;
		end loop;
		log_pkg.steps('b' || v_rowcount, v_step_start, v_steps_result);

		insert into costs_function_tmp
		select *
		from costs_function_vw vw
		where vw.project_id in (
			select lep.project_id
			from latest_estimates_project_vw lep
			where lep.tag_id = p_tag_id
			and (p_process_id is null or lep.process_id = p_process_id)
			and (p_program_id is null or lep.program_id = p_program_id)
		);
		v_rowcount := sql%rowcount;
		log_pkg.steps('c' || v_rowcount, v_step_start, v_steps_result);

		--Performance issues can happen here, hepfully not. Initially was: jira: CUC-400, then rollbacked with PROMIS-456
		insert into study_tmp
		select *
		from study_data_vw vw
		where vw.timeline_type_code = 'CUR'
		and vw.project_id in (
			select lep.project_id
			from latest_estimates_project_vw lep
			where lep.tag_id = p_tag_id
			and (p_process_id is null or lep.process_id = p_process_id)
			and (p_program_id is null or lep.program_id = p_program_id)
		);
		v_rowcount := sql%rowcount;
		log_pkg.steps('d' || v_rowcount, v_step_start, v_steps_result);

		insert into milestone_tmp
		select *
		from milestone_vw vw
		where vw.timeline_type_code = 'CUR'
		and vw.project_id in (
			select lep.project_id
			from latest_estimates_project_vw lep
			where lep.tag_id = p_tag_id
			and (p_process_id is null or lep.process_id = p_process_id)
			and (p_program_id is null or lep.program_id = p_program_id)
		);
		v_rowcount := sql%rowcount;
		log_pkg.steps('ea' || v_rowcount, v_step_start, v_steps_result);

		insert into study_milestone_tmp
		select *
		from study_milestone_vw vw
		where vw.timeline_type_code = 'CUR'
		and vw.project_id in (
			select lep.project_id
			from latest_estimates_project_vw lep
			where lep.tag_id = p_tag_id
			and (p_process_id is null or lep.process_id = p_process_id)
			and (p_program_id is null or lep.program_id = p_program_id)
		);
		v_rowcount := sql%rowcount;
		log_pkg.steps('eb' || v_rowcount, v_step_start, v_steps_result);

	  --generate rows
	  merge into latest_estimate trg
	  using (
			  select
				le.process_id,
				le.program_id,
				le.project_id,
				le.study_id,
				le.study_status_code,
				le.function_code,
				decode(le.study_status_code, 'OTHER', nvl(le.subtype_code, 'OEC'), null) as subtype_code,
				le.development_phase_code,
				le.start_date,
				le.finish_date,
				le.poc_date,
				le.details,
				le.is_placeholder,
				le.study_is_placeholder,
				le.study_is_probing,
				le.study_is_obligation,
				le.study_is_gpdc_approved --,
			  --le.study_budget_class --commenting out LE change for: BAY_PROMIS-10
			  from (
					 with std_c as (
						 select
						   std2.project_id,
						   std2.id,
						   max(std2.fpfv)             fpfv,
						   max(std2.lplv)             lplv,
						   max(std2.study_name)       name,
						   max(std2.start_date)       start_date,
						   max(std2.finish_date)      finish_date,
						   max(std2.status_code)      status_code,
						   max(std2.phase_code)       phase_code,
						   max(std2.placeholder)      placeholder,
						   max(std2.is_probing)       is_probing,
						   max(std2.is_obligation)    is_obligation,
						   max(std2.is_gpdc_approved) is_gpdc_approved --,
						 --max(decode(nvl(std2.budget_class,'LD'),'LD',to_nchar('0005'),to_nchar('0002'))) budget_class --commenting out LE change for: BAY_PROMIS-10
						 from study_tmp std2
						 where std2.timeline_type_code = 'CUR'
						 group by std2.project_id, std2.id
						 having count(*) = 1
					 )
					 select
					   leproc.id                                                        as process_id,
					   prj.program_id,
					   leprj.project_id                                                 as project_id,
					   decode(plh.code, 0, std.id, 'LE Placeholder')                    as study_id,

					   case
					   when trunc(nvl(std.fpfv, decode(std.placeholder, 1, std.start_date, null))) <=
							trunc(last_day(leproc.create_date))
						 then 'RUN'
					   when trunc(nvl(std.fpfv, decode(std.placeholder, 1, std.start_date, null))) <=
							trunc(last_day(add_months(leproc.create_date, cs.value)))
						 then 'COMM'
					   when trunc(nvl(std.fpfv, decode(std.placeholder, 1, std.start_date, null))) >
							trunc(last_day(add_months(leproc.create_date, cs.value))) or
							std.placeholder = 0 and std.fpfv is null
						 then 'PLAN'
					   else 'OTHER'
					   end                                                              as study_status_code,

					   cst.function_code,
					   decode(plh.code, 0, cst.subtype_code, 'OEC')                     as subtype_code,

					   --commenting out LE change for: BAY_PROMIS-10
					   --decode(cst.study_id,null, nvl(dev.code,prj.development_phase_code), std_bgt.budget_class) as development_phase_code,
					   --nvl(decode(cst.study_id,null, decode(dev.code,'0005',poc.milestone_date,leproc.start_date), decode(std_bgt.budget_class,'0005',poc.milestone_date,leproc.start_date)),leproc.start_date) as start_date,
					   --nvl(decode(cst.study_id,null, decode(dev.code,'0002',poc.milestone_date,leproc.finish_date), decode(std_bgt.budget_class,'0005',poc.milestone_date,leproc.finish_date)),leproc.finish_date) as finish_date,
					   --commenting out LE change for: BAY_PROMIS-10

					   /*JIRA: PROMIS-605 Strt Deactiating Cost split in case the project is late/early development and there is poc milestone*/
                       --nvl(dev.code, prj.development_phase_code)                        as development_phase_code,                       
					   --decode(dev.code, '0005', poc.milestone_date, leproc.start_date)  as start_date,
					   --decode(dev.code, '0002', poc.milestone_date, leproc.finish_date) as finish_date,
                       
                       prj.development_phase_code                        as development_phase_code,    
                       leproc.start_date  as start_date,
                       leproc.finish_date as finish_date,                       
                       /*JIRA: PROMIS-605 end Deactiating Cost split in case the project is late/early development and there is poc milestone*/

					   poc.milestone_date                                               as poc_date,

					   message_pkg.xml(
						   '<details>' ||
						   nvl2(std.id,
								'<study>' ||
								get_element('name', std.name) ||
								get_element('phase', std.phase_code) ||
								get_element('fpfv', get_char_date(std.fpfv)) ||
								get_element('lplv', get_char_date(std.lplv)) ||
								'</study>',
								''
						   ) ||
						   '</details>')                                                as details,
					   plh.code                                                         as is_placeholder,
					   std.placeholder                                                     study_is_placeholder,
					   std.is_probing                                                      study_is_probing,
					   std.is_obligation                                                   study_is_obligation,
					   std.is_gpdc_approved                                                study_is_gpdc_approved --,
					 --std.budget_class study_budget_class --commenting out LE change for: BAY_PROMIS-10

					 /*le process with calculated planning period, either one year or two years*/
					 from (
							select
							  lp.*,
							  trunc(to_date(year, 'yyyy'), 'year') as start_date,
							  last_day(
								  add_months(trunc(to_date(decode(is_next_year, 1, year + 1, year), 'yyyy'), 'year'),
											 11))                  as finish_date
							from latest_estimates_process lp
							where lp.let_id = p_tag_id
						  ) leproc

					   join configuration cs on cs.code = 'STD-MM'

					   /*le project*/
					   join latest_estimates_project_vw leprj on leprj.process_id = leproc.id
					   join project prj on prj.id = leprj.project_id

					   /*placeholder multiplicator*/
					   cross join (select level - 1 code
								   from dual
								   connect by level < 3) plh

					   /*poc milestone within planning period*/
					   left join (
								   select
									 ml.*,
									 row_number()
									 over (
									   partition by project_id
										order by decode(upper(milestone_code), 'CPOT', 1,'POC', 2,3), milestone_date desc ) as rn
								   from milestone_tmp ml
									 join configuration cfg
										on cfg.code in ('POC', 'CPOT','D6') and upper(cfg.value) = upper(milestone_code)
								 ) poc on poc.project_id = prj.id and poc.rn = 1
										  and poc.milestone_date between leproc.start_date and leproc.finish_date

					   /*studies from costs for non placeholder rows*/
					   left join (
								   select
									 cst2.project_id,
									 cst2.study_id,
									 cst2.function_code,
									 cst2.subtype_code
								   from costs_function_tmp cst2
									 join latest_estimates_project_vw lepr4 on lepr4.project_id = cst2.project_id
									 join latest_estimates_process lep4 on lep4.id = lepr4.process_id
								   where
									 lep4.let_id = p_tag_id and (lep4.id = p_process_id or p_process_id is null) and
									 (lepr4.program_id = p_program_id or p_program_id is null)
									 and cst2.scope_code = 'EXT'
									 and (exists(select 1
												 from study_tmp std3
												 where cst2.study_id = std3.id and std3.timeline_type_code = 'CUR' and
													   std3.placeholder = 0) and cst2.study_id is not null or
										  cst2.study_id is null)
									 and cst2.year >= lep4.year and
									 cst2.year <= decode(lep4.is_next_year, 1, lep4.year + 1, lep4.year)
								   group by cst2.project_id, cst2.study_id, cst2.function_code, cst2.subtype_code
								   union all
								   /* Add study placeholders which normally should not have costs, but must be shown in form */
								   select
									 std2.project_id,
									 cast(std2.id as nvarchar2(20)) id,
									 null,
									 null
								   from study_tmp std2
								   where std2.timeline_type_code = 'CUR' and placeholder = 1
								 ) cst on plh.code = 0 and cst.project_id = prj.id

					   /*JIRA: PROMIS-605 Start Deactiating Cost split in case the project is late/early development and there is poc milestone*/
                       /*multiplying rows in case then project is late/early development and there is poc milestone*/
					   /*left join (select *
								  from development_phase
								  where code in ('0002', '0005')
								 ) dev
						 on prj.development_phase_code in ('0002', '0005') and poc.milestone_code is not null*/
                         /*JIRA: PROMIS-605 END Deactiating Cost split in case the project is late/early development and there is poc milestone*/
					   --and cst.study_id is null --commenting out LE change for: BAY_PROMIS-10

					   --multiplying study rows only
					   --left join (select * from std_c ) std_bgt on std_bgt.project_id=prj.id and std_bgt.id=cst.study_id --commenting out LE change for: BAY_PROMIS-10

					   /*studies from current timeline for non placeholder rows*/
					   left join (select *
								  from std_c) std on plh.code = 0 and std.project_id = prj.id and std.id = cst.study_id

					   /*configuration for status calc*/
					   join configuration cfg on cfg.code = 'STD-MM'

					 where leprj.tag_id = p_tag_id and (leprj.process_id = p_process_id or p_process_id is null) and
						   (leprj.program_id = p_program_id or p_program_id is null) and
						   (cst.study_id is null or std.id is not null) and
						   (cst.function_code is not null or plh.code = 1 or std.placeholder = 1)
				   ) le
			) src
		on (
				trg.process_id = src.process_id
			and trg.project_id = src.project_id
			and nvl(trg.study_id, '-') = nvl(src.study_id, '-')
			and nvl(trg.function_code, '-') = nvl(src.function_code, '-')
			and nvl(trg.subtype_code, '-') = nvl(src.subtype_code, '-')
			and nvl(trg.development_phase_code, '-') = nvl(src.development_phase_code, '-')
		)
		when matched then
			update set
				trg.study_status_code = src.study_status_code,
				trg.study_is_placeholder = src.study_is_placeholder,
				trg.study_is_probing = src.study_is_probing,
				trg.study_is_obligation = src.study_is_obligation,
				trg.study_is_gpdc_approved = src.study_is_gpdc_approved,
				trg.start_date = src.start_date,
				trg.finish_date = src.finish_date,
				trg.poc_date = src.poc_date,
				trg.details = src.details,
				trg.is_upserted = 1--,
				--trg.study_budget_class=src.study_budget_class --commenting out LE change for: BAY_PROMIS-10
			where trg.is_upserted = 0
		when not matched then
			insert
			(
				trg.process_id,
				trg.program_id,
				trg.project_id,
				trg.study_id,
				trg.study_status_code,
				trg.study_is_placeholder,
				trg.study_is_probing,
				trg.study_is_obligation,
				trg.study_is_gpdc_approved,
				trg.function_code,
				trg.subtype_code,
				trg.development_phase_code,
				trg.start_date,
				trg.finish_date,
				trg.poc_date,
				trg.details,
				trg.is_upserted,
				trg.is_placeholder,
				trg.estimate_det_curr_year,
				trg.estimate_det_next_year,
				trg.estimate_prob_curr_year,
				trg.estimate_prob_next_year--,
				--trg.study_budget_class --commenting out LE change for: BAY_PROMIS-10
			)
			values
			(
				src.process_id,
				src.program_id,
				src.project_id,
				src.study_id,
				src.study_status_code,
				src.study_is_placeholder,
				src.study_is_probing,
				src.study_is_obligation,
				src.study_is_gpdc_approved,
				src.function_code,
				src.subtype_code,
				src.development_phase_code,
				src.start_date,
				src.finish_date,
				src.poc_date,
				src.details,
				1,
				src.is_placeholder,
				0,
				0,
				0,
				0--,
				--src.study_budget_class --commenting out LE change for: BAY_PROMIS-10
			);
			v_rowcount := sql%rowcount;
			log_pkg.steps('f' || v_rowcount, v_step_start, v_steps_result);

			--Delete old rows which are not available in new set, skipping placeholder row
			delete from latest_estimate le
			where le.process_id in (
				select lep.id
				from latest_estimates_process lep
				where lep.let_id = p_tag_id
			)
			and (le.process_id = p_process_id or p_process_id is null)
			and (le.program_id = p_program_id or p_program_id is null)
			and le.is_upserted = 0
			;
			v_rowcount := sql%rowcount;
			log_pkg.steps('g' || v_rowcount, v_step_start, v_steps_result);

	  /* Setup costs for non PoC rows */
	  update latest_estimate ll
	  set (details) = (
		select appendchildxml(ll.details, '/details',
							  xmltype('<costs version="">' || (listagg(costs, '')
							  within group (
								order by ndx)) || '</costs>')
		)
		from (
		  select
			le.id,
			decode(iter.ndx, 0, '<current', '<next') || ' forecast="' || get_char_number(max(cst.forecast_number)) ||
			'">' ||
			get_element('act_det', get_char_number(sum(cst.ext_det_act))) ||
			get_element('bgt_det', get_char_number(sum(cst.ext_det_bgt))) ||
			get_element('fct_det', get_char_number(sum(cst.ext_det_fct))) ||
			get_element('rr_det', get_char_number(sum(cst.ext_det_rr))) ||
			get_element('bgt_prob', get_char_number(sum(cst.ext_prob_bgt))) ||
			get_element('fct_prob', get_char_number(sum(cst.ext_prob_fct))) ||
			get_element('cfct_prob', get_char_number(sum(cst.ext_prob_cfct))) ||
			---------------------------------------------------------------------------------
			--PROMISIII-242, Make costs from FPS available for the LE form
			get_element('fps_est_c', get_char_number(sum(cst.fps_est_comm_inc_act))) ||
			get_element('fps_est_u', get_char_number(sum(cst.fps_est_uncomm))) ||
			get_element('fps_est_t', get_char_number(sum(cst.fps_est_total_inc_unspec_y1))) ||
			---------------------------------------------------------------------------------
			decode(iter.ndx, 0, '</current>', '</next>') as costs,
			iter.ndx
		  from latest_estimates_process leproc
			join latest_estimate le on le.process_id = leproc.id
			cross join (select level - 1 ndx
						from dual
						connect by level < 3) iter
			join costs_fps_le_tmp cst on
										cst.project_id = le.project_id
										and cst.month is null
										and cst.year = leproc.year + iter.ndx
										and cst.function_code = le.function_code
										and nvl(cst.study_id, '-') = nvl(le.study_id, '-')
										and (nvl(cst.subtype_code, '-') = nvl(le.subtype_code, '-') or
											 le.study_status_code != 'OTHER')
		  group by le.id, iter.ndx
		)
		where id = ll.id
	  )
	  where ll.process_id in (select lep.id
							  from latest_estimates_process lep
							  where lep.let_id = p_tag_id)
			and (ll.process_id = p_process_id or p_process_id is null)
			and (ll.program_id = p_program_id or p_program_id is null)
			and ll.is_upserted = 1
			and ll.poc_date is null;

	  v_rowcount := sql%rowcount;
	  log_pkg.steps('h' || v_rowcount, v_step_start, v_steps_result);

	  -- Setup ALL costs for PoC rows (later, when enabling BAY_PROMIS-10 here we will have only project cost part)
	  update latest_estimate ll
	  set (details) = (
		select appendchildxml(ll.details, '/details',
							  xmltype(
								  '<costs>' ||
								  '<current forecast="' || get_char_number(max(case when cst.year = le.cy
									then cst.forecast_number
																			   else null end)) || '">' ||
								  get_element('act_det', get_char_number(
									  sum(case when cst.year = le.cy and cst.month between le.cy_sm and le.cy_fm
										then cst.ext_det_act
										  else null end))) ||
								  get_element('bgt_det', get_char_number(
									  sum(case when cst.year = le.cy and cst.month between le.cy_sm and le.cy_fm
										then cst.ext_det_bgt
										  else null end))) ||
								  get_element('fct_det', get_char_number(
									  sum(case when cst.year = le.cy and cst.month between le.cy_sm and le.cy_fm
										then cst.ext_det_fct
										  else null end))) ||
								  get_element('rr_det', get_char_number(
									  sum(case when cst.year = le.cy and cst.month between le.cy_sm and le.cy_fm
										then cst.ext_det_rr
										  else null end))) ||
								  get_element('bgt_prob', get_char_number(
									  sum(case when cst.year = le.cy and cst.month between le.cy_sm and le.cy_fm
										then cst.ext_prob_bgt
										  else null end))) ||
								  get_element('fct_prob', get_char_number(
									  sum(case when cst.year = le.cy and cst.month between le.cy_sm and le.cy_fm
										then cst.ext_prob_fct
										  else null end))) ||
								  get_element('cfct_prob', get_char_number(
									  sum(case when cst.year = le.cy and cst.month between le.cy_sm and le.cy_fm
										then cst.ext_prob_cfct
										  else null end))) ||
								  ---------------------------------------------------------------------------------
								  --PROMISIII-242, Make costs from FPS available for the LE form
								  get_element('fps_est_c', get_char_number(
									  sum(case when cst.year = le.cy and cst.month between le.cy_sm and le.cy_fm
										then cst.fps_est_comm_inc_act
										  else null end))) ||
								  get_element('fps_est_u', get_char_number(
									  sum(case when cst.year = le.cy and cst.month between le.cy_sm and le.cy_fm
										then cst.fps_est_uncomm
										  else null end))) ||
								  get_element('fps_est_t', get_char_number(
									  sum(case when cst.year = le.cy and cst.month between le.cy_sm and le.cy_fm
										then cst.fps_est_total_inc_unspec_y1
										  else null end))) ||
								  ---------------------------------------------------------------------------------
								  '</current>' ||
								  '<next forecast="' || get_char_number(max(case when cst.year = le.ny
									then cst.forecast_number
																			else null end)) || '">' ||
								  get_element('bgt_det', get_char_number(
									  sum(case when cst.year = le.ny and cst.month between le.ny_sm and le.ny_fm
										then cst.ext_det_bgt
										  else null end))) ||
								  get_element('fct_det', get_char_number(
									  sum(case when cst.year = le.ny and cst.month between le.ny_sm and le.ny_fm
										then cst.ext_det_fct
										  else null end))) ||
								  get_element('bgt_prob', get_char_number(
									  sum(case when cst.year = le.ny and cst.month between le.ny_sm and le.ny_fm
										then cst.ext_prob_bgt
										  else null end))) ||
								  get_element('fct_prob', get_char_number(
									  sum(case when cst.year = le.ny and cst.month between le.ny_sm and le.ny_fm
										then cst.ext_prob_fct
										  else null end))) ||
								  get_element('cfct_prob', get_char_number(
									  sum(case when cst.year = le.ny and cst.month between le.ny_sm and le.ny_fm
										then cst.ext_prob_cfct
										  else null end))) ||
								  ---------------------------------------------------------------------------------
								  --PROMISIII-242, Make costs from FPS available for the LE form
								  get_element('fps_est_c', get_char_number(
									  sum(case when cst.year = le.ny and cst.month between le.ny_sm and le.ny_fm
										then cst.fps_est_comm
										  else null end))) ||
								  get_element('fps_est_u', get_char_number(
									  sum(case when cst.year = le.ny and cst.month between le.ny_sm and le.ny_fm
										then cst.fps_est_uncomm
										  else null end))) ||
								  get_element('fps_est_t', get_char_number(
									  sum(case when cst.year = le.ny and cst.month between le.ny_sm and le.ny_fm
										then cst.fps_est_total_inc_unspec_y2
										  else null end))) ||
								  ---------------------------------------------------------------------------------
								  '</next>' ||
								  '</costs>'
							  )
			   ) as details
		from (
			   select
				 l.*,
				 decode(development_phase_code, '0002', 1, decode(py, cy, pm, null))      as cy_sm,
				 decode(py, cy, decode(development_phase_code, '0002', pm - 1, 12),
						decode(development_phase_code, '0002', 12, null))                 as cy_fm,
				 decode(py, cy, decode(development_phase_code, '0005', 1, null),
						decode(development_phase_code, '0005', pm, 1))                    as ny_sm,
				 decode(development_phase_code, '0005', 12, decode(py, ny, pm - 1, null)) as ny_fm
			   from (
					  select
						ll.*,
						lp.year                         as cy,
						lp.year + 1                     as ny,
						extract(year from ll.poc_date)  as py,
						extract(month from ll.poc_date) as pm
					  from latest_estimate ll
						join latest_estimates_process lp on ll.process_id = lp.id
					  --where ll.study_id is null --commenting out LE change for: BAY_PROMIS-10
					) l
			 ) le
		  left join costs_fps_le_tmp cst on
										   cst.project_id = le.project_id
										   and cst.year between le.cy and le.ny
										   and cst.month is not null
										   and cst.function_code = le.function_code
										   and nvl(cst.study_id, '-') = nvl(le.study_id, '-')
										   and (nvl(cst.subtype_code, '-') = nvl(le.subtype_code, '-') or
												le.study_status_code != 'OTHER')
		where ll.id = le.id
		group by le.id
	  )
	  where ll.process_id in (select lep.id
							  from latest_estimates_process lep
							  where lep.let_id = p_tag_id)
			and (ll.process_id = p_process_id or p_process_id is null)
			and (ll.program_id = p_program_id or p_program_id is null)
			and ll.is_upserted = 1
			and ll.poc_date is not null
	  -- and ll.study_id is null --commenting out LE change for: BAY_PROMIS-10
	  ;
		v_rowcount := sql%rowcount;
		log_pkg.steps('i' || v_rowcount, v_step_start, v_steps_result);


		-- Prefill LE
		prefill(v_tag, p_process_id, p_program_id, nvl(v_tag.old_process_id, p_old_process_id));

		-- Restore "upserted" flag to be ready for new LE setup
		update latest_estimate le set
			le.is_upserted = 0,
			le.study_name = extractvalue(le.details, '//study/name'),
			le.study_phase = extractvalue(le.details, '//study/phase'),
			le.study_fpfv = to_date(extractvalue(le.details, '//study/fpfv'), 'yyyy-mm-dd"T"hh24:mi:ss'),
			le.study_lplv = to_date(extractvalue(le.details, '//study/lplv'), 'yyyy-mm-dd"T"hh24:mi:ss'),
			le.curr_forecast = extractvalue(le.details, '//costs/current/@forecast'),
			le.curr_act_det = get_number(extractvalue(le.details, '//costs/current/act_det')), --act_det
			le.curr_bgt_det = get_number(extractvalue(le.details, '//costs/current/bgt_det')), --bgt_det
			le.curr_fct_det = get_number(extractvalue(le.details, '//costs/current/fct_det')), --fct_det
			le.curr_rr_det = get_number(extractvalue(le.details, '//costs/current/rr_det')), --rr_det
			le.curr_bgt_prob = get_number(extractvalue(le.details, '//costs/current/bgt_prob')), --bgt_prob
			le.curr_fct_prob = get_number(extractvalue(le.details, '//costs/current/fct_prob')), --fct_prob
			le.curr_cfct_prob = get_number(extractvalue(le.details, '//costs/current/cfct_prob')), --cfct_prob
			le.curr_fps_est_c = get_number(extractvalue(le.details, '//costs/current/fps_est_c')), --fps_est_c
			le.curr_fps_est_u = get_number(extractvalue(le.details, '//costs/current/fps_est_u')), --fps_est_u
			le.curr_fps_est_t = get_number(extractvalue(le.details, '//costs/current/fps_est_t')), --fps_est_t
			le.next_forecast = extractvalue(le.details, '//costs/next/@forecast'),
			le.next_bgt_det = get_number(extractvalue(le.details, '//costs/next/bgt_det')), --bgt_det
			le.next_fct_det = get_number(extractvalue(le.details, '//costs/next/fct_det')), --fct_det
			le.next_bgt_prob = get_number(extractvalue(le.details, '//costs/next/bgt_prob')), --bgt_prob
			le.next_fct_prob = get_number(extractvalue(le.details, '//costs/next/fct_prob')), --fct_prob
			le.next_cfct_prob = get_number(extractvalue(le.details, '//costs/next/cfct_prob')), --cfct_prob
			le.next_fps_est_c = get_number(extractvalue(le.details, '//costs/next/fps_est_c')), --fps_est_c
			le.next_fps_est_u = get_number(extractvalue(le.details, '//costs/next/fps_est_u')), --fps_est_u
			le.next_fps_est_t = get_number(extractvalue(le.details, '//costs/next/fps_est_t')) --fps_est_t
		where le.process_id in (
			select lep.id
			from latest_estimates_process lep
			where lep.let_id = p_tag_id
		)
		and (le.process_id = p_process_id or p_process_id is null)
		and (le.program_id = p_program_id or p_program_id is null)
		and le.is_upserted = 1
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('j' || v_rowcount, v_step_start, v_steps_result);

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result);

	exception when others then
		notice_pkg.catch(v_where, v_par || ';' || v_steps_result);
		raise;
	end;

  /*************************************************************************/
  procedure submit(p_process_id in nvarchar2, p_program_id in nvarchar2) as
    v_prj             nvarchar2(30);
    v_from            date;
    v_to              date;
    v_where           nvarchar2(222) := 'estimates_pkg.submit';
    v_par             nvarchar2(4000) := 'p_process_id=' || p_process_id || ';p_program_id=' || p_program_id;
    v_step_start      timestamp := systimestamp;
    v_steps_result    nvarchar2(4000);
    v_procedure_start timestamp := systimestamp;

    begin
      log_pkg.steps(null, v_step_start, v_steps_result);
      -- calculate range
      select
        trunc(to_date(year, 'yyyy'), 'year')                                                              as start_date,
        last_day(add_months(trunc(to_date(decode(is_next_year, 1, year + 1, year), 'yyyy'), 'year'), 11)) as finish_date
      into
        v_from,
        v_to
      from latest_estimates_process leproc
      where leproc.id = p_process_id and leproc.is_syncing = 0;

      /* drop old le costs */
      delete from costs
      where
        project_id in (select leprj.project_id
                       from latest_estimates_project_vw leprj
                       where
                         leprj.process_id = p_process_id and (leprj.program_id = p_program_id or p_program_id is null))
        and type_code = 'LE'
        and start_date between v_from and v_to
        and finish_date between v_from and v_to;

      /* insert new rows */
      insert into costs (
        project_id,
        study_id,
        function_code,
        scope_code,
        type_code,
        method_code,
        status_code,
        subtype_code,
        development_phase_code,
        cost,
        start_date,
        finish_date,
        comments)
        select *
        from (
          select
            le.project_id,
            le.study_id,
            le.function_code,
            'EXT'                                                                                as scope_code,
            'LE'                                                                                 as type_code,
            mtd.code                                                                             as method_code,
            le.study_status_code,
            le.subtype_code,
            le.development_phase_code,
            decode(mtd.code, 'DET', decode(yr.ndx, 0, le.estimate_det_curr_year, 1, le.estimate_det_next_year), 'PROB',
                   decode(yr.ndx, 0, le.estimate_prob_curr_year, 1, le.estimate_prob_next_year)) as cost,
            add_months(leproc.start_date, 12 * yr.ndx)                                           as start_date,
            last_day(add_months(add_months(leproc.start_date, 12 * yr.ndx), 11))                 as finish_date,
            decode(yr.ndx, 0, le.comments_curr_year, 1, le.comments_next_year)
          from latest_estimate le
            join (
                   select
                     lp.*,
                     trunc(to_date(year, 'yyyy'), 'year') as start_date
                   from latest_estimates_process lp
                 ) leproc on leproc.id = le.process_id
            cross join calculation_method mtd
            join (select level - 1 as ndx
                  from dual
                  connect by level < 3) yr on leproc.is_next_year >= yr.ndx
          where le.process_id = p_process_id and (le.program_id = p_program_id or p_program_id is null)
        )
        where cost is not null;

      log_pkg.steps('END', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result);

      exception when others then
      notice_pkg.catch(v_where, v_par || ';' || v_steps_result);
      raise;
    end;

  /*************************************************************************/
  procedure starts_bpm_finish
    (
      p_id      in nvarchar2,
      p_payload in xmltype
    )
  as
    l_tag_id          latest_estimates_tag.id%type;
    v_type            nvarchar2(99);
    v_where           nvarchar2(222) := 'estimates_pkg.starts_bpm_finish';
    v_par             nvarchar2(4000) := 'p_id=' || p_id;
    v_step_start      timestamp := systimestamp;
    v_steps_result    nvarchar2(4000);
    v_procedure_start timestamp := systimestamp;

    begin
      log_pkg.steps(null, v_step_start, v_steps_result);

      /* validate result */
      if message_pkg.is_accept(p_payload) = 1
      then
        /* process started, setup data */
        update latest_estimates_process
        set sync_date = sysdate, is_syncing = 0, status_code = 'RUN'
        where id = p_id
        returning let_id into l_tag_id;
        setup(l_tag_id, p_id, null);
        v_type := 'BPM:Started.';
      elsif message_pkg.is_complete(p_payload) = 1
        then
          /* process completed immediatelly afer startup */
          update latest_estimates_process
          set sync_date = sysdate, is_syncing = 0, status_code = 'FIN'
          where id = p_id;
          v_type := 'BPM:Finished.';
      end if;

      log_pkg.steps('END', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result);

      exception when others then
      notice_pkg.catch(v_where, v_par || ';' || v_steps_result);
      raise;
    end;

  /*************************************************************************/
  procedure stop_bpm_finish
    (
      p_id      in nvarchar2,
      p_payload in xmltype
    )
  as
    l_let_id          latest_estimates_tag.id%type;
    v_where           nvarchar2(222) := 'estimates_pkg.stop_bpm_finish';
    v_par             nvarchar2(4000) := 'p_id=' || p_id;
    v_step_start      timestamp := systimestamp;
    v_steps_result    nvarchar2(4000);
    v_procedure_start timestamp := systimestamp;

    begin
      log_pkg.steps(null, v_step_start, v_steps_result);
      /* validate response */
      if message_pkg.is_complete(p_payload) = 0
      then
        return;
      end if;

      /* update data */
      update latest_estimates_process
      set sync_date = sysdate, is_syncing = 0, status_code = 'FIN'
      where id = p_id
      returning let_id into l_let_id;
      update latest_estimates_tag let
      set let.is_meeting_allowed = 1
      where id = l_let_id and let.is_meeting_allowed = 0;

      log_pkg.steps('END', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result);

      exception when others then
      notice_pkg.catch(v_where, v_par || ';' || v_steps_result);
      raise;
    end;

  /*************************************************************************/
  procedure restart_finish
    (
      p_id      in nvarchar2,
      p_payload in xmltype
    )
  as
    v_where           nvarchar2(222) := 'estimates_pkg.restart_finish';
    v_par             nvarchar2(4000) := 'p_id=' || p_id;
    v_step_start      timestamp := systimestamp;
    v_steps_result    nvarchar2(4000);
    v_procedure_start timestamp := systimestamp;

    begin
      log_pkg.steps(null, v_step_start, v_steps_result);
      /* validate response */
      if message_pkg.is_complete(p_payload) = 0
      then
        return;
      end if;

      /* start new process now */
      update latest_estimates_process
      set is_syncing = 0
      where id = p_id;
      starts(p_id);

      log_pkg.steps('END', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result);

      exception when others then
      notice_pkg.catch(v_where, v_par || ';' || v_steps_result);
      raise;
    end;

  /*************************************************************************/
  function get_latest_fc_numbver
    return nvarchar2
  as
  pragma autonomous_transaction;
    v_fc_num nvarchar2(99);
    v_fc_ver nvarchar2(99);
    begin
      begin
        select c.value
        into v_fc_num
        from configuration c
        where c.code = 'LAST-FCT-NUM';
        exception when others then
        v_fc_num := null;
      end;

      begin
        select c.value
        into v_fc_ver
        from configuration c
        where c.code = 'LAST-FCT-VER';
        exception when others then
        v_fc_num := null;
      end;

      return v_fc_num || '_' || v_fc_ver;
    end;

end;
/