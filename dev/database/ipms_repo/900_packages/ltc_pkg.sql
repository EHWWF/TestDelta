create or replace package ltc_pkg as

	/*************************************************************************/
	/*
	*/
	procedure update_all_ltc
	;
	/*************************************************************************/
	/*
	*/
	procedure update_ltc_dim
	(
		p_ltci_id in number,
		p_ltc_process_id in number,
		p_project_id in nvarchar2,
		p_ltc_tag_id in number
	)
	;
	/*************************************************************************/
	/*
	*/
	procedure update_ltc_fte_fct
	(
		p_ltci_id in number,
		p_ltc_process_id in number,
		p_project_id in nvarchar2,
		p_ltc_tag_id in number
	)
	;
	/*************************************************************************/
	/*
	*/
	function get_ltc_diff_count
	(
		p_ltci_id in number, --old LTC id, the one that is already being stored at ipms_repo
		p_ltc_process_id in number, -- old process_id
		p_project_id in nvarchar2
	) return number
	;
	/*************************************************************************/
end;
/
create or replace package body ltc_pkg as

	/*************************************************************************/
	/*
		Procedure is being called as a Sys DB job: COPY_LTC_JOB
	*/
	procedure update_all_ltc
	as
		v_where nvarchar2(222):='ipms_repo.job_pkg.update_all_ltc';
		v_par nvarchar2(4000):='no_par';
		v_rowcount number:=0;
		v_step_start timestamp:=systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:=systimestamp;
		v_msg_out nvarchar2(4000);

	begin
		ipms_data.log_pkg.steps(null,v_step_start,v_steps_result);
		for rr in
			(
				select
					id as ltci_id,
					ltc_process_id,
					project_id,
					ltc_tag_id
				from promis_task
				order by create_date
		) loop
			ipms_repo.ltc_pkg.update_ltc_dim(rr.ltci_id,rr.ltc_process_id,rr.project_id,rr.ltc_tag_id);
			ipms_repo.ltc_pkg.update_ltc_fte_fct(rr.ltci_id,rr.ltc_process_id,rr.project_id,rr.ltc_tag_id);
			delete from promis_task where id=rr.ltci_id;
			v_rowcount:=v_rowcount+1;
		end loop;

		if v_rowcount > 0 then
			v_msg_out:=';'||v_msg_out||';v_rowcount='||v_rowcount;
			ipms_data.log_pkg.steps('END',v_procedure_start,v_steps_result);
			ipms_data.log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);
		end if;

	exception when others then
		ipms_data.log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		ipms_data.log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);
		ipms_data.notice_pkg.catch(v_where,v_par||v_steps_result||v_msg_out);
		--raise;
	end;

	/*************************************************************************/
	/*
		Update LTC/FTE dimension
	*/
	procedure update_ltc_dim
	(
		p_ltci_id in number,
		p_ltc_process_id in number,
		p_project_id in nvarchar2,
		p_ltc_tag_id in number
	)
	as
		v_where nvarchar2(222):='ipms_repo.job_pkg.update_ltc_dim';
		v_par nvarchar2(4000):=
			'p_ltci_id='||p_ltci_id||
			';p_ltc_process_id='||p_ltc_process_id||
			';p_project_id='||p_project_id||
			';p_ltc_tag_id='||p_ltc_tag_id
			;
		v_rowcount number:=0;
		v_count_tab number;
		v_count_view number;
		v_step_start timestamp:=systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:=systimestamp;
		v_msg_out nvarchar2(4000);

	begin
		ipms_data.log_pkg.steps(null,v_step_start,v_steps_result);

		--We shuld use custom based Merge in order not to have record deletion
		merge into cost_ltc_process_dim dest
		using (
			select
				process_id,
				tag_id,
				max(decode (seq, 1, process_name)) process_name,
				max(decode (seq, 1, process_termination_date)) process_termination_date,
				max(decode (seq, 1, process_status_code)) process_status_code,
				max(decode (seq, 1, process_status_date)) process_status_date,
				max(decode (seq, 1, process_comments)) process_comments,
				max(decode (seq, 1, process_create_date)) process_create_date,
				max(decode (seq, 1, process_update_date)) process_update_date,
				max(decode (seq, 1, process_terminate_date)) process_terminate_date,
				max(decode (seq, 1, tag_name)) tag_name,
				max(decode (seq, 1, tag_start_year)) tag_start_year,
				max(decode (seq, 1, tag_submit_report_date)) tag_submit_report_date,
				max(decode (seq, 1, tag_prefil_from_profit_date)) tag_prefil_from_profit_date,
				max(decode (seq, 1, tag_calculate_prob_date)) tag_calculate_prob_date,
				max(decode (seq, 1, forecast_year)) forecast_year,
				max(decode (seq, 1, forecast_month)) forecast_month,
				max(decode (seq, 1, forecast_number)) forecast_number,
				max(decode (seq, 1, forecast_version)) forecast_version,
				max(decode (seq, 1, tag_create_date)) tag_create_date,
				max(decode (seq, 1, tag_update_date)) tag_update_date,
				max(decode (seq, 1, is_frozen)) is_frozen,
				sum(decode (seq, 1, srccnt, dstcnt)) iud,
               max(decode (seq, 1, process_description)) process_description
			from (
				select
					process_id,
					tag_id,
					process_name,
					process_termination_date,
					process_status_code,
					process_status_date,
					process_comments,
					process_create_date,
					process_update_date,
					process_terminate_date,
					tag_name,
					tag_start_year,
					tag_submit_report_date,
					tag_prefil_from_profit_date,
					tag_calculate_prob_date,
					forecast_year,
					forecast_month,
					forecast_number,
					forecast_version,
					tag_create_date,
					tag_update_date,
					is_frozen,
					srccnt,
					dstcnt,
					row_number () over (partition by process_id,tag_id order by dstcnt nulls last) seq,
                    process_description
				from (
					select
						process_id,
						tag_id,
						process_name,
						process_termination_date,
						process_status_code,
						process_status_date,
						process_comments,
						process_create_date,
						process_update_date,
						process_terminate_date,
						tag_name,
						tag_start_year,
						tag_submit_report_date,
						tag_prefil_from_profit_date,
						tag_calculate_prob_date,
						forecast_year,
						forecast_month,
						forecast_number,
						forecast_version,
						tag_create_date,
						tag_update_date,
						is_frozen
						,count (src) srccnt, count (dst) dstcnt,
                        process_description
					from (
						select
							process_id,
							tag_id,
							process_name,
							process_termination_date,
							process_status_code,
							process_status_date,
							process_comments,
							process_create_date,
							process_update_date,
							process_terminate_date,
							tag_name,
							tag_start_year,
							tag_submit_report_date,
							tag_prefil_from_profit_date,
							tag_calculate_prob_date,
							forecast_year,
							forecast_month,
							forecast_number,
							forecast_version,
							tag_create_date,
							tag_update_date,
							is_frozen
							,1 src, to_number (null) dst,
                            process_description
						from cost_ltc_process_dim_vw
						where process_id=nvl(p_ltc_process_id,process_id)
						and tag_id=nvl(p_ltc_tag_id,tag_id)
							union all
						select
							process_id,
							tag_id,
							process_name,
							process_termination_date,
							process_status_code,
							process_status_date,
							process_comments,
							process_create_date,
							process_update_date,
							process_terminate_date,
							tag_name,
							tag_start_year,
							tag_submit_report_date,
							tag_prefil_from_profit_date,
							tag_calculate_prob_date,
							forecast_year,
							forecast_month,
							forecast_number,
							forecast_version,
							tag_create_date,
							tag_update_date,
							is_frozen
							,to_number (null) src, 2 dst,
                            process_description
						from cost_ltc_process_dim
						where process_id=nvl(p_ltc_process_id,process_id)
						and tag_id=nvl(p_ltc_tag_id,tag_id)
					)
					group by
						process_id,
						tag_id,
						process_name,
						process_termination_date,
						process_status_code,
						process_status_date,
						process_comments,
						process_create_date,
						process_update_date,
						process_terminate_date,
						tag_name,
						tag_start_year,
						tag_submit_report_date,
						tag_prefil_from_profit_date,
						tag_calculate_prob_date,
						forecast_year,
						forecast_month,
						forecast_number,
						forecast_version,
						tag_create_date,
						tag_update_date,
						is_frozen,
                        process_description
					having count (src) <> count (dst)
				)
			)
			group by
				process_id,
				tag_id
		) diff
		on (
			dest.process_id=diff.process_id and
			dest.tag_id=diff.tag_id
			)
		when matched then update set
				dest.process_name = diff.process_name
				,dest.process_termination_date = diff.process_termination_date
				,dest.process_status_code = diff.process_status_code
				,dest.process_status_date = diff.process_status_date
				,dest.process_comments = diff.process_comments
				,dest.process_create_date = diff.process_create_date
				,dest.process_update_date = diff.process_update_date
				,dest.process_terminate_date = diff.process_terminate_date
				,dest.tag_name = diff.tag_name
				,dest.tag_start_year = diff.tag_start_year
				,dest.tag_submit_report_date = diff.tag_submit_report_date
				,dest.tag_prefil_from_profit_date = diff.tag_prefil_from_profit_date
				,dest.tag_calculate_prob_date = diff.tag_calculate_prob_date
				,dest.forecast_year = diff.forecast_year
				,dest.forecast_month = diff.forecast_month
				,dest.forecast_number = diff.forecast_number
				,dest.forecast_version = diff.forecast_version
				,dest.tag_create_date = diff.tag_create_date
				,dest.tag_update_date = diff.tag_update_date
				,dest.is_frozen = diff.is_frozen
                ,dest.process_description= diff.process_description
		when not matched then
			 insert
				(
					process_id,
					tag_id,
					process_name,
					process_termination_date,
					process_status_code,
					process_status_date,
					process_comments,
					process_create_date,
					process_update_date,
					process_terminate_date,
					tag_name,
					tag_start_year,
					tag_submit_report_date,
					tag_prefil_from_profit_date,
					tag_calculate_prob_date,
					forecast_year,
					forecast_month,
					forecast_number,
					forecast_version,
					tag_create_date,
					tag_update_date,
					is_frozen,
                    process_description
				)
			 values
				(
					diff.process_id,
					diff.tag_id,
					diff.process_name,
					diff.process_termination_date,
					diff.process_status_code,
					diff.process_status_date,
					diff.process_comments,
					diff.process_create_date,
					diff.process_update_date,
					diff.process_terminate_date,
					diff.tag_name,
					diff.tag_start_year,
					diff.tag_submit_report_date,
					diff.tag_prefil_from_profit_date,
					diff.tag_calculate_prob_date,
					diff.forecast_year,
					diff.forecast_month,
					diff.forecast_number,
					diff.forecast_version,
					diff.tag_create_date,
					diff.tag_update_date,
					diff.is_frozen,
                    diff.process_description
				)
			 ;

		v_rowcount:=sql%rowcount;

		select count(1) into v_count_tab
		from cost_ltc_process_dim
		where process_id=nvl(p_ltc_process_id,process_id)
		and tag_id=nvl(p_ltc_tag_id,tag_id);

		select count(1) into v_count_view
		from cost_ltc_process_dim_vw
		where process_id=nvl(p_ltc_process_id,process_id)
		and tag_id=nvl(p_ltc_tag_id,tag_id);

		if v_count_tab<v_count_view then --it can have less, because we do not delete at ipms_repo
			v_msg_out:='ERROR';
		else
			v_msg_out:='SUCCESS.UPDATED.';
		end if;

		v_msg_out:=';'||v_msg_out||';v_count_view_SRC='||v_count_view||';v_count_tab_DST='||v_count_tab||';v_rowcount='||v_rowcount;

		ipms_data.log_pkg.steps('END',v_procedure_start,v_steps_result);
		ipms_data.log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);

	exception when others then
		ipms_data.log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		ipms_data.log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);
		ipms_data.notice_pkg.catch(v_where,v_par||v_steps_result||v_msg_out);
		--raise;
	end;

	/*************************************************************************/
	/*
		Update LTC/FTE fact table without row deletion
	*/
	procedure update_ltc_fte_fct
	(
		p_ltci_id in number,
		p_ltc_process_id in number,
		p_project_id in nvarchar2,
		p_ltc_tag_id in number
	)
	as
		v_where nvarchar2(222):='ipms_repo.job_pkg.update_ltc_fte_fct';
		v_par nvarchar2(4000):=
			'p_ltci_id='||p_ltci_id||
			';p_ltc_process_id='||p_ltc_process_id||
			';p_project_id='||p_project_id||
			';p_ltc_tag_id='||p_ltc_tag_id
			;
		v_rowcount number:=0;
		v_count_tab number;
		v_count_view number;
		v_step_start timestamp:=systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:=systimestamp;
		v_msg_out nvarchar2(4000);

	begin
		ipms_data.log_pkg.steps(null,v_step_start,v_steps_result);

		merge into cost_ltc_fte_fct dest
		using (
			select
				ltci_id,
				estimate_id,
				period_id,
				max(decode (seq, 1, tag_id)) tag_id,
				max(decode (seq, 1, ltc_process_id)) ltc_process_id,
				max(decode (seq, 1, ltc_year)) ltc_year,
				max(decode (seq, 1, project_id)) project_id,
				max(decode (seq, 1, timeline_id)) timeline_id,
				max(decode (seq, 1, wbs_id)) wbs_id,
				max(decode (seq, 1, study_id)) study_id,
				max(decode (seq, 1, study_name)) study_name,
				max(decode (seq, 1, study_fpfv)) study_fpfv,
				max(decode (seq, 1, study_lplv)) study_lplv,
				max(decode (seq, 1, project_phase_code)) project_phase_code,
				max(decode (seq, 1, function_code)) function_code,
				max(decode (seq, 1, function_name)) function_name,
				max(decode (seq, 1, top_function_name)) top_function_name,
				max(decode (seq, 1, function_cost_rate)) function_cost_rate,
				max(decode (seq, 1, scope_code)) scope_code,
				max(decode (seq, 1, is_external_fte)) is_external_fte,
				max(decode (seq, 1, cost_start_date)) cost_start_date,
				max(decode (seq, 1, cost_finish_date)) cost_finish_date,
				max(decode (seq, 1, project_phase_name)) project_phase_name,
				max(decode (seq, 1, study_phase_code)) study_phase_code,
				max(decode (seq, 1, comments)) comments,
				max(decode (seq, 1, fct_det)) fct_det,
				max(decode (seq, 1, fct_prob)) fct_prob,
				max(decode (seq, 1, ltc_det)) ltc_det,
				max(decode (seq, 1, ltc_prob)) ltc_prob,
				max(decode (seq, 1, fte_calc)) fte_calc,
				--max(decode (seq, 1, estimate_create_date)) estimate_create_date,
				--max(decode (seq, 1, estimate_update_date)) estimate_update_date,
				max(decode (seq, 1, estimate_type_code)) estimate_type_code,
				sum(decode (seq, 1, srccnt, dstcnt)) iud
			from (
				select
					ltci_id,
					estimate_id,
					period_id,
					tag_id,
					ltc_process_id,
					ltc_year,
					project_id,
					timeline_id,
					wbs_id,
					study_id,
					study_name,
					study_fpfv,
					study_lplv,
					project_phase_code,
					function_code,
					function_name,
					top_function_name,
					function_cost_rate,
					scope_code,
					is_external_fte,
					cost_start_date,
					cost_finish_date,
					project_phase_name,
					study_phase_code,
					comments,
					fct_det,
					fct_prob,
					ltc_det,
					ltc_prob,
					fte_calc,
					--estimate_create_date,
					--estimate_update_date,
					estimate_type_code,
					srccnt,
					dstcnt,
					row_number () over (partition by ltci_id,estimate_id,period_id order by dstcnt nulls last) seq
				from (
					select
						ltci_id,
						estimate_id,
						period_id,
						tag_id,
						ltc_process_id,
						ltc_year,
						project_id,
						timeline_id,
						wbs_id,
						study_id,
						study_name,
						study_fpfv,
						study_lplv,
						project_phase_code,
						function_code,
						function_name,
						top_function_name,
						function_cost_rate,
						scope_code,
						is_external_fte,
						cost_start_date,
						cost_finish_date,
						project_phase_name,
						study_phase_code,
						comments,
						fct_det,
						fct_prob,
						ltc_det,
						ltc_prob,
						fte_calc,
						--estimate_create_date,
						--estimate_update_date,
						estimate_type_code
						,count (src) srccnt, count (dst) dstcnt
					from (
						select
							p_ltci_id as ltci_id,
							estimate_id,
							period_id,
							tag_id,
							ltc_process_id,
							ltc_year,
							project_id,
							timeline_id,
							wbs_id,
							study_id,
							study_name,
							study_fpfv,
							study_lplv,
							project_phase_code,
							function_code,
							function_name,
							top_function_name,
							function_cost_rate,
							scope_code,
							is_external_fte,
							cost_start_date,
							cost_finish_date,
							project_phase_name,
							study_phase_code,
							comments,
							fct_det,
							fct_prob,
							ltc_det,
							ltc_prob,
							fte_calc,
							--estimate_create_date,
							--estimate_update_date,
							estimate_type_code
							,1 src, to_number (null) dst
						from cost_ltc_fte_fct_vw --TODO: maybe should be used FlashBack ???, thus here should be the whole VIEW extracted !!
						where ltc_process_id=nvl(p_ltc_process_id,ltc_process_id)
						and tag_id=nvl(p_ltc_tag_id,tag_id)
						--and ltci_id=nvl(p_ltci_id,ltci_id)
						and project_id=nvl(p_project_id,project_id)
							union all
						select
							ltci_id,
							estimate_id,
							period_id,
							tag_id,
							ltc_process_id,
							ltc_year,
							project_id,
							timeline_id,
							wbs_id,
							study_id,
							study_name,
							study_fpfv,
							study_lplv,
							project_phase_code,
							function_code,
							function_name,
							top_function_name,
							function_cost_rate,
							scope_code,
							is_external_fte,
							cost_start_date,
							cost_finish_date,
							project_phase_name,
							study_phase_code,
							comments,
							fct_det,
							fct_prob,
							ltc_det,
							ltc_prob,
							fte_calc,
							--estimate_create_date,
							--estimate_update_date,
							estimate_type_code
							,to_number (null) src, 2 dst
						from cost_ltc_fte_fct
						where ltc_process_id=nvl(p_ltc_process_id,ltc_process_id)
						and tag_id=nvl(p_ltc_tag_id,tag_id)
						and ltci_id=nvl(p_ltci_id,ltci_id)
						and project_id=nvl(p_project_id,project_id)
					)
					group by
							ltci_id,
							estimate_id,
							period_id,
							tag_id,
							ltc_process_id,
							ltc_year,
							project_id,
							timeline_id,
							wbs_id,
							study_id,
							study_name,
							study_fpfv,
							study_lplv,
							project_phase_code,
							function_code,
							function_name,
							top_function_name,
							function_cost_rate,
							scope_code,
							is_external_fte,
							cost_start_date,
							cost_finish_date,
							project_phase_name,
							study_phase_code,
							comments,
							fct_det,
							fct_prob,
							ltc_det,
							ltc_prob,
							fte_calc,
							--estimate_create_date,
							--estimate_update_date,
							estimate_type_code
					having count (src) <> count (dst)
				)
			)
			group by
				ltci_id,
				estimate_id,
				period_id
		) diff
		on (
			dest.ltci_id=diff.ltci_id and
			dest.estimate_id=diff.estimate_id and
			dest.period_id=diff.period_id
			)
		when matched then update set
				dest.tag_id = diff.tag_id
				,dest.ltc_process_id = diff.ltc_process_id
				,dest.ltc_year = diff.ltc_year
				,dest.project_id = diff.project_id
				,dest.timeline_id = diff.timeline_id
				,dest.wbs_id = diff.wbs_id
				,dest.study_id = diff.study_id
				,dest.study_name = diff.study_name
				,dest.study_fpfv = diff.study_fpfv
				,dest.study_lplv = diff.study_lplv
				,dest.project_phase_code = diff.project_phase_code
				,dest.function_code = diff.function_code
				,dest.function_name = diff.function_name
				,dest.top_function_name = diff.top_function_name
				,dest.function_cost_rate = diff.function_cost_rate
				,dest.scope_code = diff.scope_code
				,dest.is_external_fte = diff.is_external_fte
				,dest.cost_start_date = diff.cost_start_date
				,dest.cost_finish_date = diff.cost_finish_date
				,dest.project_phase_name = diff.project_phase_name
				,dest.study_phase_code = diff.study_phase_code
				,dest.comments = diff.comments
				,dest.fct_det = diff.fct_det
				,dest.fct_prob = diff.fct_prob
				,dest.ltc_det = diff.ltc_det
				,dest.ltc_prob = diff.ltc_prob
				,dest.fte_calc = diff.fte_calc
				--,dest.estimate_create_date = diff.estimate_create_date
				,dest.estimate_type_code = diff.estimate_type_code
		when not matched then
			 insert
				(
					ltci_id,
					estimate_id,
					period_id,
					tag_id,
					ltc_process_id,
					ltc_year,
					project_id,
					timeline_id,
					wbs_id,
					study_id,
					study_name,
					study_fpfv,
					study_lplv,
					project_phase_code,
					function_code,
					function_name,
					top_function_name,
					function_cost_rate,
					scope_code,
					is_external_fte,
					cost_start_date,
					cost_finish_date,
					project_phase_name,
					study_phase_code,
					comments,
					fct_det,
					fct_prob,
					ltc_det,
					ltc_prob,
					fte_calc,
					--estimate_create_date,
					--estimate_update_date,
					estimate_type_code
				)
			 values
				(
					diff.ltci_id,
					diff.estimate_id,
					diff.period_id,
					diff.tag_id,
					diff.ltc_process_id,
					diff.ltc_year,
					diff.project_id,
					diff.timeline_id,
					diff.wbs_id,
					diff.study_id,
					diff.study_name,
					diff.study_fpfv,
					diff.study_lplv,
					diff.project_phase_code,
					diff.function_code,
					diff.function_name,
					diff.top_function_name,
					diff.function_cost_rate,
					diff.scope_code,
					diff.is_external_fte,
					diff.cost_start_date,
					diff.cost_finish_date,
					diff.project_phase_name,
					diff.study_phase_code,
					diff.comments,
					diff.fct_det,
					diff.fct_prob,
					diff.ltc_det,
					diff.ltc_prob,
					diff.fte_calc,
					--diff.estimate_create_date,
					--diff.estimate_update_date,
					diff.estimate_type_code
				)
			 ;

		v_rowcount:=sql%rowcount;

		select count(1) into v_count_tab
		from cost_ltc_fte_fct
		where ltc_process_id=nvl(p_ltc_process_id,ltc_process_id)
		and tag_id=nvl(p_ltc_tag_id,tag_id)
		and ltci_id=nvl(p_ltci_id,ltci_id)
		and project_id=nvl(p_project_id,project_id);

		select count(1) into v_count_view
		from cost_ltc_fte_fct_vw
		where ltc_process_id=nvl(p_ltc_process_id,ltc_process_id)
		and tag_id=nvl(p_ltc_tag_id,tag_id)
		--and ltci_id=nvl(p_ltci_id,ltci_id)
		and project_id=nvl(p_project_id,project_id);

		if v_count_tab<v_count_view then
			v_msg_out:='ERROR';
		else
			v_msg_out:='SUCCESS.UPDATED.';
		end if;

		v_msg_out:=';'||v_msg_out||';v_count_view_SRC='||v_count_view||';v_count_tab_DST='||v_count_tab||';v_rowcount='||v_rowcount;

		ipms_data.log_pkg.steps('END',v_procedure_start,v_steps_result);
		ipms_data.log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);

	exception when others then
		ipms_data.log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		ipms_data.log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);
		ipms_data.notice_pkg.catch(v_where,v_par||v_steps_result||v_msg_out);
		--raise;
	end;

	/*************************************************************************/
	/*
		Function is needed just for making decision if reort submision is needed at all
	*/
	function get_ltc_diff_count
	(
		p_ltci_id in number, --old LTC id, the one that is already being stored at ipms_repo
		p_ltc_process_id in number, -- old process_id
		p_project_id in nvarchar2
	) return number
	as
		v_rowcount number:=0;

	begin
		if p_ltci_id is null then
			return 1;
		else
			select max(ltci_id) into v_rowcount
			from cost_ltc_fte_fct
			where project_id=p_project_id
			;

			if v_rowcount = p_ltci_id then --only then we have the same rocord set for the same ID else return max(ltci_id) that means the row set is diff

				select count(1) into v_rowcount from (
							select
								ltci_id,
								estimate_id,
								period_id,
								sum(decode (seq, 1, srccnt, dstcnt)) iud
							from (
								select
									ltci_id,
									estimate_id,
									period_id,
									tag_id,
									ltc_process_id,
									ltc_year,
									project_id,
									timeline_id,
									wbs_id,
									study_id,
									study_name,
									study_fpfv,
									study_lplv,
									project_phase_code,
									function_code,
									function_name,
									top_function_name,
									function_cost_rate,
									scope_code,
									is_external_fte,
									cost_start_date,
									cost_finish_date,
									project_phase_name,
									study_phase_code,
									comments,
									fct_det,
									fct_prob,
									ltc_det,
									ltc_prob,
									fte_calc,
									--estimate_create_date,
									--estimate_update_date,
									srccnt,
									dstcnt,
									row_number () over (partition by ltci_id,estimate_id,period_id order by dstcnt nulls last) seq
								from (
									select
										ltci_id,
										estimate_id,
										period_id,
										tag_id,
										ltc_process_id,
										ltc_year,
										project_id,
										timeline_id,
										wbs_id,
										study_id,
										study_name,
										study_fpfv,
										study_lplv,
										project_phase_code,
										function_code,
										function_name,
										top_function_name,
										function_cost_rate,
										scope_code,
										is_external_fte,
										cost_start_date,
										cost_finish_date,
										project_phase_name,
										study_phase_code,
										comments,
										fct_det,
										fct_prob,
										ltc_det,
										ltc_prob,
										fte_calc,
										--estimate_create_date,
										--estimate_update_date,
										count (src) srccnt,
										count (dst) dstcnt
									from (
										select
											p_ltci_id as ltci_id,
											estimate_id,
											period_id,
											tag_id,
											ltc_process_id,
											ltc_year,
											project_id,
											timeline_id,
											wbs_id,
											study_id,
											study_name,
											study_fpfv,
											study_lplv,
											project_phase_code,
											function_code,
											function_name,
											top_function_name,
											function_cost_rate,
											scope_code,
											is_external_fte,
											cost_start_date,
											cost_finish_date,
											project_phase_name,
											study_phase_code,
											comments,
											fct_det,
											fct_prob,
											ltc_det,
											ltc_prob,
											fte_calc,
											--estimate_create_date,
											--estimate_update_date,
											1 src,
											to_number (null) dst
										from cost_ltc_fte_fct_vw
										where ltc_process_id=p_ltc_process_id
										and project_id=p_project_id
											union all
										select
											ltci_id,
											estimate_id,
											period_id,
											tag_id,
											ltc_process_id,
											ltc_year,
											project_id,
											timeline_id,
											wbs_id,
											study_id,
											study_name,
											study_fpfv,
											study_lplv,
											project_phase_code,
											function_code,
											function_name,
											top_function_name,
											function_cost_rate,
											scope_code,
											is_external_fte,
											cost_start_date,
											cost_finish_date,
											project_phase_name,
											study_phase_code,
											comments,
											fct_det,
											fct_prob,
											ltc_det,
											ltc_prob,
											fte_calc,
											--estimate_create_date,
											--estimate_update_date,
											to_number (null) src,
											2 dst
										from cost_ltc_fte_fct
										where ltci_id=p_ltci_id
										and ltc_process_id=p_ltc_process_id
										and project_id=p_project_id
									)
									group by
											ltci_id,
											estimate_id,
											period_id,
											tag_id,
											ltc_process_id,
											ltc_year,
											project_id,
											timeline_id,
											wbs_id,
											study_id,
											study_name,
											study_fpfv,
											study_lplv,
											project_phase_code,
											function_code,
											function_name,
											top_function_name,
											function_cost_rate,
											scope_code,
											is_external_fte,
											cost_start_date,
											cost_finish_date,
											project_phase_name,
											study_phase_code,
											comments,
											fct_det,
											fct_prob,
											ltc_det,
											ltc_prob,
											fte_calc--,
											--estimate_create_date,
											--estimate_update_date
									having count (src) <> count (dst)
								)
							)
							group by
								ltci_id,
								estimate_id,
								period_id
				)
				;
			end if;

			return v_rowcount;
		end if;
	end;
end;