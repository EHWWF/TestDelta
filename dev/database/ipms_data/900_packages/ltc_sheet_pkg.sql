create or replace package ltc_sheet_pkg
as
	/*************************************************************************/
	/*
	Prefills LTC deterministic costs from profit.
	Data processing granularity depends on provided parameters.
	*/
	procedure prefill
	(
		p_ltc_tag_id in ltc_tag.id%type,
		p_ltc_process_id in ltc_process.id%type default null,
		p_ltc_program_id in program.id%type default null,
		p_ltc_project_id in project.id%type default null,
		p_is_manual_action in number default 1
	)
	;
	/*************************************************************************/
	/*
	Prefills LTC deterministic costs from FPS.
	Data processing granularity depends on provided parameters.
	Procedure is invoked externally on demand.
	*/
	procedure prefill_fps
	(
		p_ltc_tag_id in ltc_tag.id%type,
		p_ltc_process_id in ltc_process.id%type default null,
		p_ltc_program_id in program.id%type default null,
		p_ltc_project_id in project.id%type default null,
		p_is_manual_action in number default 0 --UI manual action to prefill one more time from FPS. 0 - means do not prefil for the second time
	)
	;
	/*************************************************************************/
	/*
	Prefills LTC deterministic costs from profit and from FPS
	Data processing granularity depends on provided parameters.
	Manual action initiated from UI
	*/
	procedure prefill_all
	(
		p_ltc_tag_id in ltc_tag.id%type,
		p_ltc_process_id in ltc_process.id%type default null,
		p_ltc_program_id in program.id%type default null,
		p_ltc_project_id in project.id%type default null,
		p_is_manual_action in number default 1
	)
	;
	/*************************************************************************/
	/*
	Recalculates LTC cost availability depending on RAW plan data.
	Data processing granularity depends on provided parameters.
	*/
	procedure recalculate
	(
		p_ltc_tag_id in ltc_tag.id%type,
		p_ltc_process_id in ltc_process.id%type default null,
		p_ltc_program_id in program.id%type default null,
		p_ltc_project_id in project.id%type default null,
		p_ltc_type_code in ltc_estimate.type_code%type default null
	)
	;
	/*************************************************************************/
	/*
	Setup LTC table rows. Procedure is invoked before load data into excel.
	Data processing granularity depends on provided parameters.
	*/
	procedure setup
	(
		p_ltc_tag_id in ltc_tag.id%type,
		p_ltc_process_id in ltc_process.id%type default null,
		p_ltc_program_id in program.id%type default null,
		p_ltc_project_id in project.id%type default null,
		p_ltc_type_code in ltc_estimate.type_code%type default null
	)
	;
	/*************************************************************************/
	/*
	*/
	function check_cost_range
	(
		p_start_date in date,
		p_end_date in date,
		p_year in number,
		p_cost in number
	)
	return number
	;
	/*************************************************************************/
	/*
	*/
	function check_profit_prefill_value
	(
		p_year in number,
		p_start_year in number,
		p_plus_year in number,
		p_cost in number,
		p_number_of_profit_years in number
	)
	return number
	;
	/*************************************************************************/
	/*
	*/
	function check_fps_prefill_value
	(
		p_year in number,
		p_start_year in number,
		p_plus_year in number,
		p_cost in number,
		p_number_of_profit_years in number
	)
	return number
	;
	/*************************************************************************/
	/*
	*/
	function check_profit_update_value
	(
		p_lt_y_cost in number,
		p_y_cost in number,
		p_fct_y_cost in number,
		p_plus_year in number,
		p_number_of_profit_years in number
	)
	return number
	;
	/*************************************************************************/
	/*
	*/
	function check_if_fps_update
	(
		p_old_cost in number,
		p_new_cost in number,
		p_plus_year in number,
		p_number_of_profit_years in number
	)
	return number
	;
	/*************************************************************************/
