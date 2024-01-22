create or replace package import_costs_pkg as

	/**
	 * Costs are splitted by the costs source.
	 * functions without any suffix = original ones from FRLive
	 * _fps are merged from CUC project and ProMIS2 for all FPS costs (GED and CS and others)
	 */
	function load_costs(p_id in nvarchar2) return number;
	function merge_costs(p_id in nvarchar2) return number;
	function submit_costs(p_id in nvarchar2) return number;

	function load_costs_fps(p_id in nvarchar2) return number;
	function merge_costs_fps(p_id in nvarchar2) return number;
	function submit_costs_fps(p_id in nvarchar2) return number;
	
	PROCEDURE refresh_costs_vw_merge;

end;
/
create or replace package body import_costs_pkg
as
	/*************************************************************************/
	function get_config_number(p_code in configuration.code%type) return number as
		v_res number;
	begin

		select to_number(c.value) into v_res from configuration c where c.code=p_code;

		return v_res;

	exception when others then
		return to_number(null);
	end get_config_number;

	/*************************************************************************/
	function load_costs(p_id in nvarchar2) return number
	as
		v_forecast_number number;
		v_forecast_version number;
		v_forecast_year number;
		v_forecast_month number;
		v_max_forecast_year number;
		v_max_forecast_month number;

		v_where nvarchar2(99):='import_costs_pkg.load_costs';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		v_max_forecast_year:=import_costs_pkg.get_config_number('MAX-FCT-YEAR');
		v_max_forecast_month:=import_costs_pkg.get_config_number('MAX-FCT-MONTH');

		/* load temporary chunk of data */
		insert into sophia_costs2_tmp
		(
			PROJECT_ID,
			STUDY_ID,
			FUNCTION_ID,
			SUBFUNCTION_ID,
			COST_TYPE_CODE,
			COST_SUBTYPE_CODE,
			INT_EXT_CODE,
			PROB_DET_CODE,
			YEAR,
			MONTH,
			MERGE_KEY,
			CURRENT_FLAG,
			FORECAST_NUMBER,
			FORECAST_VERSION,
			COST,
			forecast_year,
			forecast_month
		)
			select
				PROJECT_ID,
				STUDY_ID,
				FUNCTION_ID,
				SUBFUNCTION_ID,
				COST_TYPE_CODE,
				COST_SUBTYPE_CODE,
				INT_EXT_CODE,
				PROB_DET_CODE,
				YEAR,
				MONTH,
				MERGE_KEY,
				CURRENT_FLAG,
				FORECAST_NUMBER,
				FORECAST_VERSION,
				COST,
				forecast_year,
				forecast_month
			from sophia_costs_vw_merge cst
			where cst.project_id=import_pkg.v_project.code
						and cst.cost is not null
						and cst.year between
						extract(year from import_pkg.v_import.create_date) - 1
						and extract(year from import_pkg.v_import.create_date) + 100;--PROMISIII-391, Profit Data in ProMIS only for 2 years?

		log_pkg.steps('a'||sql%rowcount ,v_step_start,v_steps_result);

		/* find forecast boundary */
		begin
			select forecast_number, forecast_version, forecast_year, forecast_month
			into v_forecast_number, v_forecast_version, v_forecast_year, v_forecast_month
			from (
				select forecast_number, forecast_version, forecast_year, forecast_month
				from sophia_costs2_tmp cst
				where cst.project_id=import_pkg.v_project.code
							and cst.cost_type_code = 'FCT'
							and cst.forecast_year=v_max_forecast_year
							and cst.forecast_month=v_max_forecast_month
				--
				/*
	  and (cst.forecast_year,cst.forecast_month) in
		(
		select
		  max(forecast_year),
		  max(forecast_month)
		from sophia_costs_vw_merge
		where cost_type_code ='FCT'
		and forecast_year=(select max(forecast_year) from sophia_costs_vw_merge where cost_type_code ='FCT')
		)
	  */
				order by forecast_number desc nulls last, forecast_version desc nulls last
			)
			where rownum=1;

			log_pkg.steps('b'||sql%rowcount ,v_step_start,v_steps_result);

			exception when no_data_found then
			v_forecast_number:=null;
			v_forecast_version:=null;
			v_forecast_year:=null;
			v_forecast_month:=null;
		end;

		/* drop old log */
		delete from import_costs
		where
			project_id = import_pkg.v_import.project_id
			and type_code in ('FCT', 'BGT', 'RR', 'ACT')
			and year between
			extract(year from import_pkg.v_import.create_date) - 1
			and extract(year from import_pkg.v_import.create_date) + 100;

		log_pkg.steps('c'||sql%rowcount ,v_step_start,v_steps_result);

		/* load data */
		insert into import_costs(
			import_id,
			project_id,
			reference_id,
			study_id,
			subfunction_code,
			type_code,
			subtype_code,
			scope_code,
			method_code,
			year,
			month,
			forecast_year,
			forecast_month,
			forecast_number,
			forecast_version,
			cost)
			select
				import_pkg.v_import.id,
				import_pkg.v_import.project_id,
				cst.merge_key, --scd2_key,
				cst.study_id,
				cst.subfunction_id,
				cst.cost_type_code,
				cstyp.code,
				cst.int_ext_code,
				cst.prob_det_code,
				cst.year,
				cst.month,
				cst.forecast_year,
				cst.forecast_month,
				cst.forecast_number,
				cst.forecast_version,
				cst.cost
			from sophia_costs2_tmp cst
				join costs_type ctyp on ctyp.code=cst.cost_type_code
				left join costs_subtype cstyp on cstyp.code=cst.cost_subtype_code
				join costs_scope csc on csc.code=cst.int_ext_code
				join calculation_method cmtd on cmtd.code=cst.prob_det_code
			where
				cst.project_id=import_pkg.v_project.code
				and (
					cst.cost_type_code <> 'FCT'
					or
					( cst.cost_type_code = 'FCT'
						and cst.forecast_number = v_forecast_number
						and cst.forecast_version = v_forecast_version
						and cst.forecast_year=v_forecast_year
						and cst.forecast_month=v_forecast_month
					)
				);

		log_pkg.steps('d'||sql%rowcount ,v_step_start,v_steps_result);

		/* release tmp space */
		delete from sophia_costs2_tmp where project_id=import_pkg.v_project.code;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where, 'p_id='||p_id||'; FCT='||v_forecast_number||'-'||v_forecast_version||';'||v_forecast_year||'-'||v_forecast_month, v_steps_result);

		return sql%rowcount;

	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result);
		raise;
	end;

	/*************************************************************************/
	function load_costs_fps(p_id in nvarchar2) return number 
	as
		v_where nvarchar2(99):='import_costs_pkg.load_costs_fps';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		--load temporary chunk of data
		insert into sophia_costs_fps_tmp
		select cst.*
		from sophia_costs_fps_vw cst
		where cst.project_id=import_pkg.v_project.code
		and cost is not null;

		log_pkg.steps('a'||sql%rowcount ,v_step_start,v_steps_result);

		--drop old log
		delete from import_costs_fps
		where project_id = import_pkg.v_import.project_id
		and type_code in ('FCT', 'BGT', 'RR', 'ACT');

		log_pkg.steps('b'||sql%rowcount ,v_step_start,v_steps_result);

		--load data
		insert into import_costs_fps(
			import_id,
			project_id,
			reference_id,
			study_id,
			project_activity_id,
			function_code,
			subfunction_code,
			type_code,
			subtype_code,
			scope_code,
			method_code,
			year,
			month,
			cost,
			committed_state,
			decision_start
		)
		select
			import_pkg.v_import.id,
			import_pkg.v_import.project_id,
			cst.scd2_key,
			cst.study_id,
			cst.project_activity_id,
			cst.function_id,
			cst.subfunction_id,
			cst.cost_type_code,
			cstyp.code,
			cst.int_ext_code,
			cst.prob_det_code,
			cst.year,
			cst.month,
			cst.cost,
			cst.commited_state,
			mil.code decision_start
		from sophia_costs_fps_tmp cst
			join costs_type ctyp on ctyp.code=cst.cost_type_code
			left join costs_subtype cstyp on cstyp.code=cst.cost_subtype_code
			join costs_scope csc on csc.code=cst.int_ext_code
			join calculation_method cmtd on cmtd.code=cst.prob_det_code
			left join milestone mil on (cst.decision_start=mil.code and mil.wbs_category is not null)
		where cst.project_id=import_pkg.v_project.code;
		--and cst.cost_type_code <> 'FCT';

		log_pkg.steps('c'||sql%rowcount ,v_step_start,v_steps_result);

		--release tmp space
		delete from sophia_costs_fps_tmp where project_id=import_pkg.v_project.code;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where, 'p_id='||p_id, v_steps_result);

		return sql%rowcount;

	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result);
		raise;
	end;

	/*************************************************************************/
	function merge_costs(p_id in nvarchar2) return number
	as
		v_where nvarchar2(99):='import_costs_pkg.merge_costs';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		update import_costs cst
		set
			status_code='FAIL',
			status_description='Invalid subfunction: '||cst.subfunction_code
		where import_id=p_id
		and status_code='NEW'
		and cst.subfunction_code is not null
		and not exists(select * from subfunction sf where sf.code=cst.subfunction_code);

		log_pkg.steps('a'||sql%rowcount ,v_step_start,v_steps_result);

		update import_costs cst
		set
			status_code='FAIL',
			status_description='Invalid study: '||cst.study_id
		where import_id=p_id
		and status_code='NEW'
		and cst.study_id is not null
		and not exists
			(
				select *
				from study_vw ts
				where ts.hlevel=1 
				and ts.project_id=cst.project_id
				and ts.timeline_type_code='CUR'
				and cst.study_id=ts.study_id
			)
		;

		log_pkg.steps('b'||sql%rowcount ,v_step_start,v_steps_result);

		update import_costs cst
		set status_code='READY'
		where import_id=p_id 
		and status_code='NEW';

		log_pkg.steps('c'||sql%rowcount ,v_step_start,v_steps_result);
		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where, 'p_id='||p_id, v_steps_result);

		return sql%rowcount;

	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result);
		raise;
	end;

	/*************************************************************************/
	function merge_costs_fps(p_id in nvarchar2) return number
	as
		v_where nvarchar2(99):='import_costs_pkg.merge_costs_fps';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		-- Make sure subfunctions are correct
		update import_costs_fps cst
		set
			status_code='FAIL',
			status_description='Invalid subfunction: '||cst.subfunction_code
		where import_id=p_id 
		and status_code='NEW' 
		and cst.subfunction_code is not null
		and not exists(select * from subfunction sf where sf.code=cst.subfunction_code);

		log_pkg.steps('a'||sql%rowcount ,v_step_start,v_steps_result);

		-- Set function (if it was not set)
		update import_costs_fps cst
		set
			function_code = (select function_code from subfunction where code=cst.subfunction_code)
		where import_id=p_id 
		and status_code='NEW'
		and function_code is null 
		and subfunction_code is not null;

		log_pkg.steps('b'||sql%rowcount ,v_step_start,v_steps_result);