end;
/
create or replace package body ltc_sheet_pkg
as
	/*************************************************************************/
	/*
	*/
	function check_profit_update_value
	(
		p_lt_y_cost in number,
		p_y_cost in number,
		p_fct_y_cost in number,
		p_plus_year in number,
		p_number_of_profit_years in number
	)
	return number
	as
	begin
		--case when lt_y1_cost is null and src.y1_cost is null then null else  nvl(src.y1_cost, 0) + nvl(lt_y1_cost,0) - nvl(fct_y1_cost, 0) end
		--if the year must be taken from Profit then calculate it, else return original value
		if p_plus_year < p_number_of_profit_years then
			if p_lt_y_cost is null and p_y_cost is null then 
				return null;
			else
				return nvl(p_y_cost, 0) + nvl(p_lt_y_cost,0) - nvl(p_fct_y_cost, 0);
			end if;
		else
			return p_lt_y_cost;
		end if;
	end;

	/*************************************************************************/
	/*
	*/
	function check_profit_prefill_value
	(
		p_year in number,
		p_start_year in number,
		p_plus_year in number,
		p_cost in number,
		p_number_of_profit_years in number
	)
	return number
	as
	begin
		if p_plus_year < p_number_of_profit_years then
			if p_year = p_start_year + p_plus_year then
				return p_cost;
			else
				return null;
			end if;
		else
			return null;
		end if;
	end;

	/*************************************************************************/
	/*
	*/
	function check_fps_prefill_value
	(
		p_year in number,
		p_start_year in number,
		p_plus_year in number,
		p_cost in number,
		p_number_of_profit_years in number
	)
	return number
	as
	begin
		if p_plus_year >= p_number_of_profit_years then
			if p_year = p_start_year + p_plus_year then
				return p_cost;
			else
				return null;
			end if;
		else
			return null;
		end if;
	end;

	/*************************************************************************/
	/*
	*/
	function check_if_fps_update
	(
		p_old_cost in number,
		p_new_cost in number,
		p_plus_year in number,
		p_number_of_profit_years in number
	)
	return number
	as
	begin
		if p_plus_year >= p_number_of_profit_years then
			return p_new_cost;
		else
			return p_old_cost; --do not update, or update to the same value
		end if;
	end;

	/*************************************************************************/
	/*
	* validate if the cost in the expected range, else return null
	*/
	function check_cost_range
	(
		p_start_date in date,
		p_end_date in date,
		p_year in number,
		p_cost in number
	)
	return number
	as
	begin
		if 
			nvl(to_number(to_char(p_start_date, 'yyyy')), 0) <= p_year
			and
			nvl(to_number(to_char(p_end_date, 'yyyy')), 9999) >= p_year
		then
			return p_cost;
		else
			return null;
		end if;
	end;

	/*************************************************************************/
	/*
	*/
	procedure prefill
	(
		p_ltc_tag_id in ltc_tag.id%type,
		p_ltc_process_id in ltc_process.id%type default null,
		p_ltc_program_id in program.id%type default null,
		p_ltc_project_id in project.id%type default null,
		p_is_manual_action in number default 1
	)
	as
		v_where nvarchar2(222) := 'ltc_sheet_pkg.prefill';
		v_par nvarchar2(4000) := 'p_ltc_tag_id=' || p_ltc_tag_id ||
								';p_ltc_process_id=' || p_ltc_process_id ||
								';p_ltc_program_id=' || p_ltc_program_id ||
								';p_ltc_project_id=' || p_ltc_project_id ||
								';p_is_manual_action=' || p_is_manual_action;
		v_rowcount number := 0;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);
		v_ltc_start_year ltc_tag.start_year%type;
		v_ltc_tag_id number;
		v_user_id nvarchar2(55) := 'TODO_PROCEDURE';
		v_number_of_profit_years number;

	begin
		log_pkg.steps(null, v_step_start, v_steps_result);
		
		select start_year, number_of_profit_years
		into v_ltc_start_year, v_number_of_profit_years
		from ltc_tag ltct
		where ltct.id = p_ltc_tag_id;
		
		v_msg_out := v_msg_out || ';v_ltc_start_year=' || v_ltc_start_year ||';v_number_of_profit_years='||v_number_of_profit_years;
		v_par := v_par || ';v_ltc_start_year=' || v_ltc_start_year ||';v_number_of_profit_years='||v_number_of_profit_years;
		------------------------------------------------------------------------
		-- Delete old discrepancies
		delete from ltc_estimate
		where ltc_project_id in (
			select ltcprj.id
			from ltc_project ltcprj
			join project prj on prj.id = ltcprj.project_id
			join ltc_process ltcprc on ltcprc.id = ltcprj.ltc_process_id and ltcprc.ltc_tag_id = p_ltc_tag_id
			where nvl(p_ltc_process_id, ltcprc.id) = ltcprc.id
			and nvl(p_ltc_program_id, prj.program_id) = prj.program_id
			and nvl(p_ltc_project_id, ltcprj.project_id) = ltcprj.project_id
		)
		and is_discrepancy_profit = 1
		and type_code = 'LTC';
		
		v_rowcount := sql%rowcount;
		log_pkg.steps('a' || v_rowcount, v_step_start, v_steps_result);

      ------------------------------------------------------------------------
      --Assumption - all records are discrepancies unless they have a match from profit (subsequent statement)
		update ltc_estimate set is_discrepancy_profit = 1
		where is_manual = 0
		and p_is_manual_action = 1
		and base_cost_source = 'PROFIT'
		and type_code = 'LTC'
		and ltc_project_id in (
			select ltcprj.id
			from ltc_project ltcprj
			join project prj on prj.id = ltcprj.project_id
			join ltc_process ltcprc on ltcprc.id = ltcprj.ltc_process_id and ltcprc.ltc_tag_id = p_ltc_tag_id
			where nvl(p_ltc_process_id, ltcprc.id) = ltcprc.id
			and nvl(p_ltc_program_id, prj.program_id) = prj.program_id
			and nvl(p_ltc_project_id, ltcprj.project_id) = ltcprj.project_id
		);
		
		v_rowcount := sql%rowcount;
		log_pkg.steps('b' || v_rowcount, v_step_start, v_steps_result);
		------------------------------------------------------------------------
		--Update/insert records, that have match in PROFIT. Mark them as NOT discrepancy.
		merge into ltc_estimate dst
		using (
			select
				'LTC' type_code,
				ltc_project_id,
				study_id,
				study_phase_code,
				study_name,
				study_fpfv,
				study_lplv,
				function_code,
				function_name,
				top_function_name,
				is_external_fte,
				scope_code,
				project_phase_code,
				project_phase_name,
				project_phase_ordering,
				--timeline_id,
				--wbs_id,
				sum(check_profit_prefill_value(year,v_ltc_start_year,0,cost,v_number_of_profit_years)) y1_cost,
				sum(check_profit_prefill_value(year,v_ltc_start_year,1,cost,v_number_of_profit_years)) y2_cost,
				sum(check_profit_prefill_value(year,v_ltc_start_year,2,cost,v_number_of_profit_years)) y3_cost,
				sum(check_profit_prefill_value(year,v_ltc_start_year,3,cost,v_number_of_profit_years)) y4_cost,
				sum(check_profit_prefill_value(year,v_ltc_start_year,4,cost,v_number_of_profit_years)) y5_cost,
				sum(check_profit_prefill_value(year,v_ltc_start_year,5,cost,v_number_of_profit_years)) y6_cost,
				sum(check_profit_prefill_value(year,v_ltc_start_year,6,cost,v_number_of_profit_years)) y7_cost,
				sum(check_profit_prefill_value(year,v_ltc_start_year,7,cost,v_number_of_profit_years)) y8_cost,
				sum(check_profit_prefill_value(year,v_ltc_start_year,8,cost,v_number_of_profit_years)) y9_cost,
				sum(check_profit_prefill_value(year,v_ltc_start_year,9,cost,v_number_of_profit_years)) y10_cost,
				sum(check_profit_prefill_value(year,v_ltc_start_year,10,cost,v_number_of_profit_years)) y11_cost,
				sum(check_profit_prefill_value(year,v_ltc_start_year,11,cost,v_number_of_profit_years)) y12_cost,
				sum(check_profit_prefill_value(year,v_ltc_start_year,12,cost,v_number_of_profit_years)) y13_cost,
				sum(check_profit_prefill_value(year,v_ltc_start_year,13,cost,v_number_of_profit_years)) y14_cost,
				sum(check_profit_prefill_value(year,v_ltc_start_year,14,cost,v_number_of_profit_years)) y15_cost,
				--sum(decode(year, v_ltc_start_year, cost, null)) y1_cost,
				--sum(decode(year, v_ltc_start_year + 1, cost, null)) y2_cost,
				--sum(decode(year, v_ltc_start_year + 2, cost, null)) y3_cost,
				min(cost_start_date) cost_start_date,
				max(cost_finish_date) cost_finsih_date
			from ltc_imp_costs_vw
			where nvl(p_ltc_tag_id, ltc_tag_id) = ltc_tag_id
			and nvl(p_ltc_process_id, ltc_process_id) = ltc_process_id
			and nvl(p_ltc_program_id, program_id) = program_id
			and nvl(p_ltc_project_id, project_id) = project_id
			and decode(p_is_manual_action, 0, is_initially_prefiled, 0) = 0 --means it was never prefilled
			group by
				ltc_project_id,
				study_id,
				function_code,
				is_external_fte,
				scope_code,
				project_phase_code,
				project_phase_name,
				project_phase_ordering,
				--timeline_id,
				--wbs_id,
				study_phase_code,
				study_name,
				study_fpfv,
				study_lplv,
				top_function_name,
				function_name
			having
				( --at least one value must be not null in order to get the whole line/record
					sum(check_profit_prefill_value(year,v_ltc_start_year,0,cost,v_number_of_profit_years))||
					sum(check_profit_prefill_value(year,v_ltc_start_year,1,cost,v_number_of_profit_years))||
					sum(check_profit_prefill_value(year,v_ltc_start_year,2,cost,v_number_of_profit_years))||
					sum(check_profit_prefill_value(year,v_ltc_start_year,3,cost,v_number_of_profit_years))||
					sum(check_profit_prefill_value(year,v_ltc_start_year,4,cost,v_number_of_profit_years))||
					sum(check_profit_prefill_value(year,v_ltc_start_year,5,cost,v_number_of_profit_years))||
					sum(check_profit_prefill_value(year,v_ltc_start_year,6,cost,v_number_of_profit_years))||
					sum(check_profit_prefill_value(year,v_ltc_start_year,7,cost,v_number_of_profit_years))||
					sum(check_profit_prefill_value(year,v_ltc_start_year,8,cost,v_number_of_profit_years))||
					sum(check_profit_prefill_value(year,v_ltc_start_year,9,cost,v_number_of_profit_years))||
					sum(check_profit_prefill_value(year,v_ltc_start_year,10,cost,v_number_of_profit_years))||
					sum(check_profit_prefill_value(year,v_ltc_start_year,11,cost,v_number_of_profit_years))||
					sum(check_profit_prefill_value(year,v_ltc_start_year,12,cost,v_number_of_profit_years))||
					sum(check_profit_prefill_value(year,v_ltc_start_year,13,cost,v_number_of_profit_years))||
					sum(check_profit_prefill_value(year,v_ltc_start_year,14,cost,v_number_of_profit_years))
				) is not null
			) src
		on (
			src.ltc_project_id = dst.ltc_project_id
		and nvl(src.study_id, -1) = nvl(dst.study_id, -1)
		and src.function_code = dst.function_code
		and src.is_external_fte = dst.is_external_fte
		and src.scope_code = dst.scope_code
		and src.project_phase_code = dst.project_phase_code
		and src.type_code = dst.type_code
		)
		when not matched then
			insert (
				ltc_project_id,
				study_id,
				function_code,
				is_external_fte,
				scope_code,
				project_phase_code,
				cost_start_date,
				cost_finish_date,
				is_manual,
				lt_y1_cost,
				lt_y2_cost,
				lt_y3_cost,
				lt_y4_cost,
				lt_y5_cost,
				lt_y6_cost,
				lt_y7_cost,
				lt_y8_cost,
				lt_y9_cost,
				lt_y10_cost,
				lt_y11_cost,
				lt_y12_cost,
				lt_y13_cost,
				lt_y14_cost,
				lt_y15_cost,

				fct_y1_cost,
				fct_y2_cost,
				fct_y3_cost,
				fct_y4_cost,
				fct_y5_cost,
				fct_y6_cost,
				fct_y7_cost,
				fct_y8_cost,
				fct_y9_cost,
				fct_y10_cost,
				fct_y11_cost,
				fct_y12_cost,
				fct_y13_cost,
				fct_y14_cost,
				fct_y15_cost,
				study_name,
				study_phase_code,
				study_fpfv,
				study_lplv,
				top_function_name,
				function_name,
				project_phase_name,
				project_phase_ordering,
				type_code,
				base_cost_source
				--, timeline_id, wbs_id
			)
			values (
				src.ltc_project_id,
				src.study_id,
				src.function_code,
				src.is_external_fte,
				src.scope_code,
				src.project_phase_code,
				src.cost_start_date,
				src.cost_finsih_date,
				0,
				--it is an Insert, thus, take as much as needed from Profit
				--and isert for all year for both cost types
				--the same value
				src.y1_cost,
				src.y2_cost,
				src.y3_cost,
				src.y4_cost,
				src.y5_cost,
				src.y6_cost,
				src.y7_cost,
				src.y8_cost,
				src.y9_cost,
				src.y10_cost,
				src.y11_cost,
				src.y12_cost,
				src.y13_cost,
				src.y14_cost,
				src.y15_cost,

				src.y1_cost,
				src.y2_cost,
				src.y3_cost,
				src.y4_cost,
				src.y5_cost,
				src.y6_cost,
				src.y7_cost,
				src.y8_cost,
				src.y9_cost,
				src.y10_cost,
				src.y11_cost,
				src.y12_cost,
				src.y13_cost,
				src.y14_cost,
				src.y15_cost,
				src.study_name,
				src.study_phase_code,
				src.study_fpfv,
				src.study_lplv,
				src.top_function_name,
				src.function_name,
				src.project_phase_name,
				src.project_phase_ordering,
				'LTC',
				'PROFIT'
				--, src.timeline_id, src.wbs_id
			)
			when matched then
				update set
					--before updating validate if for that year value is taken from Profit or from FPS
					--if from Profit then Update else leave original value
					lt_y1_cost = check_profit_update_value(lt_y1_cost,src.y1_cost,fct_y1_cost,0,v_number_of_profit_years),
					lt_y2_cost = check_profit_update_value(lt_y2_cost,src.y2_cost,fct_y2_cost,1,v_number_of_profit_years),
					lt_y3_cost = check_profit_update_value(lt_y3_cost,src.y3_cost,fct_y3_cost,2,v_number_of_profit_years),
					lt_y4_cost = check_profit_update_value(lt_y4_cost,src.y3_cost,fct_y4_cost,3,v_number_of_profit_years),
					lt_y5_cost = check_profit_update_value(lt_y5_cost,src.y3_cost,fct_y5_cost,4,v_number_of_profit_years),
					lt_y6_cost = check_profit_update_value(lt_y6_cost,src.y3_cost,fct_y6_cost,5,v_number_of_profit_years),
					lt_y7_cost = check_profit_update_value(lt_y7_cost,src.y3_cost,fct_y7_cost,6,v_number_of_profit_years),
					lt_y8_cost = check_profit_update_value(lt_y8_cost,src.y3_cost,fct_y8_cost,7,v_number_of_profit_years),
					lt_y9_cost = check_profit_update_value(lt_y9_cost,src.y3_cost,fct_y9_cost,8,v_number_of_profit_years),
					lt_y10_cost = check_profit_update_value(lt_y10_cost,src.y3_cost,fct_y10_cost,9,v_number_of_profit_years),
					lt_y11_cost = check_profit_update_value(lt_y11_cost,src.y3_cost,fct_y11_cost,10,v_number_of_profit_years),
					lt_y12_cost = check_profit_update_value(lt_y12_cost,src.y3_cost,fct_y12_cost,11,v_number_of_profit_years),
					lt_y13_cost = check_profit_update_value(lt_y13_cost,src.y3_cost,fct_y13_cost,12,v_number_of_profit_years),
					lt_y14_cost = check_profit_update_value(lt_y14_cost,src.y3_cost,fct_y14_cost,13,v_number_of_profit_years),
					lt_y15_cost = check_profit_update_value(lt_y15_cost,src.y3_cost,fct_y15_cost,14,v_number_of_profit_years),
					--get values for all 15 Profit years, in case if not imported then result will be null
					fct_y1_cost = src.y1_cost,
					fct_y2_cost = src.y2_cost,
					fct_y3_cost = src.y3_cost,
					fct_y4_cost = src.y4_cost,
					fct_y5_cost = src.y5_cost,
					fct_y6_cost = src.y6_cost,
					fct_y7_cost = src.y7_cost,
					fct_y8_cost = src.y8_cost,
					fct_y9_cost = src.y9_cost,
					fct_y10_cost = src.y10_cost,
					fct_y11_cost = src.y11_cost,
					fct_y12_cost = src.y12_cost,
					fct_y13_cost = src.y13_cost,
					fct_y14_cost = src.y14_cost,
					fct_y15_cost = src.y15_cost,
					is_discrepancy_profit = 0,
					cost_start_date = src.cost_start_date,
					cost_finish_date = src.cost_finsih_date,
					is_manual = 0,
					base_cost_source = 'PROFIT'
			;

		------------------------------------------------------------------------
		v_rowcount := sql%rowcount;
		log_pkg.steps('c' || v_rowcount, v_step_start, v_steps_result);

		------------------------------------------------------------------------
		--Update only one field - Forecast Probabilistyc for study level costs.
		merge into ltc_estimate dst
			using (
				select
					ltcp.id ltc_project_id,
					cst.study_id,
					sfn.function_code,
					cst.scope_code,
					decode(cst.scope_code || cst.subtype_code, 'EXTOEI', 1, 0) as is_external_fte,
					--to_number(to_char(cst.start_date,'yyyy')) as start_date_yyyy,
					--sum(decode(to_number(to_char(cst.start_date, 'yyyy')), v_ltc_start_year, cst.cost, null)) as fct_prob_y1_cost,
					--sum(decode(to_number(to_char(cst.start_date, 'yyyy')), v_ltc_start_year + 1, cst.cost, null)) as fct_prob_y2_cost,
					--sum(decode(to_number(to_char(cst.start_date, 'yyyy')), v_ltc_start_year + 2, cst.cost, null)) as fct_prob_y3_cost
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,0,cst.cost,v_number_of_profit_years)) as fct_prob_y1_cost,
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,1,cst.cost,v_number_of_profit_years)) as fct_prob_y2_cost,
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,2,cst.cost,v_number_of_profit_years)) as fct_prob_y3_cost,
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,3,cst.cost,v_number_of_profit_years)) as fct_prob_y4_cost,
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,4,cst.cost,v_number_of_profit_years)) as fct_prob_y5_cost,
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,5,cst.cost,v_number_of_profit_years)) as fct_prob_y6_cost,
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,6,cst.cost,v_number_of_profit_years)) as fct_prob_y7_cost,
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,7,cst.cost,v_number_of_profit_years)) as fct_prob_y8_cost,
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,8,cst.cost,v_number_of_profit_years)) as fct_prob_y9_cost,
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,9,cst.cost,v_number_of_profit_years)) as fct_prob_y10_cost,
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,10,cst.cost,v_number_of_profit_years)) as fct_prob_y11_cost,
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,11,cst.cost,v_number_of_profit_years)) as fct_prob_y12_cost,
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,12,cst.cost,v_number_of_profit_years)) as fct_prob_y13_cost,
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,13,cst.cost,v_number_of_profit_years)) as fct_prob_y14_cost,
					sum(check_profit_prefill_value(to_number(to_char(cst.start_date, 'yyyy')),v_ltc_start_year,14,cst.cost,v_number_of_profit_years)) as fct_prob_y15_cost
				from ipms_data.costs cst
				join ipms_data.subfunction sfn on (sfn.code = cst.subfunction_code)
				join ipms_data.function fnc on (fnc.code = sfn.function_code and fnc.top_function_code in ('1530', '1533'))
				join ltc_project ltcp on (ltcp.project_id = cst.project_id)
				join project prj on (ltcp.project_id = prj.id)
				join ltc_process ltcprc on (ltcprc.id = ltcp.ltc_process_id)
				join ltc_tag ltctag on (ltctag.id = ltcprc.ltc_tag_id)
				where cst.method_code = 'PROB'
				and cst.cost is not null
				and nvl(p_ltc_tag_id, ltcprc.ltc_tag_id) = ltcprc.ltc_tag_id
				and nvl(p_ltc_process_id, ltcp.ltc_process_id) = ltcp.ltc_process_id
				and nvl(p_ltc_program_id, prj.program_id) = prj.program_id
				and nvl(p_ltc_project_id, ltcp.project_id) = ltcp.project_id
				--and decode(p_is_manual_action,0,is_initially_prefiled,0) = 0 --was never prefilled -- For Prob -- this chcek is not needed because we always prefil
				and to_number(to_char(cst.start_date, 'yyyy')) >= v_ltc_start_year
				and to_number(to_char(cst.start_date, 'yyyy')) <= v_ltc_start_year + 2
				and cst.study_id is not null
				--the rule for Probabilistic Cost calculation where ForecastPROB is needed applies only for study_level costs
				--and cst.scope_code || cst.subtype_code in ('EXTECG', 'EXTCRO', 'EXTOEC', 'EXTOEI', 'INT')--below is the same rule but extracted with ORs
				and (
						(cst.scope_code = 'EXT' and
							(
								cst.subtype_code = 'ECG' or
								cst.subtype_code = 'CRO' or
								cst.subtype_code = 'OEC' or
								cst.subtype_code = 'OEI'
							)
						)
						or
						(cst.scope_code = 'INT' and cst.subtype_code is null)
				)
				and cst.type_code = 'FCT'
				and cst.is_last_forecast = 1 --TODO, probably it must be last forecast
				and nvl(sfn.function_code, cst.function_code) is not null
				group by
					ltcp.id,
					cst.study_id,
					sfn.function_code,
					cst.scope_code,
					decode(cst.scope_code || cst.subtype_code, 'EXTOEI', 1, 0)
				) src
			on (
				src.ltc_project_id = dst.ltc_project_id and 
				src.study_id = dst.study_id and 
				src.function_code = dst.function_code and 
				src.is_external_fte = dst.is_external_fte and 
				src.scope_code = dst.scope_code and 
				dst.is_discrepancy_profit = 0 and 
				dst.base_cost_source = 'PROFIT'
			-- and src.project_phase_code = dst.project_phase_code
			)
			when matched then
				update set
					fct_prob_y1_cost = src.fct_prob_y1_cost,
					fct_prob_y2_cost = src.fct_prob_y2_cost,
					fct_prob_y3_cost = src.fct_prob_y3_cost,
					fct_prob_y4_cost = src.fct_prob_y4_cost,
					fct_prob_y5_cost = src.fct_prob_y5_cost,
					fct_prob_y6_cost = src.fct_prob_y6_cost,
					fct_prob_y7_cost = src.fct_prob_y7_cost,
					fct_prob_y8_cost = src.fct_prob_y8_cost,
					fct_prob_y9_cost = src.fct_prob_y9_cost,
					fct_prob_y10_cost = src.fct_prob_y10_cost,
					fct_prob_y11_cost = src.fct_prob_y11_cost,
					fct_prob_y12_cost = src.fct_prob_y12_cost,
					fct_prob_y13_cost = src.fct_prob_y13_cost,
					fct_prob_y14_cost = src.fct_prob_y14_cost,
					fct_prob_y15_cost = src.fct_prob_y15_cost
			;
		
		------------------------------------------------------------------------
		v_rowcount := sql%rowcount;
		log_pkg.steps('d' || v_rowcount, v_step_start, v_steps_result);

		------------------------------------------------------------------------

		if p_ltc_tag_id is null then
			select ltc_tag_id
			into v_ltc_tag_id
			from ltc_process
			where id = p_ltc_process_id;
		else
			v_ltc_tag_id := p_ltc_tag_id;
		end if;

		------------------------------------------------------------------------
		--Update ltc_tag in order to mark prefil from ProFIT action.
		update ltc_tag set
			prefil_from_profit_date = sysdate,
			prefil_from_profit_user_id = v_user_id,
			update_date = sysdate,
			update_user_id = v_user_id,
			forecast_year = configuration_pkg.get_config_number('LAST-FCT-YEAR'),
			forecast_month = configuration_pkg.get_config_number('LAST-FCT-MONTH'),
			forecast_number = configuration_pkg.get_config_number('LAST-FCT-NUM'),
			forecast_version = configuration_pkg.get_config_number('LAST-FCT-VER')
		where id = v_ltc_tag_id;

		------------------------------------------------------------------------
		v_msg_out := ';' || v_msg_out || ';ltc_tag_updated_rowcount=' || sql%rowcount;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

	exception when others then
      log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
      notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
      raise;
    end;

	/*************************************************************************/
	/*
	*/
	procedure prefill_fps
	(
		p_ltc_tag_id in ltc_tag.id%type,
		p_ltc_process_id in ltc_process.id%type default null,
		p_ltc_program_id in program.id%type default null,
		p_ltc_project_id in project.id%type default null,
		p_is_manual_action in number default 0 --UI manual action to prefill one more time from FPS. 0 - means do not prefil for the second time
	) 
	as
		v_where nvarchar2(222) := 'ltc_sheet_pkg.prefill_fps';
		v_par nvarchar2(4000) := 'p_ltc_tag_id=' || p_ltc_tag_id ||
						';p_ltc_process_id=' || p_ltc_process_id ||
						';p_ltc_program_id=' || p_ltc_program_id ||
						';p_ltc_project_id=' || p_ltc_project_id ||
						';p_is_manual_action=' || p_is_manual_action;
		v_rowcount number := 0;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);
		v_ltc_start_year ltc_tag.start_year%type;
		v_number_of_profit_years number;

	begin

		log_pkg.steps(null, v_step_start, v_steps_result);

		select start_year, number_of_profit_years
		into v_ltc_start_year, v_number_of_profit_years
		from ltc_tag ltct
		where ltct.id = p_ltc_tag_id;

		v_par := v_par || ';v_ltc_start_year=' || v_ltc_start_year ||';v_number_of_profit_years='||v_number_of_profit_years;

		merge into ltc_estimate dst
			using (
				select
					'LTC' type_code,
					ltc_project_id,
					study_id,
					study_phase_code,
					study_name,
					study_fpfv,
					study_lplv,
					function_code,
					function_name,
					top_function_name,
					is_external_fte,
					scope_code,
					project_phase_code,
					project_phase_name,
					project_phase_ordering,
					sum(check_fps_prefill_value(year,v_ltc_start_year,0,cost,v_number_of_profit_years)) y1_cost,
					sum(check_fps_prefill_value(year,v_ltc_start_year,1,cost,v_number_of_profit_years)) y2_cost,
					sum(check_fps_prefill_value(year,v_ltc_start_year,2,cost,v_number_of_profit_years)) y3_cost,
					sum(check_fps_prefill_value(year,v_ltc_start_year,3,cost,v_number_of_profit_years)) y4_cost,
					sum(check_fps_prefill_value(year,v_ltc_start_year,4,cost,v_number_of_profit_years)) y5_cost,
					sum(check_fps_prefill_value(year,v_ltc_start_year,5,cost,v_number_of_profit_years)) y6_cost,
					sum(check_fps_prefill_value(year,v_ltc_start_year,6,cost,v_number_of_profit_years)) y7_cost,
					sum(check_fps_prefill_value(year,v_ltc_start_year,7,cost,v_number_of_profit_years)) y8_cost,
					sum(check_fps_prefill_value(year,v_ltc_start_year,8,cost,v_number_of_profit_years)) y9_cost,
					sum(check_fps_prefill_value(year,v_ltc_start_year,9,cost,v_number_of_profit_years)) y10_cost,
					sum(check_fps_prefill_value(year,v_ltc_start_year,10,cost,v_number_of_profit_years)) y11_cost,
					sum(check_fps_prefill_value(year,v_ltc_start_year,11,cost,v_number_of_profit_years)) y12_cost,
					sum(check_fps_prefill_value(year,v_ltc_start_year,12,cost,v_number_of_profit_years)) y13_cost,
					sum(check_fps_prefill_value(year,v_ltc_start_year,13,cost,v_number_of_profit_years)) y14_cost,
					sum(check_fps_prefill_value(year,v_ltc_start_year,14,cost,v_number_of_profit_years)) y15_cost,
					--sum(decode(year, v_ltc_start_year + 3, cost, null))  y4_cost,
					--sum(decode(year, v_ltc_start_year + 4, cost, null))  y5_cost,
					--sum(decode(year, v_ltc_start_year + 5, cost, null))  y6_cost,
					--sum(decode(year, v_ltc_start_year + 6, cost, null))  y7_cost,
					--sum(decode(year, v_ltc_start_year + 7, cost, null))  y8_cost,
					--sum(decode(year, v_ltc_start_year + 8, cost, null))  y9_cost,
					--sum(decode(year, v_ltc_start_year + 9, cost, null))  y10_cost,
					--sum(decode(year, v_ltc_start_year + 10, cost, null)) y11_cost,
					--sum(decode(year, v_ltc_start_year + 11, cost, null)) y12_cost,
					--sum(decode(year, v_ltc_start_year + 12, cost, null)) y13_cost,
					--sum(decode(year, v_ltc_start_year + 13, cost, null)) y14_cost,
					--sum(decode(year, v_ltc_start_year + 14, cost, null)) y15_cost,
					min(cost_start_date) cost_start_date,
					max(cost_finish_date) cost_finsih_date
				from ltc_imp_costs_fps_vw
				where nvl(p_ltc_tag_id, ltc_tag_id) = ltc_tag_id
				and nvl(p_ltc_process_id, ltc_process_id) = ltc_process_id
				and nvl(p_ltc_program_id, program_id) = program_id
				and nvl(p_ltc_project_id, project_id) = project_id
				--and is_initially_prefiled = 0 --was never prefilled
				and decode(p_is_manual_action, 0, is_initially_prefiled, 0) = 0 --means it was never prefilled
				group by
					ltc_project_id,
					study_id,
					function_code,
					is_external_fte,
					scope_code,
					project_phase_code,
					project_phase_name,
					project_phase_ordering,
					--timeline_id,
					--wbs_id,
					study_phase_code,
					study_name,
					study_fpfv,
					study_lplv,
					top_function_name,
					function_name
				having
					(
						sum(check_fps_prefill_value(year,v_ltc_start_year,0,cost,v_number_of_profit_years))||
						sum(check_fps_prefill_value(year,v_ltc_start_year,1,cost,v_number_of_profit_years))||
						sum(check_fps_prefill_value(year,v_ltc_start_year,2,cost,v_number_of_profit_years))||
						sum(check_fps_prefill_value(year,v_ltc_start_year,3,cost,v_number_of_profit_years))||
						sum(check_fps_prefill_value(year,v_ltc_start_year,4,cost,v_number_of_profit_years))||
						sum(check_fps_prefill_value(year,v_ltc_start_year,5,cost,v_number_of_profit_years))||
						sum(check_fps_prefill_value(year,v_ltc_start_year,6,cost,v_number_of_profit_years))||
						sum(check_fps_prefill_value(year,v_ltc_start_year,7,cost,v_number_of_profit_years))||
						sum(check_fps_prefill_value(year,v_ltc_start_year,8,cost,v_number_of_profit_years))||
						sum(check_fps_prefill_value(year,v_ltc_start_year,9,cost,v_number_of_profit_years))||
						sum(check_fps_prefill_value(year,v_ltc_start_year,10,cost,v_number_of_profit_years))||
						sum(check_fps_prefill_value(year,v_ltc_start_year,11,cost,v_number_of_profit_years))||
						sum(check_fps_prefill_value(year,v_ltc_start_year,12,cost,v_number_of_profit_years))||
						sum(check_fps_prefill_value(year,v_ltc_start_year,13,cost,v_number_of_profit_years))||
						sum(check_fps_prefill_value(year,v_ltc_start_year,14,cost,v_number_of_profit_years))
					) is not null
			) src
		on (
				src.ltc_project_id = dst.ltc_project_id
			and nvl(src.study_id, -1) = nvl(dst.study_id, -1)
			and src.function_code = dst.function_code
			and src.is_external_fte = dst.is_external_fte
			and src.scope_code = dst.scope_code
			and src.project_phase_code = dst.project_phase_code
			and src.type_code = dst.type_code
			and dst.is_manual = 0
		)
		when matched then
			update set
			--update only when value msut be taken from FPS, else update to the existing value (empty update)
				dst.lt_y1_cost = check_if_fps_update(dst.lt_y1_cost,src.y1_cost,0,v_number_of_profit_years),
				dst.lt_y2_cost = check_if_fps_update(dst.lt_y2_cost,src.y2_cost,1,v_number_of_profit_years),
				dst.lt_y3_cost = check_if_fps_update(dst.lt_y3_cost,src.y3_cost,2,v_number_of_profit_years),
				dst.lt_y4_cost = check_if_fps_update(dst.lt_y4_cost,src.y4_cost,3,v_number_of_profit_years),
				dst.lt_y5_cost = check_if_fps_update(dst.lt_y5_cost,src.y5_cost,4,v_number_of_profit_years),
				dst.lt_y6_cost = check_if_fps_update(dst.lt_y6_cost,src.y6_cost,5,v_number_of_profit_years),
				dst.lt_y7_cost = check_if_fps_update(dst.lt_y7_cost,src.y7_cost,6,v_number_of_profit_years),
				dst.lt_y8_cost = check_if_fps_update(dst.lt_y8_cost,src.y8_cost,7,v_number_of_profit_years),
				dst.lt_y9_cost = check_if_fps_update(dst.lt_y9_cost,src.y9_cost,8,v_number_of_profit_years),
				dst.lt_y10_cost = check_if_fps_update(dst.lt_y10_cost,src.y10_cost,9,v_number_of_profit_years),
				dst.lt_y11_cost = check_if_fps_update(dst.lt_y11_cost,src.y11_cost,10,v_number_of_profit_years),
				dst.lt_y12_cost = check_if_fps_update(dst.lt_y12_cost,src.y12_cost,11,v_number_of_profit_years),
				dst.lt_y13_cost = check_if_fps_update(dst.lt_y13_cost,src.y13_cost,12,v_number_of_profit_years),
				dst.lt_y14_cost = check_if_fps_update(dst.lt_y14_cost,src.y14_cost,13,v_number_of_profit_years),
				dst.lt_y15_cost = check_if_fps_update(dst.lt_y15_cost,src.y15_cost,14,v_number_of_profit_years)
		when not matched then
			insert (
				ltc_project_id, 
				study_id, 
				function_code,
				is_external_fte, 
				scope_code, 
				project_phase_code,
				cost_start_date, 
				cost_finish_date, 
				is_manual,
				study_name, 
				study_phase_code, 
				study_fpfv,
				study_lplv, 
				top_function_name, 
				function_name,
				project_phase_name, 
				project_phase_ordering,
				type_code, 
				base_cost_source,
				--if inserting then insert values based on SRC select calculation for all 15 years
				lt_y1_cost, 
				lt_y2_cost,
				lt_y3_cost,
				lt_y4_cost,
				lt_y5_cost, 
				lt_y6_cost, 
				lt_y7_cost, 
				lt_y8_cost, 
				lt_y9_cost, 
				lt_y10_cost, 
				lt_y11_cost, 
				lt_y12_cost, 
				lt_y13_cost, 
				lt_y14_cost, 
				lt_y15_cost
			)
			values (
				src.ltc_project_id, 
				src.study_id, 
				src.function_code,
				src.is_external_fte, 
				src.scope_code, 
				src.project_phase_code,
				src.cost_start_date, 
				src.cost_finsih_date, 
				0,
				src.study_name, 
				src.study_phase_code, 
				src.study_fpfv,
				src.study_lplv, 
				src.top_function_name,
				src.function_name,
				src.project_phase_name, 
				src.project_phase_ordering,
				'LTC', 
				'FPS',
				src.y1_cost, 
				src.y2_cost,
				src.y3_cost,
				src.y4_cost,
				src.y5_cost, 
				src.y6_cost, 
				src.y7_cost,
				src.y8_cost, 
				src.y9_cost,
				src.y10_cost, 
				src.y11_cost,
				src.y12_cost, 
				src.y13_cost,
				src.y14_cost, 
				src.y15_cost
			)
		;

		v_rowcount := sql%rowcount;
		log_pkg.steps('a' || v_rowcount, v_step_start, v_steps_result);

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

	exception when others then
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
		notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
		raise;
	end;

	/*************************************************************************/
	/*
	Prefills LTC deterministic costs from profit and from FPS
	Data processing granularity depends on provided parameters.
	Manual action initiated from UI
	*/
	procedure prefill_all
	(
		p_ltc_tag_id in ltc_tag.id%type,
		p_ltc_process_id in ltc_process.id%type default null,
		p_ltc_program_id in program.id%type default null,
		p_ltc_project_id in project.id%type default null,
		p_is_manual_action in number default 1
	)
	as
		v_where nvarchar2(222) := 'ltc_sheet_pkg.prefill_all';
		v_par nvarchar2(4000) := 'p_ltc_tag_id=' || p_ltc_tag_id ||
								';p_ltc_process_id=' || p_ltc_process_id ||
								';p_ltc_program_id=' || p_ltc_program_id ||
								';p_ltc_project_id=' || p_ltc_project_id ||
								';p_is_manual_action=' || p_is_manual_action;
		v_rowcount number := 0;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);

		ltc_sheet_pkg.prefill
			(
				p_ltc_tag_id,
				p_ltc_process_id,
				p_ltc_program_id,
				p_ltc_project_id,
				p_is_manual_action
			);

		ltc_sheet_pkg.prefill_fps
			(
				p_ltc_tag_id,
				p_ltc_process_id,
				p_ltc_program_id,
				p_ltc_project_id,
				p_is_manual_action
			);

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

	exception when others then
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
		notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
		raise;
	end;
	
	/*************************************************************************/
	/*
	*/
	function count_disc
	(
		p_ltc_tag_id in ltc_tag.id%type,
		p_ltc_process_id in ltc_process.id%type default null,
		p_ltc_program_id in program.id%type default null,
		p_ltc_project_id in project.id%type default null,
		p_ltc_type_code in ltc_estimate.type_code%type default null
	)
	return nvarchar2
	as
		v_sum_p6 number;
		v_sum_profit number;
		v_sum_c number;
		v_rcount number;
	begin
		if p_ltc_type_code is not null then -- can never be null
			select
				sum(is_discrepancy_p6) sum_p6,
				sum(is_discrepancy_profit) sum_profit,
				sum(is_discrepancy) sum_c,
				count(1) rcount
			into
				v_sum_p6,
				v_sum_profit,
				v_sum_c,
				v_rcount
			from ltc_estimate
			where ltc_project_id in (
										select
											ltcprj.id
										from ltc_project ltcprj
										join project prj on prj.id = ltcprj.project_id
										join ltc_process ltcprc on (
																	ltcprc.id = ltcprj.ltc_process_id 
																	and 
																	ltcprc.ltc_tag_id = nvl(p_ltc_tag_id,	decode(p_ltc_process_id,null, null,	ltcprc.ltc_tag_id))
																	)
										where nvl(p_ltc_process_id, ltcprc.id) = ltcprc.id
										and nvl(p_ltc_program_id, prj.program_id) = prj.program_id
										and nvl(p_ltc_project_id, ltcprj.project_id) = ltcprj.project_id
									)
			and type_code = p_ltc_type_code
			;
		end if;

		return '(' || v_sum_p6 || ':' || v_sum_profit || ':' || v_sum_c || ':' || v_rcount || ')';

	exception when others then
		return sqlerrm;
	end;

	/*************************************************************************/
	/*
	*/
	procedure recalculate
	(
		p_ltc_tag_id in ltc_tag.id%type,
		p_ltc_process_id in ltc_process.id%type default null,
		p_ltc_program_id in program.id%type default null,
		p_ltc_project_id in project.id%type default null,
		p_ltc_type_code in ltc_estimate.type_code%type default null
	)
	as
		v_where nvarchar2(222) := 'ltc_sheet_pkg.recalculate';
		v_par nvarchar2(4000) := 'p_user_id=' || --null || --Must be provided by UI
								';p_ltc_tag_id=' || p_ltc_tag_id ||
								';p_ltc_process_id=' || p_ltc_process_id ||
								';p_ltc_program_id=' || p_ltc_program_id ||
								';p_ltc_project_id=' || p_ltc_project_id ||
								';p_ltc_type_code=' || p_ltc_type_code;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);
		v_ltc_start_year ltc_tag.start_year%type;
		v_ltc_tag_id number;
		v_user_id nvarchar2(55) := 'TODO_PROCEDURE';
		v_rowcount number;
		v_start_scn number;
		v_finish_scn number;

	begin
		select timestamp_to_scn(sysdate) into v_start_scn from dual;

		log_pkg.steps(null, v_step_start, v_steps_result);
		v_msg_out := v_msg_out || ';#' ||count_disc(p_ltc_tag_id, p_ltc_process_id, p_ltc_program_id, p_ltc_project_id, p_ltc_type_code);

		-- Delete old discrepancies
		if p_ltc_type_code is not null then -- can never be null. the column is mandatory in the table
			delete from ltc_estimate
			where ltc_project_id in (
									select ltcprj.id
									from ltc_project ltcprj
									join project prj on prj.id = ltcprj.project_id
									join ltc_process ltcprc on (
																ltcprc.id = ltcprj.ltc_process_id 
																and 
																ltcprc.ltc_tag_id = nvl(p_ltc_tag_id,decode(p_ltc_process_id,null, null,ltcprc.ltc_tag_id))
																)
									where nvl(p_ltc_process_id, ltcprc.id) = ltcprc.id
									and nvl(p_ltc_program_id, prj.program_id) = prj.program_id
									and nvl(p_ltc_project_id, ltcprj.project_id) = ltcprj.project_id
									)
			and is_discrepancy_p6 = 1
			and type_code = p_ltc_type_code;
			
			v_rowcount := sql%rowcount;
		else
			v_rowcount := 0;
		end if;
		log_pkg.steps('a' || v_rowcount, v_step_start, v_steps_result);
		
		--Assumption - all records are discrepancies unless they have a match in RAW plan
		if p_ltc_type_code is not null then -- can never be null
			update ltc_estimate set is_discrepancy_p6 = 1
			where type_code = p_ltc_type_code
			and base_cost_source = 'PROFIT'
			and is_discrepancy_p6 = 0 -- if it is already 1 no reason to set again
			and ltc_project_id in (
									select ltcprj.id
									from ltc_project ltcprj
									join project prj on prj.id = ltcprj.project_id
									join ltc_process ltcprc on (
																ltcprc.id = ltcprj.ltc_process_id 
																and 
																ltcprc.ltc_tag_id = nvl(p_ltc_tag_id,decode(p_ltc_process_id,null, null,ltcprc.ltc_tag_id))
																)
									where nvl(p_ltc_process_id, ltcprc.id) = ltcprc.id
									and nvl(p_ltc_program_id, prj.program_id) = prj.program_id
									and nvl(p_ltc_project_id, ltcprj.project_id) = ltcprj.project_id
									);
			
			v_rowcount := sql%rowcount;
		else
			v_rowcount := 0;
		end if;
		log_pkg.steps('b' || v_rowcount, v_step_start, v_steps_result);
		
		-- Check whether study exists in RAW plan with particular project phase
		merge into ltc_estimate dst
			using (
				select
					p_ltc_type_code type_code,
					ltcprj.id ltc_project_id,
					wbs.study_id,
					mpm.phase_code project_phase_code
				from timeline_wbs wbs
				join timeline_wbs_category wca on (
													wca.timeline_id = wbs.timeline_id and 
													wca.wbs_id = wbs.wbs_id and 
													wbs.study_id is not null
													)
				join milestone mls on (mls.wbs_category = wca.category_name and mls.type_code='DEV')
				join ltc_milestone_phase_mapping mpm on (mpm.milestone_code = mls.code)
				join ltc_project ltcprj on (ltcprj.project_id = wbs.project_id)
				join project prj on (prj.id = ltcprj.project_id)
				join ltc_process ltcprc on (ltcprc.id = ltcprj.ltc_process_id)
				where nvl(p_ltc_tag_id, ltcprc.ltc_tag_id) = ltcprc.ltc_tag_id
				and nvl(p_ltc_process_id, ltcprc.id) = ltcprc.id
				and nvl(p_ltc_program_id, prj.program_id) = prj.program_id
				and nvl(p_ltc_project_id, prj.id) = prj.id
				and wbs.timeline_type_code = 'RAW'
				group by 
					ltcprj.id, 
					wbs.study_id, 
					mpm.phase_code
				having count(1) = 1
			) src
		on (
				src.ltc_project_id = dst.ltc_project_id
			and src.study_id = dst.study_id
			and src.project_phase_code = dst.project_phase_code
			and src.type_code = dst.type_code
			and dst.base_cost_source = 'PROFIT'
			--and dst.is_discrepancy_p6 = 1 --no need to set 0 when it is already 0 -- EORROR here, can not be used
		)
		when matched then update set is_discrepancy_p6 = 0;

		v_rowcount := sql%rowcount;
		log_pkg.steps('c' || v_rowcount, v_step_start, v_steps_result);

		-- Check whether project related costs still have project phase available (when its manual entry) or available and inside phase period (when its prefilled from PROFIT) in RAW plan
		merge into ltc_estimate dst
			using (
				select
					p_ltc_type_code type_code,
					ltcprj.id ltc_project_id,
					pmm.phase_code project_phase_code,
					nvl(pmm.start_date, to_date(ltctag.start_year || '-01-01', 'YYYY-MM-DD')) start_date,
					pmm.finish_date
				from ltc_milestone_phase_vw pmm
				join ltc_project ltcprj on (ltcprj.project_id = pmm.project_id and pmm.timeline_type_code = 'RAW')
				join ltc_process ltcprc on (ltcprc.id = ltcprj.ltc_process_id)
				join ltc_tag ltctag on (ltctag.id = ltcprc.ltc_tag_id)
				join project prj on (prj.id = ltcprj.project_id)
				where nvl(p_ltc_tag_id, ltcprc.ltc_tag_id) = ltcprc.ltc_tag_id
				and nvl(p_ltc_process_id, ltcprc.id) = ltcprc.id
				and nvl(p_ltc_program_id, prj.program_id) = prj.program_id
				and nvl(p_ltc_project_id, prj.id) = prj.id
			) src
		on (
				dst.study_id is null
			and src.ltc_project_id = dst.ltc_project_id
			and src.project_phase_code = dst.project_phase_code
			and src.start_date <= nvl(dst.cost_start_date, src.start_date)
			and nvl(src.finish_date, to_date('3000-01-01', 'YYYY-MM-DD')) >= nvl(dst.cost_finish_date, to_date('1000-01-01', 'YYYY-MM-DD'))
			and src.type_code = dst.type_code
			and dst.base_cost_source = 'PROFIT'
			--and dst.is_discrepancy_p6 = 1 --no need to set 0 when it is already 0 --ERROR can not be used here
		)
		when matched then update set is_discrepancy_p6 = 0;
		
		v_rowcount := sql%rowcount;
		log_pkg.steps('d' || v_rowcount, v_step_start, v_steps_result);
		
		begin
			v_rowcount := 0;
			--Insert all Discrepancies to TMP table in order to aviod DB issue - not stable data set later when making merge to the same table

			if p_ltc_type_code is not null then -- can never be null
				insert into ltc_estimate_tmp
				select *
				from ltc_estimate
				where ltc_project_id in
										(
										select ltcprj.id
										from ltc_project ltcprj
										join project prj on prj.id = ltcprj.project_id
										join ltc_process ltcprc on (
																	ltcprc.id = ltcprj.ltc_process_id
																	and 
																	ltcprc.ltc_tag_id = nvl(p_ltc_tag_id, decode(p_ltc_process_id, null,null, ltcprc.ltc_tag_id))
																	)
										where nvl(p_ltc_process_id, ltcprc.id) = ltcprc.id
										and nvl(p_ltc_program_id, prj.program_id) = prj.program_id
										and nvl(p_ltc_project_id, ltcprj.project_id) = ltcprj.project_id
										)
				;
				--and is_discrepancy_p6 = 1
				--and type_code = p_ltc_type_code
				--because of strange DB12.2 issue following two delete statements were extracted from insert and added as delete
				delete from ltc_estimate_tmp where type_code <> p_ltc_type_code;
				delete from ltc_estimate_tmp where is_discrepancy_p6 <> 1;
				select count(1) into v_rowcount from ltc_estimate_tmp;
			end if;

			log_pkg.steps('e' || v_rowcount, v_step_start, v_steps_result);

		exception when others then --until this step is not stable and fully tested better to continue then to stop the whole process
			v_msg_out := v_msg_out || ';eERROR=' || sqlerrm;
			log_pkg.steps('eERROR' || v_rowcount, v_step_start, v_steps_result);
		end;

		--Insert records from TMP to LTC_estimate as not discrepancy
		--but only if that is possible (using joins) based on Source VIEW
		if v_rowcount > 0 and p_ltc_tag_id is not null then
			begin
				v_rowcount := 0;
				insert into ltc_estimate
				(
					ltc_project_id,
					project_phase_code,
					study_id,
					function_code,
					scope_code,
					is_external_fte,
					comments,
					fct_y1_cost,
					fct_y2_cost,
					fct_y3_cost,
					fct_y4_cost,
					fct_y5_cost,
					fct_y6_cost,
					fct_y7_cost,
					fct_y8_cost,
					fct_y9_cost,
					fct_y10_cost,
					fct_y11_cost,
					fct_y12_cost,
					fct_y13_cost,
					fct_y14_cost,
					fct_y15_cost,

					lt_y1_cost,
					lt_y2_cost,
					lt_y3_cost,
					lt_y4_cost,
					lt_y5_cost,
					lt_y6_cost,
					lt_y7_cost,
					lt_y8_cost,
					lt_y9_cost,
					lt_y10_cost,
					lt_y11_cost,
					lt_y12_cost,
					lt_y13_cost,
					lt_y14_cost,
					lt_y15_cost,
					cost_start_date,
					cost_finish_date,
					is_manual,
					project_phase_name,
					study_phase_code,
					study_name,
					study_fpfv,
					study_lplv,
					top_function_name,
					function_name,
					function_cost_rate,
					fct_prob_y1_cost,
					fct_prob_y2_cost,
					fct_prob_y3_cost,
					type_code,
					is_discrepancy_profit,
					is_discrepancy_p6,
					project_phase_ordering
				)
				select
					ltctmp.ltc_project_id,
					ltctmp.project_phase_code,
					ltctmp.study_id,
					ltctmp.function_code,
					ltctmp.scope_code,
					ltctmp.is_external_fte,
					ltctmp.comments,
					--validate if the cost in the expected range, else return null
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 0, ltctmp.fct_y1_cost) as fct_y1_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 1, ltctmp.fct_y2_cost) as fct_y2_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 2, ltctmp.fct_y3_cost) as fct_y3_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 3, ltctmp.fct_y4_cost) as fct_y4_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 4, ltctmp.fct_y5_cost) as fct_y5_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 5, ltctmp.fct_y6_cost) as fct_y6_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 6, ltctmp.fct_y7_cost) as fct_y7_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 7, ltctmp.fct_y8_cost) as fct_y8_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 8, ltctmp.fct_y9_cost) as fct_y9_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 9, ltctmp.fct_y10_cost) as fct_y10_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 10, ltctmp.fct_y11_cost) as fct_y11_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 11, ltctmp.fct_y12_cost) as fct_y12_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 12, ltctmp.fct_y13_cost) as fct_y13_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 13, ltctmp.fct_y14_cost) as fct_y14_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 14, ltctmp.fct_y15_cost) as fct_y15_cost,

					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 0, ltctmp.lt_y1_cost) as lt_y1_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 1, ltctmp.lt_y2_cost) as lt_y2_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 2, ltctmp.lt_y3_cost) as lt_y3_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 3, ltctmp.lt_y4_cost) as lt_y4_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 4, ltctmp.lt_y5_cost) as lt_y5_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 5, ltctmp.lt_y6_cost) as lt_y6_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 6, ltctmp.lt_y7_cost) as lt_y7_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 7, ltctmp.lt_y8_cost) as lt_y8_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 8, ltctmp.lt_y9_cost) as lt_y9_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 9, ltctmp.lt_y10_cost) as lt_y10_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 10,ltctmp.lt_y11_cost) as lt_y11_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 11,ltctmp.lt_y12_cost) as lt_y12_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 12,ltctmp.lt_y13_cost) as lt_y13_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 13,ltctmp.lt_y14_cost) as lt_y14_cost,
					check_cost_range(pmm.start_date, pmm.finish_date, ltct.start_year + 14,ltctmp.lt_y15_cost) as lt_y15_cost,
					pmm.start_date,
					--ltctmp.cost_start_date,
					pmm.finish_date,
					--ltctmp.cost_finish_date,
					ltctmp.is_manual,
					ltctmp.project_phase_name,
					ltctmp.study_phase_code,
					ltctmp.study_name,
					ltctmp.study_fpfv,
					ltctmp.study_lplv,
					ltctmp.top_function_name,
					ltctmp.function_name,
					ltctmp.function_cost_rate,
					ltctmp.fct_prob_y1_cost,
					ltctmp.fct_prob_y2_cost,
					ltctmp.fct_prob_y3_cost,
					ltctmp.type_code,
					ltctmp.is_discrepancy_profit,
					0,
					--ltctmp.is_discrepancy_p6,
					ltctmp.project_phase_ordering
				from ltc_milestone_phase_vw pmm
				join ltc_project ltcprj on (ltcprj.project_id = pmm.project_id and pmm.timeline_type_code = 'RAW')
				join ltc_process ltcprc on (ltcprc.id = ltcprj.ltc_process_id)
				join ltc_tag ltct on (ltct.id = ltcprc.ltc_tag_id)
				--join project prj on (prj.id = ltcprj.project_id)
				join ltc_estimate_tmp ltctmp on
												(
												ltctmp.study_id is null
												and ltcprj.id = ltctmp.ltc_project_id
												and pmm.phase_code = ltctmp.project_phase_code
												--and src.start_date <= nvl(dst.cost_start_date, src.start_date)
												--and nvl(src.finish_date,to_date('3000-01-01','YYYY-MM-DD')) >= nvl(dst.cost_finish_date, to_date('1000-01-01','YYYY-MM-DD'))
												and p_ltc_type_code = ltctmp.type_code
												)
				;
				v_rowcount := sql%rowcount;
				log_pkg.steps('f' || v_rowcount, v_step_start, v_steps_result);

			exception when others then --until this step is not stable and fully tested better to continue then to stop the whole process
				v_msg_out := v_msg_out || ';fERROR=' || sqlerrm;
				log_pkg.steps('fERROR' || v_rowcount, v_step_start, v_steps_result);
			end;
		end if;

		if v_rowcount > 0 and p_ltc_tag_id is not null then 
		--some rows were moved back from Discrepancy to Normal, thus Update discrepancy (clean some cels)
			begin
				select start_year
				into v_ltc_start_year
				from ltc_tag ltct
				where ltct.id = p_ltc_tag_id;
				
				update ltc_estimate set
					fct_y1_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 0, fct_y1_cost),
					fct_y2_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 1, fct_y2_cost),
					fct_y3_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 2, fct_y3_cost),
					fct_y4_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 3, fct_y4_cost),
					fct_y5_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 4, fct_y5_cost),
					fct_y6_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 5, fct_y6_cost),
					fct_y7_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 6, fct_y7_cost),
					fct_y8_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 7, fct_y8_cost),
					fct_y9_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 8, fct_y9_cost),
					fct_y10_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 9, fct_y10_cost),
					fct_y11_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 10, fct_y11_cost),
					fct_y12_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 11, fct_y12_cost),
					fct_y13_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 12, fct_y13_cost),
					fct_y14_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 13, fct_y14_cost),
					fct_y15_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 14, fct_y15_cost),

					lt_y1_cost  = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 0, lt_y1_cost),
					lt_y2_cost  = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 1, lt_y2_cost),
					lt_y3_cost  = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 2, lt_y3_cost),
					lt_y4_cost  = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 3, lt_y4_cost),
					lt_y5_cost  = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 4, lt_y5_cost),
					lt_y6_cost  = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 5, lt_y6_cost),
					lt_y7_cost  = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 6, lt_y7_cost),
					lt_y8_cost  = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 7, lt_y8_cost),
					lt_y9_cost  = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 8, lt_y9_cost),
					lt_y10_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 9, lt_y10_cost),
					lt_y11_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 10, lt_y11_cost),
					lt_y12_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 11, lt_y12_cost),
					lt_y13_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 12, lt_y13_cost),
					lt_y14_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 13, lt_y14_cost),
					lt_y15_cost = check_cost_range(cost_start_date, cost_finish_date, v_ltc_start_year + 14, lt_y15_cost)
				where is_discrepancy = 1
				and id in (select id from ltc_estimate_tmp);

				v_rowcount := sql%rowcount;
				log_pkg.steps('g' || v_rowcount, v_step_start, v_steps_result);

			exception when others then --until this step is not stable and fully tested better to continue then to stop the whole process
				v_msg_out := v_msg_out || ';gERROR=' || sqlerrm;
				log_pkg.steps('gERROR' || v_rowcount, v_step_start, v_steps_result);
			end;
				
			begin
				delete ltc_estimate
				where (
					lt_y1_cost || lt_y2_cost || lt_y3_cost || lt_y4_cost || lt_y5_cost || lt_y6_cost || lt_y7_cost || lt_y8_cost || 
					lt_y9_cost || lt_y10_cost || lt_y11_cost || lt_y12_cost || lt_y13_cost || lt_y14_cost || lt_y15_cost
					) is null
				and id in (select id from ltc_estimate_tmp);

				v_rowcount := sql%rowcount;
				log_pkg.steps('h' || v_rowcount, v_step_start, v_steps_result);

			exception when others then --until this step is not stable and fully tested better to continue then to stop the whole process
				v_msg_out := v_msg_out || ';hERROR=' || sqlerrm;
				log_pkg.steps('hERROR' || v_rowcount, v_step_start, v_steps_result);
			end;

		end if;
		
		v_msg_out := v_msg_out || ';*' ||
		count_disc(p_ltc_tag_id, p_ltc_process_id, p_ltc_program_id, p_ltc_project_id, p_ltc_type_code);
		
		select timestamp_to_scn(sysdate) into v_finish_scn from dual;

		if v_start_scn <> v_finish_scn then
			v_msg_out := v_msg_out || ';start_scn=' || v_start_scn || ';finish_scn=' || v_finish_scn;
		else
			v_msg_out := v_msg_out || ';scn=' || v_start_scn;
		end if;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

	exception when others then
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
		notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
		raise;
	end;

	/*************************************************************************/
	/*
	*/
	procedure refresh_readonly
	(
		p_ltc_tag_id in ltc_tag.id%type,
		p_ltc_process_id in ltc_process.id%type default null,
		p_ltc_program_id in program.id%type default null,
		p_ltc_project_id in project.id%type default null,
		p_ltc_type_code in ltc_estimate.type_code%type default null
	)
	as
		v_where nvarchar2(222) := 'ltc_sheet_pkg.refresh_readonly';
		v_par nvarchar2(4000) := 'p_user_id=' || --null || -- Must be provided by UI
								';p_ltc_tag_id=' || p_ltc_tag_id ||
								';p_ltc_process_id=' || p_ltc_process_id ||
								';p_ltc_program_id=' || p_ltc_program_id ||
								';p_ltc_project_id=' || p_ltc_project_id ||
								';p_ltc_type_code=' || p_ltc_type_code;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);
		v_ltc_start_year ltc_tag.start_year%type;
		v_ltc_tag_id number;
		v_user_id nvarchar2(55) := 'TODO_PROCEDURE';
		v_rowcount number;
		v_start_scn number;
		v_finish_scn number;
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);

		merge into ltc_estimate dst
			using (
				select
					lte.id,
					tfnc.name top_function_name,
					fnc.name function_name,
					phs.name project_phase_name,
					std.name study_name,
					std.fpfv study_fpfv,
					std.lplv study_lplv,
					std.phase_code study_phase_code
				from ltc_estimate lte
				join ltc_project ltcprj on (ltcprj.id = lte.ltc_project_id)
				join phase phs on (phs.code = lte.project_phase_code)
				join function fnc on (lte.function_code = fnc.code)
				join top_function tfnc on tfnc.code = fnc.top_function_code
				left join study_data_vw std on (
												std.project_id = ltcprj.project_id and 
												std.id = lte.study_id and 
												std.timeline_type_code = 'RAW'
												)
				where type_code = p_ltc_type_code
				and ltc_project_id in (
										select 
											ltcprj.id
										from ltc_project ltcprj
										join project prj on prj.id = ltcprj.project_id
										join ltc_process ltcprc on (
																	ltcprc.id = ltcprj.ltc_process_id and 
																	ltcprc.ltc_tag_id = nvl(p_ltc_tag_id,decode(p_ltc_process_id,null,null,ltcprc.ltc_tag_id))
																	)
										where nvl(p_ltc_process_id, ltcprc.id) = ltcprc.id
										and nvl(p_ltc_program_id, prj.program_id) = prj.program_id
										and nvl(p_ltc_project_id, ltcprj.project_id) = ltcprj.project_id
										)
				and (
					phs.name != lte.project_phase_name or
					std.phase_code != lte.study_phase_code or
					tfnc.name != lte.top_function_name or
					fnc.name != lte.function_name or
					std.name != lte.study_name or
					std.fpfv != lte.study_fpfv or
					std.lplv != lte.study_lplv
					)
			
			) src
		on (src.id = dst.id)
		when matched then
			update set 
				dst.project_phase_name = src.project_phase_name,
				dst.study_phase_code = src.study_phase_code,
				dst.top_function_name = src.top_function_name,
				dst.function_name = src.function_name,
				dst.study_name = src.study_name,
				dst.study_fpfv = src.study_fpfv,
				dst.study_lplv = src.study_lplv
		;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

	exception when others then
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
		notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
		raise;
	end;

	/*************************************************************************/
	/*
	*/
	procedure setup
	(
		p_ltc_tag_id     in ltc_tag.id%type,
		p_ltc_process_id in ltc_process.id%type default null,
		p_ltc_program_id in program.id%type default null,
		p_ltc_project_id in project.id%type default null,
		p_ltc_type_code  in ltc_estimate.type_code%type default null
	)
	as
		v_where           nvarchar2(222) := 'ltc_sheet_pkg.setup';
		v_par             nvarchar2(4000) :=
		'p_user_id=' || null || --TODO Must be provided
		';p_ltc_tag_id=' || p_ltc_tag_id ||
		';p_ltc_process_id=' || p_ltc_process_id ||
		';p_ltc_program_id=' || p_ltc_program_id ||
		';p_ltc_project_id=' || p_ltc_project_id ||
		';p_ltc_type_code=' || p_ltc_type_code;
		v_step_start      timestamp := systimestamp;
		v_steps_result    nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out         nvarchar2(4000);
		v_ltc_start_year  ltc_tag.start_year%type;
	
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);
		
		refresh_readonly(p_ltc_tag_id, p_ltc_process_id, p_ltc_program_id, p_ltc_project_id, p_ltc_type_code);
		recalculate(p_ltc_tag_id, p_ltc_process_id, p_ltc_program_id, p_ltc_project_id, p_ltc_type_code);
		
		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
	
	exception when others then
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
		notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
		raise;
	end;
	
	/*************************************************************************/
	/*
	*/
end;
/