/*
	  update import_costs_fps cst
	  set
		status_code='FAIL',
		status_description='Invalid study: '||cst.study_id
	  where
		import_id=p_id and status_code='NEW'
		and cst.study_id is not null
		and not exists(
		  select *
		  from study_vw
		  where ts.hlevel=1 and ts.project_id=cst.project_id
		  and ts.timeline_type_code='CUR' and cst.study_id=ts.study_id
		);
*/

		update import_costs_fps cst
		set status_code='READY'
		where import_id=p_id 
		and status_code='NEW';

		log_pkg.steps('c'||sql%rowcount ,v_step_start,v_steps_result);
		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where, 'p_id='||p_id, v_steps_result);

		return sql%rowcount;

	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result);
		raise;
	end;

	/*************************************************************************/
	function submit_costs(p_id in nvarchar2) return number 
	as
		v_where nvarchar2(99):='import_costs_pkg.submit_costs';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		v_is_fct_submitted boolean :=false;
		v_max_month number;
		v_max_year number;
		v_max_number number;
		v_max_version number;
		v_msg nvarchar2(11);
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		--drop old entries
		delete from costs
		where
			project_id=import_pkg.v_import.project_id
			and type_code in ('FCT', 'BGT', 'RR', 'ACT')
			and extract(year from start_date) between
			extract(year from import_pkg.v_import.create_date) - 1
			and extract(year from import_pkg.v_import.create_date) + 100;

		log_pkg.steps('a'||sql%rowcount ,v_step_start,v_steps_result);

		--Clear last forecast flag
		update costs set is_last_forecast=0 
		where type_code='FCT' 
		and project_id=import_pkg.v_import.project_id;

		log_pkg.steps('b'||sql%rowcount ,v_step_start,v_steps_result);

		--move data into ipms
		insert into costs
		(
			project_id,
			study_id,
			subfunction_code,
			scope_code,
			method_code,
			type_code,
			subtype_code,
			cost,
			forecast_year,
			forecast_month,
			forecast_number,
			forecast_version,
			is_last_forecast,
			start_date,
			finish_date
		)
		select
			project_id,
			study_id,
			imp.subfunction_code,
			scope_code,
			method_code,
			type_code,
			subtype_code,
			cost,
			forecast_year,
			forecast_month,
			forecast_number,
			forecast_version,
			decode(type_code,'FCT',1,null),
			to_date(year||'-'||month, 'yyyy-mm') as start_date,
			last_day(to_date(year||'-'||month, 'yyyy-mm')) as finish_date
		from import_costs imp
		join subfunction sub on sub.code=imp.subfunction_code
		where status_code='READY'
		and import_id=p_id;

		log_pkg.steps('c'||sql%rowcount ,v_step_start,v_steps_result);

		-- Validate if there were any FCT costs submitted

		for rr in (select 1 from costs where project_id=import_pkg.v_import.project_id and type_code='FCT' and rownum=1) loop
			v_is_fct_submitted:=true;
		end loop;

		if not v_is_fct_submitted then
			log_pkg.slog(v_where, v_par, 'Warning! No FCT data was submitted to COSTS table','WARNING');
		end if;

		-- Once we are sure that at least one FCT cost of last forecast year/month was submitted, save last forecast year and month to use in system calculations
		-- If at least one FCT row is available in import_costs, that mean its of last forecast version, so we can update system configuration without additional assertions
		begin
			select
				max(forecast_month) max_month,
				max(forecast_year) max_year,
				max(forecast_number) max_number,
				max(forecast_version) max_version
			into
				v_max_month,
				v_max_year,
				v_max_number,
				v_max_version
			from import_costs
			where import_id=p_id
			and type_code='FCT'
			and status_code='READY';
			
			if v_max_month is not null or v_max_year is not null or v_max_number is not null or v_max_version is not null then
				if nvl(configuration_pkg.get_config_number('LAST-FCT-MONTH'),-1)<>nvl(v_max_month,-1) then
					update configuration set value=nvl(v_max_month,value) where code='LAST-FCT-MONTH';
					v_msg:=v_msg||'m';
				end if;
				if nvl(configuration_pkg.get_config_number('LAST-FCT-YEAR'),-1)<>nvl(v_max_year,-1) then
					update configuration set value=nvl(v_max_year,value) where code='LAST-FCT-YEAR';
					v_msg:=v_msg||'y';
				end if;
				if nvl(configuration_pkg.get_config_number('LAST-FCT-NUM'),-1)<>nvl(v_max_number,-1) then
					update configuration set value=nvl(v_max_number,value) where code='LAST-FCT-NUM';
					v_msg:=v_msg||'n';
				end if;
				if nvl(configuration_pkg.get_config_number('LAST-FCT-VER'),-1)<>nvl(v_max_version,-1) then
					update configuration set value=nvl(v_max_version,value) where code='LAST-FCT-VER';
					v_msg:=v_msg||'v';
				end if;
			else
				v_msg:=v_msg||'null';
			end if;
		
		exception when others then
			v_msg:=v_msg||'ER';
		end;

		log_pkg.steps('d'||v_msg,v_step_start,v_steps_result);
		
		--mark as complete
		--update import_costs cst set status_code='DONE'
		--delete from tem logs, because it is not being used anywhere
		delete from import_costs
		where import_id=p_id 
		and status_code='READY';
		
		log_pkg.steps('e'||sql%rowcount ,v_step_start,v_steps_result);
		
		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where, 'p_id='||p_id, v_steps_result);
		
		return sql%rowcount;

	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result);
		raise;
	end;

	/*************************************************************************/
	function submit_costs_fps(p_id in nvarchar2) return number
	as
		v_where nvarchar2(99):='import_costs_pkg.submit_costs_fps';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		--drop old entries
		delete from costs_fps
		where project_id=import_pkg.v_import.project_id;

		log_pkg.steps('a'||sql%rowcount, v_step_start, v_steps_result);

		--move data into promis
		insert into costs_fps
		(
			project_id,
			study_id,
			project_activity_id,
			function_code,
			subfunction_code,
			scope_code,
			method_code,
			type_code,
			subtype_code,
			cost,
			committed_state,
			start_date,
			finish_date,
			decision_start
		)
		select
			project_id,
			study_id,
			project_activity_id,
			function_code,
			subfunction_code,
			scope_code,
			method_code,
			type_code,
			subtype_code,
			cost,
			committed_state,
			to_date(year||'-'||month, 'yyyy-mm') as start_date,
			last_day(to_date(year||'-'||month, 'yyyy-mm')) as finish_date,
			decision_start
		from import_costs_fps imp
		where status_code='READY'
		and import_id=p_id;

		log_pkg.steps('b'||sql%rowcount,v_step_start,v_steps_result);

		--mark as complete
		update import_costs_fps cst
		set status_code='DONE'
		where import_id=p_id
		and status_code='READY';

		log_pkg.steps('c'||sql%rowcount,v_step_start,v_steps_result);
		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where, 'p_id='||p_id, v_steps_result);

		return sql%rowcount;

	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result);
		raise;
	end;

	/*************************************************************************/
	PROCEDURE refresh_costs_vw_merge AS
		v_rowcount number:=0;
		v_count_view number;
		v_count_tab number;
		----
		v_where nvarchar2(222):='import_costs_pkg.refresh_costs_vw_merge';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		----
		begin
			log_pkg.steps(null,v_step_start,v_steps_result);

			MERGE INTO sophia_costs_vw_merge dest
			using (select merge_key
							 , max (decode (seq, 1, project_id)) project_id
							 , max (decode (seq, 1, study_id)) study_id
							 , max (decode (seq, 1, function_id)) function_id
							 , max (decode (seq, 1, subfunction_id)) subfunction_id
							 , max (decode (seq, 1, cost_type_code)) cost_type_code
							 , max (decode (seq, 1, cost_subtype_code)) cost_subtype_code
							 , max (decode (seq, 1, int_ext_code)) int_ext_code
							 , max (decode (seq, 1, prob_det_code)) prob_det_code
							 , max (decode (seq, 1, year)) year
							 , max (decode (seq, 1, month)) month
							 , max (decode (seq, 1, current_flag)) current_flag
							 --, max (decode (seq, 1, valid_from)) valid_from
							 --, max (decode (seq, 1, valid_to)) valid_to
							 , max (decode (seq, 1, forecast_number)) forecast_number
							 , max (decode (seq, 1, forecast_version)) forecast_version
							 , max (decode (seq, 1, cost)) cost
							 , max (decode (seq, 1, forecast_year)) forecast_year
							 , max (decode (seq, 1, forecast_month)) forecast_month
							 , sum (decode (seq, 1, srccnt, dstcnt)) iud
						 FROM (SELECT merge_key,project_id,study_id,function_id,subfunction_id,cost_type_code,cost_subtype_code,
										 int_ext_code,prob_det_code,YEAR,MONTH,current_flag,forecast_number,
										 forecast_version,cost,forecast_year,forecast_month
										 ,srccnt, dstcnt
										 ,row_number () over (partition by merge_key order by dstcnt nulls last) seq
									 FROM (SELECT merge_key,project_id,study_id,function_id,subfunction_id,cost_type_code,
													 cost_subtype_code,int_ext_code,prob_det_code,year,month,current_flag,
													 forecast_number,forecast_version,cost,forecast_year,forecast_month
													 , count (src) srccnt, count (dst) dstcnt
												 FROM (SELECT merge_key,
																 project_id,
																 study_id,
																 function_id,
																 subfunction_id,
																 cost_type_code,
																 cost_subtype_code,
																 int_ext_code,
																 prob_det_code,
																 YEAR,
																 MONTH,
																 current_flag,
																 --trunc(valid_from) valid_from,
																 --trunc(valid_to) valid_to,
																 forecast_number,
																 forecast_version,
																 COST,
																 forecast_year,
																 forecast_month
																 ,1 src, to_number(null) dst
															 from sophia_costs2_vw
															 --where project_id='1997'
															 UNION ALL
															 SELECT merge_key,
																 project_id,
																 study_id,
																 function_id,
																 subfunction_id,
																 cost_type_code,
																 cost_subtype_code,
																 int_ext_code,
																 prob_det_code,
																 YEAR,
																 MONTH,
																 current_flag,
																 --trunc(valid_from) valid_from,
																 --trunc(valid_to) valid_to,
																 forecast_number,
																 forecast_version,
																 COST,
																 forecast_year,
																 forecast_month
																 ,to_number(null) src, 2 dst
															 from sophia_costs_vw_merge
													 --where project_id='1997'
												 )
												 GROUP BY merge_key,project_id,study_id,function_id,subfunction_id,cost_type_code,
													 cost_subtype_code,int_ext_code,prob_det_code,YEAR,MONTH,current_flag,
													 forecast_number,forecast_version,cost,forecast_year,forecast_month
												 having count (src) <> count (dst)))
						 group by merge_key) diff
			ON (dest.merge_key = diff.merge_key)
			WHEN MATCHED
			THEN
			UPDATE SET
				dest.project_id = diff.project_id
				,dest.study_id = diff.study_id
				,dest.function_id = diff.function_id
				,dest.subfunction_id = diff.subfunction_id
				,dest.cost_type_code = diff.cost_type_code
				,dest.cost_subtype_code = diff.cost_subtype_code
				,dest.int_ext_code = diff.int_ext_code
				,dest.prob_det_code = diff.prob_det_code
				,dest.year = diff.year
				,dest.month = diff.month
				,dest.current_flag = diff.current_flag
				--,dest.valid_from = diff.valid_from
				--,dest.valid_to = diff.valid_to
				,dest.forecast_number = diff.forecast_number
				,dest.forecast_version = diff.forecast_version
				,dest.COST = diff.COST
				,dest.forecast_year = diff.forecast_year
				,dest.forecast_month = diff.forecast_month
				,dest.update_date = sysdate

			DELETE
			WHERE (diff.iud = 0)
			WHEN NOT MATCHED
			then
			INSERT (merge_key,project_id,study_id,function_id,subfunction_id,cost_type_code,cost_subtype_code,int_ext_code,
							prob_det_code,year,month,current_flag,forecast_number,forecast_version,cost,
							forecast_year,forecast_month,create_date,update_date)
			VALUES (diff.merge_key,
				diff.project_id,
				diff.study_id,
				diff.function_id,
				diff.subfunction_id,
				diff.cost_type_code,
				diff.cost_subtype_code,
				diff.int_ext_code,
				diff.prob_det_code,
				diff.YEAR,
				diff.MONTH,
							diff.current_flag,
							--diff.valid_from,
							--diff.valid_to,
							diff.forecast_number,
							diff.forecast_version,
							diff.cost,
							diff.forecast_year,
							diff.forecast_month,
							sysdate,
							sysdate);
			v_rowcount := v_rowcount + sql%rowcount;

			log_pkg.steps('END',v_procedure_start,v_steps_result);
			log_pkg.log(v_where, 'rowcount='||v_rowcount,v_steps_result);

			exception when others then
			log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
			log_pkg.scatch(v_where, null, v_steps_result);
			raise;
		end;

end;
/