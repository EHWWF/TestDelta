create or replace package import_pkg as
--pragma serially_reusable;
	v_import import%rowtype;
	v_project project%rowtype;

	/*************************************************************************/
	function type_headcount return number;
	--Costs import mask.
	function type_costs return number;
	--Resources import mask.
	function type_resources return number;
	--Timeline actuals import mask.
	function type_actuals return number;
	--Timeline plan import mask.
	function type_plan return number;
	--Studies import mask.
	function type_study return number;
	--Masterdata import mask.
	function type_masterdata return number;
	--Lookups import mask
	function type_lookups return number;
	--Log import mask
	function type_log return number;
	--D1 project area import mask
	function type_d1 return number;
	--Timeline plan import mask. Conditional - only for studies which are maked for automatic import
	function type_plan_auto return number;
  --Import mask for project level activities
	function type_project_activities return number;
	--Import mask, which requires fresh RAW plan.
	function type_raw return number;
	--Import mask of all project data.
	function type_project return number;
	--Import mask of non-project data.
	function type_global return number;

	/*************************************************************************/
	/**
	 * Safely cleanups old data.
	 */
	procedure cleanup;

	/*************************************************************************/
	/**
	 * Starts import job for all projects.
	 * Includes only those unlocked projects, which has no unfinished imports.
	 * Handles all startups exceptions.
	 */
	procedure launch_all;

	/*************************************************************************/
	/**
	 * Starts single project level import of defined type mask.
	 * Returns import id.
	 */
	function launch(p_project_id in nvarchar2, p_import_type in number, p_is_manual in number := 0) return nvarchar2;

	/*************************************************************************/
	/**
	 * Starts import for already existing entry.
	 * Loads data from sophia and combase into import log.
	 * Loads only data for 3 years (previous, current, next).
	 * Deletes previous import logs for the same projects and same period.
	 * Requires unlocked instance in status 'new'.
	 * Requires project for project level import.
	 * Requires raw plan for timeline related import.
	 * Throws no_data_found exception if requirements unmatched.
	 * Asynchronous (optionaly).
	 * Sends (optionaly) read/timeline message.
	 * Calls load_xyz() according to import mask.
	 * Calls merge() in synchronous case (no raw plan needed).
	 * Sequence of calls for non-timeline related imports: launch->load_xyz()->merge()->merge_xyz()->finish()->submit_xyz().
	 * Sequence of calls for timeline related imports: launch->load_xyz()->send(read/timeline)/./merge()->merge_xyz()->send(update/timeline)->finish()->submit_xyz()/./finish(xml)->finish_xyz().
	 */
	procedure launch(p_id in nvarchar2);

	/*************************************************************************/
	/**
	 * Completes timeline related import.
	 * Requires instance in state 'send'.
	 * Throws no_data_found exception if requirements unmatched.
	 * Callback.
	 * Unlocks instance.
	 * Calls finis_xyz() according to import mask.
	 * Marks instance as 'done'.
	 */
	procedure send_finish(p_id in nvarchar2, p_payload in xmltype);

	/*************************************************************************/
	/**
	 * Finishes import.
	 * Saves data into ipms.
	 * Deletes previous data of the same period.
	 * Requires unlocked instance in status 'ready'.
	 * Requires project for project level import.
	 * Requires raw plan for timeline related import.
	 * Throws no_data_found exception if requirements unmatched.
	 * Calls submit_xyz() according to import mask.
	 * Asynchronous (optionaly).
	 * Sends (optionaly) update/timeline message.
	 * Marks instance as 'done' or 'send' (in asynchronous case).
	 */
	procedure finish(p_id in nvarchar2);

	/*************************************************************************/
	/**
	 * Merges import data with ipms data and raw plan.
	 * Requires instance in status 'new'.
	 * Requires unlocked instance in non-callback case.
	 * Requires project for project level import.
	 * Throws no_data_found exception if requirements unmatched.
	 * Callback (optionaly).
	 * Calls merge_xyz() according to import mask.
	 * Moves import into 'ready' state.
	 * Calls finish() in non-manual case (otherwise finish() will be called explicitly).
	 */
	procedure merge(p_id in nvarchar2, p_payload in xmltype);

	/*************************************************************************/
	/**
	 * Discards import.
	 * Deletes all import log.
	 */
	procedure cancel(p_id in nvarchar2);

	/*************************************************************************/
	/**
	 * Sets final status for import instance.
	 *
	 */
	procedure finalize(p_id in nvarchar2, p_payload in xmltype);


end;
/
create or replace package body import_pkg
as
	--pragma serially_reusable;
	v_timeline xmltype;
	v_msg nvarchar2(4000);
	v_ltimestamp_start timestamp;
	v_g_ltimestamp_start timestamp;
	v_log_performance nvarchar2(32000);
	v_job_id nvarchar2(20);
	v_error nvarchar2(32000);
	v_guid sys_guid_transaction.guid%type;


	/*************************************************************************/
	--Headcount import mask.
	--type_headcount constant number(20) := 1;
	function type_headcount return number
	as
	begin
		return 1;
	end;

	/*************************************************************************/
	--Costs import mask.
	--type_costs constant number(20) := 2;
	function type_costs return number
	as
	begin
		return 2;
	end;

	/*************************************************************************/
	--Resources import mask.
	--type_resources constant number(20) := 4;
	function type_resources return number
	as
	begin
		return 4;
	end;

	/*************************************************************************/
	--Timeline actuals import mask.
	--type_actuals constant number(20) := 8;
	function type_actuals return number
	as
	begin
		return 8;
	end;

	/*************************************************************************/
	--Timeline plan import mask.
	--type_plan constant number(20) := 16;
	function type_plan return number
	as
	begin
		return 16;
	end;

	/*************************************************************************/
	--Studies import mask.
	--type_study constant number(20) := 64;
	function type_study return number
	as
	begin
		return 64;
	end;

	/*************************************************************************/
	--Masterdata import mask.
	--type_masterdata constant number(20) := 128;
	function type_masterdata return number
	as
	begin
		return 128;
	end;

	/*************************************************************************/
	--Lookups import mask
	--type_lookups constant number(20) := 256;
	function type_lookups return number
	as
	begin
		return 256;
	end;

	/*************************************************************************/
	--Log import mask
	--type_log constant number(20) := 512;
	function type_log return number
	as
	begin
		return 512;
	end;

	/*************************************************************************/
	--D1 project area import mask
	--type_d1 constant number(20) := 1024;
	function type_d1 return number
	as
	begin
		return 1024;
	end;

	/*************************************************************************/
	--Timeline plan import mask. Conditional - only for studies which are maked for automatic import
	--type_plan_auto constant number(20) := 2048;
	function type_plan_auto return number
	as
	begin
		return 2048;
	end;

	/*************************************************************************/
	--Import mask for project level activities
	function type_project_activities return number
	as
	begin
		return 4096;
	end;

	/*************************************************************************/
	--Import mask, which requires fresh RAW plan.
	--type_raw constant number(20) := type_actuals + type_plan + type_plan_auto + type_study;
	function type_raw return number
	as
	begin
		return type_actuals + type_plan + type_plan_auto + type_study;
	end;

	/*************************************************************************/
	--Import mask of all project data.
	--type_project constant number(20) := type_costs + type_resources + type_actuals + type_study + type_masterdata;--2+4+8+64+128
	function type_project return number
	as
	begin
		return type_costs + type_resources + type_actuals + type_study + type_masterdata + type_project_activities;--2+4+8+64+128;
	end;

	/*************************************************************************/
	--Import mask of non-project data.
	--type_global constant number(20) := type_lookups + type_headcount + type_log;
	function type_global return number
	as
	begin
		return type_lookups + type_headcount + type_log;
	end;

	/*************************************************************************/
	procedure set_max_forecast as
		v_forecast_year number;
		v_forecast_month number;
		v_where nvarchar2(99):='import_pkg.set_max_forecast';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		select
			max(forecast_year),max(forecast_month)
		into v_forecast_year, v_forecast_month
		from sophia_costs_vw_merge
		where cost_type_code ='FCT'
					and forecast_year=(select max(forecast_year) from sophia_costs_vw_merge where cost_type_code ='FCT')
		;

		if v_forecast_year is not null then
			update configuration set value=v_forecast_year where code = 'MAX-FCT-YEAR' and nvl(value,'#')<>to_char(v_forecast_year);
		end if;

		if v_forecast_month is not null then
			update configuration set value=v_forecast_month where code = 'MAX-FCT-MONTH' and nvl(value,'#')<>to_char(v_forecast_month);
		end if;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where, 'v_forecast_year='||v_forecast_year||';v_forecast_month='||v_forecast_month, v_steps_result);

	exception when others then
		log_pkg.scatch(v_where, 'v_forecast_year='||v_forecast_year||';v_forecast_month='||v_forecast_month, v_steps_result);
	end;

	/*************************************************************************/
	function get_subject return nvarchar2 as
		begin
			return 'import:'||v_import.id;
		end;

	/*************************************************************************/
	function get_summary return nvarchar2
	as
	begin
		if v_import.project_id is not null then
			return 'Import['||v_import.id||'] of '||project_pkg.get_summary(v_project.id);
		else
			return 'Import['||v_import.id||']';
		end if;
	end;

	/*************************************************************************/
	function get_timeline_id(p_id in import.id%type) return timeline.id%type
	as
		v_timeline_id timeline.id%type;
	begin
		select tml.id as timeline_id
		into v_timeline_id
		from timeline tml, import i
		where i.id = p_id
		and (
			i.project_id is not null and tml.project_id=i.project_id and tml.type_code='RAW'
			or
			i.sandbox_id is not null and tml.id = (select snd_timeline_id from program_sandbox where id=i.sandbox_id)
		)
		and tml.is_syncing=0;

		return v_timeline_id;

	exception when no_data_found then
		return null; --we also load project that have no TIMELINE at all, e.g. LG, LO
	end;

	/*************************************************************************/
	procedure log_performance(p_where nvarchar2)
	as
		v_linterval_diff interval day to second;
	begin
		v_linterval_diff := systimestamp - v_ltimestamp_start;
		if trunc(extract(second from v_linterval_diff)) > 0 then
			--v_log_performance := v_log_performance||';'||p_where||'='||trunc(extract(second from v_linterval_diff));
			v_log_performance := substr(v_log_performance||';'||p_where||'='||trunc(extract(minute from v_linterval_diff)*60+extract(second from v_linterval_diff)),1,4000);
		end if;
		v_ltimestamp_start := systimestamp;
	exception when others then
		null;
	end;

	/*************************************************************************/
	procedure cleanup
	as
		v_where nvarchar2(99):='import_pkg.cleanup';
	begin
		/* do not keep discarded imports */
		begin
			delete from import where status_code in ('DROP','VOID');
		exception when others then
			log_pkg.catch(v_where,'import1','import1');
			for rr in (select id from import where status_code in ('DROP','VOID'))
			loop
				begin
					delete from import where id=rr.id;
				exception when others then
					--log_pkg.catch(v_where,'import1e','import1e');
					null;
				end;
			end loop;
		end;
		/* keep imports only for two months */
		begin
			delete from import where (sysdate - create_date) > 60;
		exception when others then
			log_pkg.catch(v_where,'import2','import2');
			for rr in (select id from import where (sysdate - create_date) > 60)
			loop
				begin
					delete from import where id=rr.id;
				exception when others then
					--log_pkg.catch(v_where,'import2e','import2e');
					null;
				end;
			end loop;
		end;
		/* keep stale imports only for one day */
		begin
			delete from import where status_code not in ('DONE','FAIL') and (sysdate - create_date) > 1;
		exception when others then
			log_pkg.catch(v_where,'import3','import3');
			for rr in (select id from import where status_code not in ('DONE','FAIL') and (sysdate - create_date) > 1)
			loop
				begin
					delete from import where id=rr.id;
				exception when others then
					--log_pkg.catch(v_where,'import3e','import3e');
					null;
				end;
			end loop;
		end;
	end;

	/*************************************************************************/
	function is_reload_costs return number as
		v_max_date date;
		begin
			---PROMISIII-294
			--if data source (costs from Sophia) was not changed then skip import
			--to do that chcek max update date
			--and if this date equals to import date (sysdate) then import
			select nvl(max(update_date), sysdate+999) into v_max_date
			from sophia_costs_vw_merge
			where project_id=import_pkg.v_project.code;

			if trunc(v_max_date)=trunc(sysdate) then --imported/updated today
				return 1;
			else
				--ELSE
				--test special cases:
				---it could happen that even if the source did not change but some changes at ProMIS impacted that cost should be imported again
				---if the last cost import was with errors (had FAIL  status), so, maybe trying one more time now would lead to success
				begin
					select create_date into v_max_date --it just for checking if at all exsisted FAIL, else we will get no data found
					from import_costs
					where project_id=import_pkg.v_project.id
								and status_code <> 'DONE'
								and trunc(create_date)=(select trunc(max(create_date)) from import_costs where project_id=import_pkg.v_project.id)
								and rownum=1; --at least one needed for checking

					return 1;

					exception when others then
					return 0;
				end;

			end if;
		end;

	/*************************************************************************/
	function load_timeline(p_id in nvarchar2) return number
	as
		v_sophia_prj_id project.code%type;
		v_timeline_id timeline.id%type;
		v_rowcount pls_integer:=0;
		v_where nvarchar2(99):='import_pkg.load_timeline';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		v_sub_ nvarchar2(10);
		v_app_ nvarchar2(10);

	begin
			log_pkg.steps(null,v_step_start,v_steps_result);

			if v_import.source = 'RAPT' then
				v_sub_ := 'SUB_';
				v_app_ := 'APP_';
			end if;

			v_sophia_prj_id := v_project.code;
			if v_import.sandbox_id is not null then

				select sbx_src_prj.code as sophia_prj_id
				into v_sophia_prj_id
				from program_sandbox sbx
				inner join timeline sbx_src_tml on sbx_src_tml.id = sbx.timeline_id
				inner join project sbx_src_prj on sbx_src_prj.id=sbx_src_tml.project_id
				where sbx.id=v_import.sandbox_id;

			end if;

			log_pkg.steps('a',v_step_start,v_steps_result);

			v_timeline_id := get_timeline_id(v_import.id);

			/* load temporary chunk of data */
			insert into sophia_timeline_tmp
			select tml.*
			from sophia_timeline_vw tml
			where tml.project_id=v_sophia_prj_id
			and (tml.start_date is not null or tml.finish_date is not null)
			and
			(
					bitand(v_import.type_mask, type_actuals) = type_actuals and tml.type_code = 'ACT'
				or
					bitand(v_import.type_mask, type_plan) = type_plan and tml.type_code = 'PLAN'
				or
					(
						bitand(v_import.type_mask, type_plan_auto) = type_plan_auto
						and tml.type_code = 'PLAN'
						and exists (select 1 from study std where std.id=tml.study_id and std.project_id=v_project.id and is_timeline_auto_import=1)
					)
			)
			and (nvl(study_element_id,'######') like v_sub_||'%' or nvl(study_element_id,'######') like v_app_||'%')
			;

			v_rowcount := v_rowcount + sql%rowcount;
			log_pkg.steps('b'||sql%rowcount,v_step_start,v_steps_result);

			/* drop old log */
			delete from import_timeline tml
			where exists(
						select *
						from import i
						where i.id = tml.import_id
									and nvl(i.source, 'CMBS')=nvl(v_import.source, 'CMBS')
									and (
										i.project_id=v_import.project_id or i.sandbox_id=v_import.sandbox_id
										or
											tml.project_id=v_import.project_id
										or
											tml.timeline_id=v_timeline_id
									)
			)
			and (
				bitand(v_import.type_mask, type_actuals) = type_actuals and tml.type_code = 'ACT'
				or
				bitand(v_import.type_mask, type_plan) = type_plan and tml.type_code = 'PLAN'
				or
				(
					bitand(v_import.type_mask, type_plan_auto) = type_plan_auto and tml.type_code = 'PLAN'
					and exists (select 1 from study std where std.id=tml.study_id and std.project_id=v_project.id and is_timeline_auto_import=1)
				)
			);

			v_rowcount := v_rowcount + sql%rowcount;
			log_pkg.steps('c'||sql%rowcount,v_step_start,v_steps_result);

			/* load data */
			insert into import_timeline(
				import_id,
				project_id,
				timeline_id,
				reference_id,
				study_id,
				study_element_id,
				type_code,
				new_start_date,
				new_finish_date
			)
				select
					v_import.id as import_id,
					v_import.project_id as project_id,
					v_timeline_id as timeline_id,
					tml.scd2_key,
					tml.study_id,
					tml.study_element_id,
					tml.type_code,
					tml.start_date,
					tml.finish_date
				from sophia_timeline_tmp tml
				where tml.project_id = v_sophia_prj_id;

			v_rowcount := v_rowcount + sql%rowcount;
			log_pkg.steps('d'||sql%rowcount,v_step_start,v_steps_result);

			/* release tmp space */
			delete from sophia_timeline_tmp where project_id=v_sophia_prj_id;

			log_pkg.steps('END'||sql%rowcount,v_procedure_start,v_steps_result);
			log_pkg.log(v_where, 'p_id='||p_id||';rowcount='||v_rowcount||';source='||v_import.source, v_steps_result);

			return v_rowcount;--sql%rowcount;
		end;

	/*************************************************************************/
	function load_study(p_id in nvarchar2) return number
	as
		v_rowcount pls_integer:=0;
		v_sum_rowcount pls_integer:=0;
		v_where nvarchar2(99):='import_pkg.load_study';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;

	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		-- drop old log
		delete from import_study where project_id=v_import.project_id;

		v_rowcount := sql%rowcount;
		v_sum_rowcount := v_sum_rowcount + v_rowcount;
		log_pkg.steps('a'||v_rowcount,v_step_start,v_steps_result);

		-- drop old log
		delete from import_study_fte where project_id=v_import.project_id;

		v_rowcount := sql%rowcount;
		v_sum_rowcount := v_sum_rowcount + v_rowcount;
		log_pkg.steps('b'||v_rowcount,v_step_start,v_steps_result);

		-- load data
		insert into import_study
		(
			import_id,
			project_id,
			study_id,
			name,
			study_name,
			phase,
			phase_code,
			plan_patients,
			actual_patients,
			int_ext_flag,
			study_modus_no,
			study_modus_name,
			clin_plan_type,
			study_unit_count,
			study_unit_count_plan,
			therapeutic_group_code,
			therapeutic_group_desc,
			volunteer_flag,
			study_country_count,
			study_country_count_plan,
			subject_type,
			plan_entered_screen,
			act_entered_screen,
			budget_class,
			branch_flag
		)
		select
			v_import.id as import_id,
			v_project.id as project_id,
			st.study_id,
			st.study_id||': '||st.study_name,
			st.study_name,
			st.study_phase,
			st.study_phase_code,
			sp.plan_entered_trial,
			sp.act_entered_trial,
			sp.int_ext_flag,
			sp.study_modus_no,
			--decode(sp.study_id,'16502','2',sp.study_modus_no) study_modus_no,--TODO testing
			sp.study_modus_name,
			--decode(sp.study_id,'16502','Planned',sp.study_modus_name) study_modus_name,--TODO testing
			sp.clin_plan_type,
			sp.study_unit_count,
			sp.study_unit_count_plan,
			sp.therapeutic_group_code,
			sp.therapeutic_group_desc,
			sp.volunteer_flag,
			sp.study_country_count,
			sp.study_country_count_plan,
			sp.subject_type,
			sp.plan_entered_screen,
			sp.act_entered_screen,
			st.budget_class,
			sp.branch_flag
		from combase_study_vw st
		left join sophia_study_vw sp on (sp.project_id=v_project.code and sp.study_id=st.study_id)
		where v_project.code=st.project_id;

		v_rowcount := sql%rowcount;
		v_sum_rowcount := v_sum_rowcount + v_rowcount;
		log_pkg.steps('c'||v_rowcount,v_step_start,v_steps_result);

		insert into import_study_fte
		(
			import_id,
			project_id,
			study_id,
			function_id,
			year,
			month,
			fte
		)
		select
			v_import.id as import_id,
			v_project.id as project_id,
			study_id,
			function_id,
			year,
			month,
			fte
		from sophia_study_fte_vw
		where project_id=v_project.code
		and regexp_like(v_project.code, '^[[:digit:]]+$');--Sophia has data only for Projects that code is NUMBER

		v_rowcount := sql%rowcount;
		v_sum_rowcount := v_sum_rowcount + v_rowcount;
		log_pkg.steps('d'||v_rowcount,v_step_start,v_steps_result);

		update import_study i set is_placeholder = 1
		where import_id=v_import.id
		and is_placeholder<>1 --dont need to update twice
		and not exists (select * from costs where project_id=i.project_id and study_id=i.study_id)
		and not exists (select * from costs_fps where project_id=i.project_id and study_id=i.study_id);

		v_rowcount := sql%rowcount;
		v_sum_rowcount := v_sum_rowcount + v_rowcount;
		log_pkg.steps('e'||v_rowcount,v_step_start,v_steps_result);

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where, 'p_id='||p_id||';v_sum_rowcount='||v_sum_rowcount, v_steps_result);

		return v_sum_rowcount;

	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.scatch(v_where, 'p_id='||p_id||';v_sum_rowcount='||v_sum_rowcount, v_steps_result);
		raise;
	end;

	/*************************************************************************/
	function load_masterdata(p_id in nvarchar2) return number as
		v_rowcount number :=0;
		begin
			/* load temporary chunk of data */
			insert into sophia_project_tmp
				select md.*
				from sophia_project_vw md
				where
					md.project_id=v_project.code;

			insert into combase_project_tmp
				select md.*
				from combase_project_vw md
				where md.project_id=v_project.code;

			/* drop old log */
			delete from import_masterdata
			where project_id=v_import.project_id;

			/* load data */
			insert into import_masterdata(import_id,project_id,reference_id,development_phase_code)
				select
					v_import.id as import_id,
					v_import.project_id,
					md.scd2_key,
					md.le_overview
				from sophia_project_tmp md
				where md.project_id=v_project.code;

			merge into import_masterdata md
			using combase_project_tmp cb on (md.project_id=v_import.project_id)
			when matched then update set
				md.sbe_code=cb.sbe_code,
				md.gbu_code=cb.gbu_code,
				md.bay_code=cb.bay_code,
				md.ipowner_code=cb.ipowner_code,
				md.subgroup_code=cb.subgroup_code,
				md.successor_id=cb.successor_id,
				md.accounting_status_code=cb.accounting_status_code,
				md.program_code=cb.program_code,
				md.program_name=cb.program_name,
				md.planning_enabled_code=cb.planning_enabled_code,
				md.collaboration_code=cb.collaboration_code,
				md.project_group_code=cb.project_group_code
			when not matched then insert
			(
				import_id,
				project_id,
				sbe_code,
				gbu_code,
				bay_code,
				ipowner_code,
				subgroup_code,
				successor_id,
				accounting_status_code,
				program_code,
				program_name,
				planning_enabled_code,
				collaboration_code,
				project_group_code
			)
			values(
				v_import.id,
				v_import.project_id,
				cb.sbe_code,
				cb.gbu_code,
				cb.bay_code,
				cb.ipowner_code,
				cb.subgroup_code,
				cb.successor_id,
				cb.accounting_status_code,
				cb.program_code,
				cb.program_name,
				cb.planning_enabled_code,
				cb.collaboration_code,
				cb.project_group_code
			);

			v_rowcount := sql%rowcount;

			/* release tmp space */
			delete from combase_project_tmp where project_id=v_project.code;
			delete from sophia_project_tmp where project_id=v_project.code;

			return v_rowcount;
		end;

	/*************************************************************************/
	function load_headcount(p_id in nvarchar2) return number as
		begin
			/* load temporary chunk of data */
			insert into sophia_headcount_tmp
				select hd.*
				from sophia_headcount_vw hd
				where
					hd.demand is not null
					and hd.year between
					extract(year from v_import.create_date) - 1
					and extract(year from v_import.create_date) + 1;

			/* drop old log */
			delete from import_headcount
			where
				year between
				extract(year from v_import.create_date) - 1
				and extract(year from v_import.create_date) + 1;

			/* load data */
			insert into import_headcount(
				import_id,
				reference_id,
				subfunction_code,
				type_code,
				year,
				forecast_year,
				forecast_month,
				demand)
				select
					v_import.id as import_id,
					hd.scd2_key,
					hd.subfunction_id,
					hd.type_code,
					hd.year,
					hd.forecast_year,
					hd.forecast_month,
					hd.demand
				from sophia_headcount_tmp hd;

			/* release tmp space */
			delete from sophia_headcount_tmp;

			return sql%rowcount;
		end;

	/*************************************************************************/
	procedure do_loop(p_id in nvarchar2, p_code in nvarchar2, p_lookups in varchar2_table_typ)
	as
	begin
		for ndx in 1..p_lookups.count
		loop
			execute immediate get_text(p_code, varchar2_table_typ(p_lookups(ndx))) using p_id;
		end loop;
	end;

	/*************************************************************************/
	function load_lookups(p_id in nvarchar2) return number
	as
		v_where nvarchar2(222) := 'import_pkg.load_lookups';
		v_par nvarchar2(4000) := 'p_id=' || p_id ;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_rowcount number := 0;
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);
		do_loop
		(
			p_id,
			'begin delete from import_%1 where :1=:1; end;',
			varchar2_table_typ
				(
				'substance',
				'sbe',
				'bay_number',
				'bay_combination',
				'substance_combi',
				'smu',
				'ipowner',
				'topgroup',
				'maingroup',
				'subgroup',
				'bu'
				)
		);
		log_pkg.steps('a', v_step_start, v_steps_result);

		do_loop
		(
			p_id,
			'begin
				insert into import_%1(import_id,code,name,is_active)
				select import_id,code,name,is_active
				from (
					select
						:1 as import_id,
						code,
						name,
						is_active,
						row_number() over(partition by code order by modify_date desc) as rank
					from combase_%1_vw
				) where rank=1;
			end;',
			varchar2_table_typ
				(
					'substance',
					'bay_number',
					'bay_combination',
					'ipowner',
					'topgroup',
					'bu'
				)
		);
		log_pkg.steps('b', v_step_start, v_steps_result);

		insert into import_substance_combi(import_id,substance_code,combination_code,is_active)
		select import_id,substance_code,combination_code,is_active
		from (
			select
				p_id as import_id,
				substance_code,
				combination_code,
				is_active,
				row_number() over(partition by substance_code,combination_code order by modify_date desc) as rank
			from combase_substance_combi_vw
		) where rank=1;
		v_rowcount := sql%rowcount;
		log_pkg.steps('c' || v_rowcount, v_step_start, v_steps_result);

		insert into import_smu(import_id,code,substance_code,name,is_active)
		select import_id,code,substance_code,name,is_active
		from (
			select
				p_id as import_id,
				code,
				substance_code,
				name,
				is_active,
				row_number() over(partition by code order by modify_date desc) as rank
			from combase_smu_vw
		) where rank=1;
		v_rowcount := sql%rowcount;
		log_pkg.steps('d' || v_rowcount, v_step_start, v_steps_result);

		insert into import_maingroup(import_id,code,topgroup_code,name,is_active)
		select import_id,code,topgroup_code,name,is_active
		from (
			select
				p_id as import_id,
				code,
				topgroup_code,
				name,
				is_active,
				row_number() over(partition by code order by modify_date desc) as rank
			from combase_maingroup_vw
		) where rank=1;
		v_rowcount := sql%rowcount;
		log_pkg.steps('e' || v_rowcount, v_step_start, v_steps_result);

		insert into import_subgroup
			(
				import_id,
				correlation_id,
				code,
				maingroup_code,
				name,
				is_active
			)
		select
			import_id,
			correlation_id,
			code,
			maingroup_code,
			name,
			is_active
		from
		(
			select
				p_id as import_id,
				correlation_id,
				code code,
				maingroup_code,
				name,
				is_active,
				row_number() over(partition by code order by modify_date desc, is_active desc) as rank
			from combase_subgroup_vw
		) where rank=1;
		v_rowcount := sql%rowcount;
		log_pkg.steps('f' || v_rowcount, v_step_start, v_steps_result);

		insert into import_sbe(import_id,code,gbu_code,name,is_active)
		select import_id,code,gbu_code,name,is_active
		from (
			select
				p_id as import_id,
				code,
				gbu_code,
				name,
				is_active,
				row_number() over(partition by code order by modify_date desc) as rank
			from combase_sbe_vw
		) where rank=1;
		v_rowcount := sql%rowcount;
		log_pkg.steps('g' || v_rowcount, v_step_start, v_steps_result);

		begin
			insert into import_project_activity_name
			(
				import_id,
				project_activity_id,
				project_activity_name,
				is_active
			)
			select
				p_id as import_id,
				substr(project_activity_id,1,instr(project_activity_id||'_','_',1,1)-1) project_activity_id,
				nvl(project_activity_name, 'ERROR, the name is missing') project_activity_name,
				1
			from project_activities@sophia_db
			group by
				substr(project_activity_id,1,instr(project_activity_id||'_','_',1,1)-1),
				project_activity_name
			;
			v_rowcount := sql%rowcount;
			log_pkg.steps('h' || v_rowcount, v_step_start, v_steps_result);

		exception when others then --no critical error because old data will still remain
			notice_pkg.catch(v_where, v_par || ';' || v_steps_result || ';import_project_activity_name' );
		end;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result );

		return 1;

	exception when others then
		notice_pkg.catch(v_where, v_par || ';' || v_steps_result );
		return 0;
		--raise;
	end;

	/*************************************************************************/
	procedure launch(p_id in nvarchar2)
	as
		v_where nvarchar2(222):='import_pkg.launch.p';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		v_rowcount number := 0;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_tlid timeline.id%type;
		v_cnt number;
		--v_payload xmltype;
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);
		select * into v_import from import where id=p_id and status_code='NEW' and is_syncing=0;

		if v_import.source='FPS' then
			import_qplan_pkg.launch(p_id);
			return;
		end if;
		log_pkg.steps('a',v_step_start,v_steps_result);
		if v_import.project_id is not null then
			select * into v_project from project where id=v_import.project_id;
			v_msg_out:=v_msg_out||';v_project.code='||v_project.code;
		end if;

		-- Check timeline plan
		if bitand(v_import.type_mask, type_raw+type_project_activities) > 0 then
			v_msg := 'L1*_SELECT';
			if v_import.project_id is not null then
				v_msg := 'timeline;';
				begin
					v_tlid := get_timeline_id(v_import.id);
				exception when no_data_found then
					-- If project does not have timeline, all other data should be imported anyway IPMS-1023
					v_import.type_mask:=v_import.type_mask-import_pkg.type_plan;
					v_tlid:=null;
					notice_pkg.warning(get_subject, get_summary||' timeline skipped. It does not exist or is in syncing mode.');
				end;
			elsif v_import.sandbox_id is not null then
				v_msg := 'sandbox;';
				v_tlid := get_timeline_id(v_import.id);
			end if;

			log_performance('L1_SELECT');
			v_msg:=null;
		end if;

		log_pkg.steps('b',v_step_start,v_steps_result);

		/* load data */
		v_cnt := 0;
		v_msg:=null;

		if bitand(v_import.type_mask,type_lookups)=type_lookups then
			v_msg := 'L2*_lookups';
			v_cnt := v_cnt + load_lookups(p_id);
			log_performance('L2_lookups');
			v_msg:=null;
		end if;

		log_pkg.steps('c',v_step_start,v_steps_result);

		if bitand(v_import.type_mask,type_study)=type_study then
			v_msg := 'L3*_study';
			v_cnt := v_cnt + load_study(p_id);
			log_performance('L3_study');
			v_msg:=null;
		end if;

		log_pkg.steps('d',v_step_start,v_steps_result);

		if bitand(v_import.type_mask,type_masterdata)=type_masterdata then
			v_msg := 'L4*_master';
			v_cnt := v_cnt + load_masterdata(p_id);
			log_performance('L4_master');
			v_msg:=null;
		end if;

		log_pkg.steps('e',v_step_start,v_steps_result);

		if bitand(v_import.type_mask,type_costs)=type_costs then
			v_msg := 'L5*_costsX';
			--skip when AREA is null or Research
			if nvl(v_project.area_code,'RS')='RS' then
				null;
			else
				if import_pkg.is_reload_costs=1 then
					v_cnt := v_cnt + import_costs_pkg.load_costs(p_id);
				end if;
				v_cnt := v_cnt + import_costs_pkg.load_costs_fps(p_id);
			end if;
			log_performance('L5_costsX');
			v_msg:=null;
		end if;

		log_pkg.steps('f',v_step_start,v_steps_result);

		if bitand(v_import.type_mask,type_headcount)=type_headcount then
			v_msg := 'L6*_headcount';
			v_cnt := v_cnt + load_headcount(p_id);
			log_performance('L6_headcount');
			v_msg:=null;
		end if;

		log_pkg.steps('g',v_step_start,v_steps_result);

		if bitand(v_import.type_mask,type_resources)=type_resources then
			v_msg := 'L7*_resources';
			v_cnt := v_cnt + import_resources_pkg.load_resources(p_id);
			v_cnt := v_cnt + import_resources_pkg.load_resources_cs(p_id);
			v_cnt := v_cnt + import_resources_pkg.load_resources_ged(p_id);
			log_performance('L7_resources');
			v_msg:=null;
		end if;

		log_pkg.steps('h',v_step_start,v_steps_result);

		if bitand(v_import.type_mask,type_actuals+type_plan+type_plan_auto)>0 then
			v_msg := 'L8*_timeline';
			v_cnt := v_cnt + load_timeline(p_id);
			log_performance('L8_timeline');
			v_msg:=null;
		end if;

		log_pkg.steps('i',v_step_start,v_steps_result);

		if bitand(v_import.type_mask,type_project_activities)>0 then
			v_msg := 'L9*_project_activities';
			v_cnt := v_cnt + project_activities_pkg.import_load(v_import);
			log_performance('L9*_project_activities');
			v_msg:=null;
		end if;

		log_pkg.steps('m',v_step_start,v_steps_result);

		-- validate load results
		if v_cnt = 0 then
			update import set status_code=decode(is_manual,0,'VOID','DONE') where id=p_id;
			return;
		end if;

		log_performance('L10_UPDATE');
		log_pkg.steps('j',v_step_start,v_steps_result);
		/* start process */
		if v_tlid is not null then
			dbms_lock.sleep(configuration_pkg.get_config_number('IMP-SLEEP')); --only wait when SOA is beaing called
			timeline_pkg.receive(v_tlid, 'begin import_pkg.merge('''||p_id||''',:1); end;');

			update import set is_syncing=1 where id=p_id;
			/*
				select
				xmltype('<?xml version="1.0" encoding="UTF-8"?><response id="0" xmlns="http://xmlns.bayer.com/ipms/soa"><complete id="0"></complete></response>')
				into v_payload
				from dual;
				import_pkg.merge(p_id,v_payload);
			*/
			log_performance('11A_timelineSOA');
			log_pkg.steps('k',v_step_start,v_steps_result);
		else
			--merge(p_id, null);
			--some projects AREA do not have timeline, so, merge package validates payload, if empty then throws an error.
			merge(p_id, xmltype('<?xml version="1.0" encoding="UTF-8"?><response id="1" '||message_pkg.xmlns_ipms_soa||'><complete id="1"/></response>'));
			--logging moved to down to "merge" log_performance('11B_timelineSOA');
			log_pkg.steps('l',v_step_start,v_steps_result);
		end if;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where,v_par,v_steps_result);

	exception when others then
		v_error:=substr(v_msg||';launch();sqlerrm='||sqlerrm,1,4000);

		update import set status_code='FAIL', timestamp_log=substr(timestamp_log||v_error,1,4000) where id=p_id;
		notice_pkg.catch(get_subject, get_summary||v_msg||' start failed.');
	end;

	/*************************************************************************/
	function launch
		(
			p_project_id in nvarchar2,
			p_import_type in number,
			p_is_manual in number := 0
		) return nvarchar2
	as
		v_id import.id%type;
		v_type_project pls_integer:= type_project;
		v_where nvarchar2(99):='import_pkg.launch.f';
		v_par nvarchar2(4000):='p_project_id='||p_project_id||';p_import_type='||p_import_type||';p_is_manual='||p_is_manual;
		v_msg_out nvarchar2(4000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;

	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		if p_import_type = type_plan_auto then --p_import_type=2048 --- means that DB user is starting the script from SQLDev and wants exacly 2048, thus check one more time global settings
			if configuration_pkg.get_config_value('AUTOIMPORT')=1 then --PROMISiii-82
				v_type_project:= v_type_project + type_plan_auto;
			end if;
		end if;

		insert into import
		(
			project_id,
			type_mask,
			job_id,
			source,
			is_manual
		)
		values
			(
				decode(bitand(p_import_type,bitor(v_type_project,type_plan)),0,null,p_project_id),
				p_import_type,
				v_job_id,
				'CMBS', --COMBASE
				p_is_manual
			)
		returning id into v_id;

		ba_log_pkg.put_guid(v_guid,null,null);

		launch(v_id);

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where,v_par||';import_id='||v_id||';v_type_project='||v_type_project||';is_reload_costs='||import_pkg.is_reload_costs,v_steps_result);

		return v_id;
	end;

	/*************************************************************************/
	procedure launch_all
	as
		v_id import.id%type;
		v_program_id nvarchar2(20);
		v_tbody xmltype;
		v_where nvarchar2(99):='import_pkg.launch_all';
		v_type_project pls_integer:= type_project;
		v_area_code nvarchar2(99);
		v_user nvarchar2(99):='PROMIS';
	begin
		if configuration_pkg.get_config_value('AUTOIMPORT')=1 then --PROMISiii-82
			v_type_project:= v_type_project + type_plan_auto;
		end if;

		--create unique import Job Id
		select import_id_seq.nextval into v_job_id from dual;
		v_guid:=ba_log_pkg.generate_guid;
		ba_log_pkg.put_guid(v_guid,'PROMIS', v_where);

		--Refresh MVIEW for Discrepancies, based on this table=mview discrepancies are filtered only to the studies that exists in Combase and Sophia.
		discrepancies_pkg.refresh_dis_study_mview;
		-- refresh COSTS_VW for better IMPORT perfromance
		import_costs_pkg.refresh_costs_vw_merge;
		import_resources_pkg.merge_sophia_all_resources;
		set_max_forecast;
		log_pkg.log(v_where, 'Views refreshed.','discrepancies_pkg.refresh_dis_study_mview and import_costs_pkg.refresh_costs_vw_merge');
		ba_log_pkg.put_guid(v_guid,null,null);
		commit;

		-- general import
		v_id := launch(null, type_global);
		log_pkg.log(v_where, 'lunch()','launch finished.');
		ba_log_pkg.put_guid(v_guid,null,null);
		commit;

		begin
			-- add missing projects
			-- During PROJECT import, use <<virtual>> PROGRAM_ID where program.code='RESERVED-PT-UNT'
			select id into v_program_id from program where code='RESERVED-PT-UNT';

			insert into project (code,name,program_id,is_active)
				select code, name, v_program_id,1 --> only Active projects could be imported, if exists in the view, means active
				from combase_project_name_vw
				where code in (
					select code
					from combase_project_name_vw
					--where modify_date>=to_date('2014-12-01','yyyy-mm-dd')
					minus
					select distinct to_char(code)
					from project where code is not null
					--and modify_date>=to_date('2014-12-01','yyyy-mm-dd')
				);
			ba_log_pkg.put_guid(v_guid,null,null);
			commit;
			exception when OTHERS then
			log_pkg.scatch(v_where, 'v_job_id='||v_job_id,'OTHERS.Insert New projects.');
		end;

		-- ... and only now, after making insert of missing projects -> full project data import must be run
		-- project level import
		v_tbody := notify_pkg.get_import_msg_for_skipped_prj(v_import.type_mask);
		log_pkg.log(v_where, 'get_import_msg_for_skipped_prj','Finished.');
		for prj in
		(-- collect target projects
		select
			prj.id,
			prj.code,
			prj.area_code
		from project prj
		where prj.is_syncing = 0 -- project is unlocked
					--and prj.area_code is not null ---TESTING TODO remove, allow all projects to be updated
					and prj.program_id != 'RBIN' --skip deleted projects
					and prj.code is not null
					and (
						bitand(v_import.type_mask, type_raw) = 0 -- timeline is unlocked
						or
						not exists(select tl.id from timeline tl where tl.project_id = prj.id and tl.is_syncing = 1)
						-- no running import for the project atm
					)
					--2016-01-20 based on PROD e-mails, project should be imported even if the import not finished but for different type_mask
					and not exists (select * from import where project_id = prj.id and status_code in ('NEW','READY','SEND') and type_mask=v_import.type_mask)
					and nvl(prj.area_code,'X')!='D1' --D1 projects are being imported with a different procedure
		--in case of import performance problems, at first IMPORT: Dev, then MNT, D2, D3, ...
		order by decode(prj.area_code,'PRE-POT','A1','POST-POT','A2','PRD-MNT','A3','D2-PRJ','A4','D3-TR','A5', 'SAMD','A6', prj.area_code), prj.id--PROMIS 604
		) loop
			begin
				v_id := launch(prj.id, v_type_project);
				exception when others then
				-- skip failed startups
				log_pkg.scatch(v_where,'import:0','Import of Project[' || prj.id || ',' || nvl(prj.code,'-') || '] setup failed.');
			end;

			if v_area_code is null then --just the begining, the very first run. do nothing
				null;
			else
				if v_area_code<>prj.area_code then--means one phase/step has just finished, thus log with the last know area code
					v_guid:=ba_log_pkg.generate_guid;
					ba_log_pkg.put_guid(v_guid,v_user,'importareacode'||replace(lower(v_area_code),'-'),null,null,'DONE',null,1,null);
				end if;
			end if;

			if prj.area_code is not null then
				v_area_code:=prj.area_code;
				--mark import
				begin
					update project_area set is_running_import='YES'
					where code=v_area_code
								and is_running_import<>'YES';
					exception when others then
					update project_area set is_running_import=code
					where is_running_import<>code;

					update project_area set is_running_import='YES'
					where code=v_area_code
								and is_running_import<>'YES';
				end;
			end if;

			ba_log_pkg.put_guid(v_guid,null,null);
			commit;
		end loop;

		--just in case, clean running state.
		update project_area set is_running_import=code
		where is_running_import<>code;
		log_pkg.log(v_where, 'Finished main loop.','Finished.');

		--------------------------------------------------------------------
		--BAY_PROMIS-11;Automatic Study Import
		--after study part is done, after all import run all list of timline import
		--it must be done after study is fully imported, because only then we know wbs_id
		for rr in
		(
		select
			id,
			project_id
		from import
		where job_id=v_job_id
					and status_code='NEW'
					and type_mask=import_pkg.type_plan_auto
		order by project_id
		)
		loop
			begin
				launch(rr.id);
				exception when others then
				log_pkg.scatch(v_where,'import:timeline','import_id='||rr.id||';project_id='||rr.project_id);
			end;
			ba_log_pkg.put_guid(v_guid,null,null);
			commit;
		end loop;

		--------------------------------------------------------------------
		--After all import is Done, do Project name synchornization with COMBASE
		-- BUT only with the Projects that originaly have source at COMBASE
		begin
			for rr in (
			select *
			from (
				select
					prj.id, prj.area_code, prj.code, prj.name, cm.name cm_name, prj.sync_date
				from project prj
					join combase_project_name_vw cm on (prj.code=cm.code)
				where nvl(prj.area_code,'#####') NOT in ('PRE-POT','POST-POT','D2-PRJ','D1','SAMD')--PROMIS 604
			)
			where replace(upper(name),' ')<>replace(upper(cm_name),' ')
			)
			loop
				update project set name=rr.cm_name where id=rr.id and name<>rr.cm_name;
				--SYNC with P6 only if it was sync at least once before
				if rr.sync_date is not null then
					project_pkg.send(rr.id);
					dbms_lock.sleep(2);
				end if;

				ba_log_pkg.put_guid(v_guid,null,null);
				commit;
			end loop;

		exception when others then --LOG and continue next steps
			log_pkg.log(v_where, 'OTHERS.Loop for diff PROJECT names.',sqlerrm);
		end;
		--------------------------------------------------------------------
		-- Notify (e-mail) about Import's skipped or failed projects (if any).
		log_pkg.log(v_where, 'Finished second loop.','Finished.');
		v_tbody := notify_pkg.get_import_msg_for_failed_prj(v_import.type_mask,v_tbody,v_job_id);
		log_pkg.log(v_where, 'Finished. get_import_msg_for_failed_prj.','Finished.');
		v_tbody := notify_pkg.get_running_soa(v_import.type_mask,v_tbody,v_job_id);
		log_pkg.log(v_where, 'Finished.get_running_soa.','Finished.');
		notify_pkg.import_failed(v_tbody);
		log_pkg.log(v_where, 'Finished.import_failed.','Finished.');
		ba_log_pkg.put_guid(v_guid,null,null);

	end;

	/*************************************************************************/
	function merge_masterdata(p_id in nvarchar2) return number
	as
		v_status_description nvarchar2(500);
		v_num pls_integer;
		begin
			update import_masterdata md
			set md.status_code='FAIL',
				md.status_description='Invalid'||
															nvl2(md.development_phase_code, ' development phase code ('||md.development_phase_code||')',null)||
															nvl2(md.sbe_code,' or SBE code ('||md.sbe_code||')',null)||
															nvl2(md.gbu_code,' or GBU code ('||md.gbu_code||')',null)||
															nvl2(md.bay_code,' or BAY code ('||md.bay_code||')',null)||
															nvl2(md.ipowner_code,' or IPOWNER code ('||md.ipowner_code||')',null)||
															nvl2(md.subgroup_code,' or SUBGROUP code ('||md.subgroup_code||')',null)
			where
				import_id=p_id and status_code='NEW'
				and (not exists(select 1 from development_phase dp where dp.code=md.development_phase_code) and md.development_phase_code is not null
						 or not exists(select 1 from strategic_business_entity sbe where sbe.code=md.sbe_code) and md.sbe_code is not null
						 or not exists(select 1 from global_business_unit gbu where gbu.code=md.gbu_code) and md.gbu_code is not null
						 or not exists(select 1 from bay_number bn where bn.code=md.bay_code) and md.bay_code is not null
						 or not exists(select 1 from ipowner ip where ip.code=md.ipowner_code) and md.ipowner_code is not null
						 or not exists(select 1 from project_category pc where pc.code=md.subgroup_code) and md.subgroup_code is not null
				);
			--successor_id is not needed to check, it is just view atribute of the Project
			--program_code -> no need to be checked, acts only as supporting attribut during typification
			--planning_enabled_code -> no need to be checked

			--analyze exact errors
			for ff in (select * from import_masterdata where import_id=p_id and status_code='FAIL')
			loop
				v_status_description := null;
				if ff.development_phase_code is not null then
					begin
						select 1 into v_num from development_phase dp where dp.code=ff.development_phase_code;
						exception when others then
						v_status_description := v_status_description||' development phase code ('||ff.development_phase_code||')';
					end;
				end if;

				if ff.sbe_code is not null then
					begin
						select 1 into v_num from strategic_business_entity sbe where sbe.code=ff.sbe_code;
						exception when others then
						v_status_description := v_status_description||' SBE code ('||ff.sbe_code||')';
					end;
				end if;

				if ff.gbu_code is not null then
					begin
						select 1 into v_num from global_business_unit gbu where gbu.code=ff.gbu_code;
						exception when others then
						v_status_description := v_status_description||' GBU code ('||ff.gbu_code||')';
					end;
				end if;

				if ff.bay_code is not null then
					begin
						select 1 into v_num from bay_number bn where bn.code=ff.bay_code;
						exception when others then
						v_status_description := v_status_description||' BAY code ('||ff.bay_code||')';
					end;
				end if;

				if ff.ipowner_code is not null then
					begin
						select 1 into v_num from ipowner ip where ip.code=ff.ipowner_code;
						exception when others then
						v_status_description := v_status_description||' IPOWNER code ('||ff.ipowner_code||')';
					end;
				end if;

				if ff.subgroup_code is not null then
					begin
						select 1 into v_num from project_category pc where pc.code=ff.subgroup_code;
						exception when others then
						v_status_description := v_status_description||' SUBGROUP code ('||ff.subgroup_code||')';
					end;
				end if;

				if v_status_description is not null then
					update import_masterdata prj
					set status_description='Invalid '||v_status_description
					where import_id=p_id and project_id=ff.project_id;
				end if;

			end loop;

			update import_masterdata prj
			set status_code='READY'
			where import_id=p_id and status_code='NEW';

			return sql%rowcount;
		end;

	/*************************************************************************/
	function merge_headcount(p_id in nvarchar2) return number as
		begin
			update import_headcount hd
			set
				status_code='FAIL',
				status_description='Invalid subfunction: '||hd.subfunction_code
			where
				import_id=p_id and status_code='NEW'
				and not exists(select * from subfunction sf where sf.code=hd.subfunction_code);

			update import_headcount hd
			set status_code='READY'
			where import_id=p_id and status_code='NEW';

			return sql%rowcount;
		end;

	/*************************************************************************/
	function merge_lookups(p_id in nvarchar2) return number
	as
		v_where nvarchar2(222) := 'import_pkg.merge_lookups';
		v_par nvarchar2(4000) := 'p_id=' || p_id ;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_rowcount number := 0;
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);
		do_loop
		(
			p_id,
			'begin
				update import_%1
				set status_code=''READY''
				where import_id=:1 and status_code=''NEW'';
			end;',
			varchar2_table_typ
			(
				'substance',
				'sbe',
				'bay_number',
				'bay_combination',
				'ipowner',
				'topgroup',
				'bu'
			)
		);
		log_pkg.steps('a', v_step_start, v_steps_result);

		update import_smu smu
		set
			status_code='FAIL',
			status_description='Invalid substance: '||smu.substance_code
		where import_id=p_id and status_code='NEW'
		and not exists(select 1 from import_substance sf where sf.code=smu.substance_code)
		and not exists(select 1 from substance sf where sf.code=smu.substance_code);
		v_rowcount := sql%rowcount;
		log_pkg.steps('b' || v_rowcount, v_step_start, v_steps_result);

		update import_smu smu
		set status_code='READY'
		where import_id=p_id
		and status_code='NEW';
		v_rowcount := sql%rowcount;
		log_pkg.steps('c' || v_rowcount, v_step_start, v_steps_result);

		update import_substance_combi cb
		set
			status_code='FAIL',
			status_description='Invalid substance: '||cb.substance_code
		where import_id=p_id
		and status_code='NEW'
		and not exists(select 1 from import_substance sf where sf.code=cb.substance_code)
		and not exists(select 1 from substance sf where sf.code=cb.substance_code);
		v_rowcount := sql%rowcount;
		log_pkg.steps('d' || v_rowcount, v_step_start, v_steps_result);

		update import_substance_combi cb
		set
			status_code='FAIL',
			status_description='Invalid combination: '||cb.combination_code
		where import_id=p_id
		and status_code='NEW'
		and not exists(select 1 from import_bay_combination sf where sf.code=cb.combination_code)
		and not exists(select 1 from bay_number sf where sf.code=cb.combination_code);
		v_rowcount := sql%rowcount;
		log_pkg.steps('e' || v_rowcount, v_step_start, v_steps_result);

		update import_substance_combi cb
		set status_code='READY'
		where import_id=p_id
		and status_code='NEW';
		v_rowcount := sql%rowcount;
		log_pkg.steps('f' || v_rowcount, v_step_start, v_steps_result);

		update import_maingroup mg
		set
			status_code='FAIL',
			status_description='Invalid topgroup: '||mg.topgroup_code
		where import_id=p_id
		and status_code='NEW'
		and not exists(select 1 from import_topgroup img where img.code=mg.topgroup_code)
		and not exists(select 1 from topgroup tg where tg.code=mg.topgroup_code);
		v_rowcount := sql%rowcount;
		log_pkg.steps('g' || v_rowcount, v_step_start, v_steps_result);

		update import_maingroup mg
		set status_code='READY'
		where import_id=p_id
		and status_code='NEW';
		v_rowcount := sql%rowcount;
		log_pkg.steps('h' || v_rowcount, v_step_start, v_steps_result);

		update import_subgroup sg
		set
			status_code='FAIL',
			status_description='Invalid maingroup: '||sg.maingroup_code
		where import_id=p_id
		and status_code='NEW'
		and sg.maingroup_code is not null
		and not exists(select 1 from import_maingroup img where img.code=sg.maingroup_code)
		and not exists(select 1 from maingroup mg where mg.code=sg.maingroup_code);
		v_rowcount := sql%rowcount;
		log_pkg.steps('i' || v_rowcount, v_step_start, v_steps_result);

		update import_subgroup sg
		set status_code='READY'
		where import_id=p_id
		and status_code='NEW';
		v_rowcount := sql%rowcount;
		log_pkg.steps('j' || v_rowcount, v_step_start, v_steps_result);

		begin
			update import_project_activity_name
			set status_code='READY'
			where import_id=p_id
			and status_code='NEW';

			v_rowcount := sql%rowcount;
			log_pkg.steps('k' || v_rowcount, v_step_start, v_steps_result);

		exception when others then --no critical error because old data will still remain
			notice_pkg.catch(v_where, v_par || ';' || v_steps_result || ';import_project_activity_name' );
		end;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result );

		return 1;

	exception when others then
		notice_pkg.catch(v_where, v_par || ';' || v_steps_result );
		--return 0;
		raise;
	end;

	/*************************************************************************/
	function merge_timeline(p_id in nvarchar2) return number
	as
		--v_cnt number;
		v_timeline_id timeline.id%type;
		v_rowcount pls_integer:=0;
		v_where nvarchar2(99):='import_pkg.merge_timeline';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);
		v_timeline_id := get_timeline_id(p_id);

		/* drop old unmatched entries */
		delete from import_timeline where import_id=p_id and status_code='OLD';
		v_rowcount := v_rowcount + sql%rowcount;

		/* reset status for the rest */
		update import_timeline set status_code='NEW' where status_code='READY' and import_id=p_id;
		v_rowcount := v_rowcount + sql%rowcount;
		log_pkg.steps('a',v_step_start,v_steps_result);

		/* merge activities: update dates for matched, insert rows for unmatched */
		merge into import_timeline tm
		using (
						select
							imp.id as import_id,
							ta.project_id,
							ta.timeline_id,
							max(ta.activity_id) as activity_id,
							ta.study_element_id,
							ts.study_id,
							max(ta.parent_wbs_id) as parent_wbs_id,
							max(ta.code) as code,
							max(ta.name) as name,
							max(ta.type) as type,
							max(ta.plan_start) as plan_start,
							max(ta.plan_finish) as plan_finish,
							max(ta.actual_start) as actual_start,
							max(ta.actual_finish) as actual_finish,
							count(1) as cnt
						from import imp
							join timeline_activity ta on ta.timeline_id=v_timeline_id and lower(ta.integration_type)='auto'
							left join study_vw ts on ta.timeline_id=ts.timeline_id and ts.wbs_id=ta.parent_wbs_id
						where imp.id=p_id
						group by imp.id, ta.project_id, ta.timeline_id, ts.study_id, ta.study_element_id
					) xs
		on (
			tm.import_id=xs.import_id
			and tm.timeline_id=xs.timeline_id
			and tm.study_element_id=xs.study_element_id
			and nvl(tm.study_id,'-')=nvl(xs.study_id,'-')
		)
		when matched then
		update set
			tm.parent_wbs_id=decode(xs.cnt,1,xs.parent_wbs_id,null),
			tm.activity_id=decode(xs.cnt,1,xs.activity_id,null),
			tm.status_code=decode(xs.cnt,1,'READY','FAIL'),
			tm.action_code=decode(xs.cnt,1,decode(tm.type_code,'PLAN',decode(v_import.is_manual,1,'SKIP',tm.action_code),tm.action_code),null),
			tm.code=decode(xs.cnt,1,xs.code,null),
			tm.name=decode(xs.cnt,1,xs.name,null),
			tm.activity_type=decode(xs.cnt,1,xs.type,null),
			tm.old_start_date=decode(xs.cnt,1,decode(tm.type_code,'ACT',xs.actual_start,xs.plan_start),null),
			tm.old_finish_date=decode(xs.cnt,1,decode(tm.type_code,'ACT',xs.actual_finish,xs.plan_finish),null),
			tm.status_description=decode(xs.cnt,1,null,'Duplicate study element: '||tm.study_id||'-'||tm.study_element_id)
		when not matched then
		insert(
			tm.import_id,
			tm.project_id, tm.timeline_id,
			tm.study_id, tm.study_element_id,
			tm.parent_wbs_id, tm.activity_id,
			tm.status_code,
			tm.name,tm.code,tm.activity_type,
			tm.old_start_date,tm.old_finish_date)
		values(
			p_id,
			xs.project_id, xs.timeline_id,
			xs.study_id, xs.study_element_id,
			xs.parent_wbs_id, xs.activity_id,
			'OLD',
			xs.name,xs.code,xs.type,
			xs.plan_start,
			xs.plan_finish)
		where bitand(v_import.type_mask, type_plan)=type_plan and xs.cnt=1;

		v_rowcount := v_rowcount + sql%rowcount;
		log_pkg.steps('b',v_step_start,v_steps_result);

		--v_cnt := sql%rowcount;

		/* drop unmodified */
		update import_timeline
		set
			status_code = 'OLD',
			action_code = null
		where
			import_id = p_id
			and status_code = 'READY'
			and trunc(nvl(old_start_date,sysdate)) = trunc(nvl(new_start_date,sysdate))
			and trunc(nvl(old_finish_date,sysdate)) = trunc(nvl(new_finish_date,sysdate));

		v_rowcount := v_rowcount + sql%rowcount;
		log_pkg.steps('c',v_step_start,v_steps_result);

		/* update unmatched importing activities */
		update import_timeline tm
		set
			status_code='FAIL',
			status_description='Invalid study element: '||tm.study_id||'-'||tm.study_element_id
		where import_id=p_id and status_code='NEW';

		v_rowcount := v_rowcount + sql%rowcount;
		log_pkg.steps('d',v_step_start,v_steps_result);

		/* merge wbs in case of plan import */
		insert into import_timeline(import_id, project_id, timeline_id, parent_wbs_id, wbs_id, study_id, sequence_number, code, name, status_code, old_start_date, old_finish_date)
			select p_id, tw.project_id, tw.timeline_id, tw.parent_wbs_id, tw.wbs_id, tw.study_id, tw.sequence_number, tw.code, tw.name, 'OLD', tw.start_date, tw.finish_date
			from import imp
				join timeline_wbs tw on tw.timeline_id=v_timeline_id
			where imp.id=p_id and bitand(imp.type_mask,type_plan)=type_plan;

		v_rowcount := v_rowcount + sql%rowcount;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'p_id='||p_id||';rowcount='||v_rowcount, v_steps_result);

		--v_cnt := v_cnt + sql%rowcount;
		return v_rowcount;--v_cnt;
	end;

	/*************************************************************************/
	procedure set_study_parent_wbs_id(p_id in nvarchar2)
	as
		v_rowcount pls_integer:=0;
		v_where nvarchar2(99):='import_pkg.set_study_parent_wbs_id';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		v_loop_msg_out nvarchar2(4000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		v_fpfv_date date;
		v_wbs_id nvarchar2(222);
		v_study_tmp_id nvarchar2(222);

	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		if configuration_pkg.get_config_number('STUDY-AUTO-IMPORT')=1 then
			begin
				select id into v_study_tmp_id
				from study_template
				where replace(lower(name),' ')=replace(lower(configuration_pkg.get_config_value('DEFAULT-STUDY-TEMPLATE')),' ')
							and is_active=1;

				--try to find missing wbs_id in order to perform automatic import for those studies (see other limitation in "where" statement)
				for rr in
				(
				select
					ims.id ims_id,
					tw.wbs_id top_wbs_id, --parent_wbs_id is null, means here we get TOP plan node
					prj.code project_code,
					ims.study_id,
					ims.project_id
				from import_study ims
					join project prj on prj.id=ims.project_id
					left join study stu on (stu.id=ims.study_id)
					join project prj on (ims.project_id=prj.id)
					left join import_study_target_wbs_vw tw on (tw.project_id=ims.project_id and tw.timeline_type_code='RAW' and tw.parent_wbs_id is null)
				where ims.import_id=p_id
							--and ims.project_id in ('29-12','95-145') --TODO:BAY_PROMIS-11 remove after testing, now it is just for blocking the STUDY auto import
							and prj.is_active=1 and prj.area_code in ('PRE-POT','POST-POT') and prj.is_portfolio = 1 -- BAY_PROMIS-315: Limit Automatic Study Import to Active Development Projects with Portfolio status
							and ims.wbs_id is null --means: still not imported to P6
							and ims.study_modus_no=2 --BAY_PROMIS-11: Studies of status "planned" (BAY_PROMIS-306) should automatically be imported by default!
							and nvl(stu.is_study_auto_import,1)=1 --after deleting study at P6 it must be set to: 0 thus this flag msut be always validated
				)
				loop
					begin
						v_loop_msg_out:=null;
						v_wbs_id :=null;
						v_fpfv_date :=null;

						--At first, chcek if FPFV date exists at all
						begin
							select max(nvl(nvl(nvl(dsm.act_start_date,dsm.plan_start_date),dsm.act_finish_date),dsm.plan_finish_date))
							into v_fpfv_date
							from dis_study_mview dsm
								join configuration cf on (cf.code='FPFV' and cf.value=dsm.study_element_id)--study_element_id=3200
							where dsm.project_id=rr.project_code
										and dsm.study_id=rr.study_id
							;

							exception
							when no_data_found then
							v_fpfv_date:=null;
							when others then
							v_fpfv_date:=null;
							v_loop_msg_out:=v_loop_msg_out||';SELECT.FPFV.OTHERS;'||sqlerrm;
						end;

						if v_fpfv_date is not null then --try to find using v_fpfv_date
							--try to set: v_wbs_id that will used as parent WBS for imported study

							/*
			  --info: BAY_PROMIS-11
			  Compare the FPFV of the study with the development milestones for the project (according to the defined phase milestones in ProMIS).
			  Identify the relevant WBS node in Primavera based on the Project Category. Always take the topmost node in the hierarchy to which the WBS Category is assigned.
			  The study will be displayed below the identified node in the RAW-Plan.
			  If no FPFV exists, enter study below the top node
			*/
							begin

								select wbs_id
								into v_wbs_id
								from (
									select
										level,
										cat.wbs_category,
										wbs.wbs_id
									from timeline_wbs wbs
										left join (
																select
																	wca.wbs_id,
																	mls.wbs_category
																from ltc_milestone_phase_vw mph
																	join milestone mls on mls.code = mph.milestone_code and mls.is_active = 1 and mls.type_code = 'DEV'
																	join timeline_wbs_category wca
																		on wca.timeline_id = rr.project_id || '-RAW' and wca.category_name = mls.wbs_category
																where mph.timeline_id = rr.project_id || '-RAW'
																			and v_fpfv_date between mph.start_date and nvl(mph.finish_date,v_fpfv_date)
															) cat on cat.wbs_id = wbs.wbs_id
									where wbs.timeline_id = rr.project_id || '-RAW'
									connect by wbs.parent_wbs_id = prior wbs.wbs_id
									start with wbs.parent_wbs_id is null
									order by level, wbs_id
								)
								where wbs_category is not null and rownum = 1;

								exception when others then
								null;
							end;
						end if;

						if v_wbs_id is not null or rr.top_wbs_id is not null then
							--If no FPFV exists, enter study below the top node
							update import_study set
								parent_wbs_id=nvl(v_wbs_id,rr.top_wbs_id),
								wbs_id='#new#',
								fpfv_date=v_fpfv_date,
								--action_code='SKIP', --not needed to set action_cde at all
								study_template_id=v_study_tmp_id
							where id=rr.ims_id;
							v_rowcount:=v_rowcount+1;
						end if;

						if v_loop_msg_out is not null then--log action for every row
							log_pkg.slog(v_where, v_par, v_steps_result||';LOOP;rr.study_id='||rr.study_id||';'||v_loop_msg_out,'WARNING');
						end if;
						exception when others then
						log_pkg.scatch(v_where, v_par, v_steps_result||';LOOP.OTHERS;rr.study_id='||rr.study_id||';'||v_loop_msg_out);
					end;
				end loop;

				exception when others then
				log_pkg.scatch(v_where, v_par, v_steps_result||';TMP.OTHERS');
			end;
		end if;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where, v_par, v_steps_result||';v_rowcount='||v_rowcount||';'||v_loop_msg_out);

	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result||';v_rowcount='||v_rowcount||';'||v_loop_msg_out);
		raise;
	end;

	/*************************************************************************/
	function merge_study(p_id in nvarchar2) return number
	as
		v_timeline_id timeline.id%type;
		v_cnt number;
		v_rowcount pls_integer:=0;
		v_where nvarchar2(99):='import_pkg.merge_study';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		v_loop_msg_out nvarchar2(4000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;

	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		--at first check if it at all makes sence to do costly select to XML type
		select count(1)
		into v_cnt
		from timeline t
		where t.project_id=v_project.id
					and type_code='RAW';

		if v_cnt > 0 then
			-- merge studies: set wbs_id
			merge into import_study std
			using (
							select
								imp.id as import_id,
								ts.project_id,
								ts.study_id,
								max(ts.wbs_id) as wbs_id,
								min(ts.placeholder) as is_placeholder,
								max(stdv.is_gpdc_approved) as is_gpdc_approved,
								max(stdv.is_obligation) as is_obligation,
								max(stdv.is_probing) as is_probing,
								count(*) as cnt
							from import imp
								join study_vw ts on ts.hlevel=1 and ts.project_id=imp.project_id and ts.timeline_type_code='RAW'
								left join study_data_vw stdv on stdv.project_id=ts.project_id and stdv.timeline_id=ts.timeline_id and stdv.wbs_id=ts.wbs_id
							where imp.id=p_id
							group by imp.id,ts.project_id,ts.study_id
						) xs
			on (
				std.import_id=xs.import_id
				and std.project_id=xs.project_id
				and std.study_id=xs.study_id
			)
			when matched then update set
				std.wbs_id=decode(xs.cnt,1,xs.wbs_id,null),
				std.is_placeholder=xs.is_placeholder,
				std.is_gpdc_approved=xs.is_gpdc_approved,
				std.is_obligation=xs.is_obligation,
				std.is_probing=xs.is_probing,
				std.status_code=decode(xs.cnt,1,'READY','FAIL'),
				std.status_description=decode(xs.cnt,1,null,'Duplicate study:'||std.study_id)
			where std.status_code='NEW';

			v_rowcount := sql%rowcount;
			log_pkg.steps('a'||v_rowcount,v_step_start,v_steps_result);

		end if;

		if v_import.is_manual=1 then
			-- Manual import will skip all new studies as a default
			update import_study set status_code = 'OLD'
			where import_id=p_id
						and wbs_id is not null;

			v_rowcount := sql%rowcount;
			log_pkg.steps('b'||v_rowcount,v_step_start,v_steps_result);

			update import_study set status_code = 'READY', action_code='SKIP'
			where import_id=p_id
						and status_code in ('NEW', 'READY');

			v_rowcount := sql%rowcount;
			log_pkg.steps('c'||v_rowcount,v_step_start,v_steps_result);
		else
			--BAY_PROMIS-11, Automatic Study Import
			set_study_parent_wbs_id(p_id);

			-- Automated import will only update existing studies
			update import_study set
				status_code = 'FAIL',
				status_description = 'Invalid study, missing wbs_id for study_id: '||study_id
			where import_id=p_id
						and wbs_id is null;

			v_rowcount := sql%rowcount;
			log_pkg.steps('d'||v_rowcount,v_step_start,v_steps_result);

			update import_study set status_code = 'READY', action_code='APPLY'
			where import_id=p_id
						and status_code='NEW';

			v_rowcount := sql%rowcount;
			log_pkg.steps('e'||v_rowcount,v_step_start,v_steps_result);
		end if;

		select count(1)
		into v_cnt
		from import_study std
		where std.import_id=p_id
					and status_code='READY';

		-- TODO: Purge old studies that needs no updates

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where, v_par, v_steps_result||';READY_count='||v_cnt);

		return v_cnt;

	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result||';READY_count='||v_cnt);
		raise;
	end;

	/*************************************************************************/
	procedure merge(p_id in nvarchar2, p_payload in xmltype)
	as
		v_cnt number:=0;
		v_tlid timeline.id%type;
		v_where nvarchar2(99):='import_pkg.merge';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		--v_step nvarchar2(99):='0.'||v_where;
		--v_rowcount pls_integer:=0;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);
		select * into v_import from import where id=p_id and status_code='NEW';

		if message_pkg.is_error(p_payload) = 1 then
			update import set status_code='FAIL', timestamp_log=substr(timestamp_log||v_error,1,4000) where id=p_id;
			notice_pkg.catch(v_where, get_summary||' merge failed.');
			return;
		end if;

		if message_pkg.is_complete(p_payload) = 0 then
			return;
		end if;

		update import set sync_date=sysdate,is_syncing=0 where id=p_id;

		log_pkg.steps('a',v_step_start,v_steps_result);

		if v_import.project_id is not null then

			select * into v_project from project where id=v_import.project_id;

			/* check RAW plan */
			if bitand(v_import.type_mask, type_raw+type_project_activities) > 0 then
				begin
					select tl.id into v_tlid from timeline tl
					where tl.project_id=v_import.project_id and tl.type_code='RAW' and tl.is_syncing=0;
					exception when no_data_found then
					v_tlid:=null;
				end;
			end if;
		elsif v_import.sandbox_id is not null then
			v_tlid := get_timeline_id(p_id);
		end if;

		/* process data */
		log_pkg.steps('b',v_step_start,v_steps_result);


		if bitand(v_import.type_mask,type_lookups)=type_lookups then
			v_cnt := v_cnt + merge_lookups(p_id);
		end if;

		if bitand(v_import.type_mask,type_study)=type_study then
			v_cnt := v_cnt + merge_study(p_id);
		end if;

		log_pkg.steps('c',v_step_start,v_steps_result);


		if bitand(v_import.type_mask,type_masterdata)=type_masterdata then
			v_cnt := v_cnt + merge_masterdata(p_id);
		end if;

		log_pkg.steps('d',v_step_start,v_steps_result);

		if bitand(v_import.type_mask,type_costs)=type_costs then
			--skip when AREA is null or Research
			if nvl(v_project.area_code,'RS')='RS' then
				null;
			else
				if import_pkg.is_reload_costs=1 then
					v_cnt := v_cnt + import_costs_pkg.merge_costs(p_id);
				end if;
				v_cnt := v_cnt + import_costs_pkg.merge_costs_fps(p_id);
			end if;
		end if;

		log_pkg.steps('e',v_step_start,v_steps_result);

		if bitand(v_import.type_mask,type_headcount)=type_headcount then
			v_cnt := v_cnt + merge_headcount(p_id);
		end if;

		log_pkg.steps('f',v_step_start,v_steps_result);

		if bitand(v_import.type_mask,type_resources)=type_resources then
			v_cnt := v_cnt + import_resources_pkg.merge_resources(p_id);
			v_cnt := v_cnt + import_resources_pkg.merge_resources_cs(p_id);
			v_cnt := v_cnt + import_resources_pkg.merge_resources_ged(p_id);
		end if;

		log_pkg.steps('g',v_step_start,v_steps_result);

		if bitand(v_import.type_mask,type_actuals+type_plan+type_plan_auto)>0 then
			if v_tlid is not null then --not needed to merge timeline when no RAW timeline at all
				v_cnt := v_cnt + merge_timeline(p_id);
			end if;
		end if;

		log_pkg.steps('h',v_step_start,v_steps_result);

		if bitand(v_import.type_mask,type_project_activities)>0 then
			if v_tlid is not null then
				v_cnt := v_cnt + project_activities_pkg.import_merge(v_import);
				log_pkg.steps('i',v_step_start,v_steps_result);
			end if;
		end if;



		/* update master */
		update import set status_code='READY' where id=p_id;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'p_id='||p_id, v_steps_result);

		/* try to finish import */
		if v_import.is_manual = 0 then
			finish(p_id);
		end if;

	exception when others then
		v_error:=substr('step='||v_steps_result||';sqlerrm='||sqlerrm,1,4000);

		update import set status_code='FAIL', timestamp_log=substr(timestamp_log||v_error,1,4000) where id=p_id;
		notice_pkg.catch(v_where, get_summary||' merge failed.');
	end;

	/*************************************************************************/
	function submit_masterdata(p_id in nvarchar2) return number
	as
		v_existing_program_code nvarchar2(20);
		v_existing_program_name nvarchar2(256);
		v_program_id nvarchar2(20);
		v_program2_id nvarchar2(20);
		v_state_code nvarchar2(10);
		v_where nvarchar2(99):='import_pkg.submit_masterdata';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
	begin
		/* move data into ipms */
		/* depending on the project AREA not all data could be updated*/
		/* At ProMIS only DEV and D2 are created/managed so only minimal data set is updated*/
		log_performance('START_submit_masterdata()');

		if v_project.area_code in ('PRE-POT','POST-POT','D2-PRJ', 'SAMD') then-- PROMIS 604

			/* MINimum update */
			merge into project prj
			using (
							select
								imp.project_id,
								imp.development_phase_code,
								imp.sbe_code,
								imp.bay_code,
								--ipowner_code,
								--subgroup_code, -->> category_code -->> LC Type
								--successor_id -->> rather should not be Updated for ProMIS projects
								imp.gbu_code,
								--- accounting_status_code ---
								--0070	auf Projekt kann gebucht werden (project is accountable)
								--0071	auf Projekt kann nicht gebucht werden (project is not accountable)
								to_number(decode(imp.accounting_status_code, '0071','0','0070','1',null)) accounting_status_code,
								--,program_code
								decode(imp.planning_enabled_code, '0123','red','0122','green',null) planning_enabled_code,
								imp.project_group_code
							from import_masterdata imp
							where status_code='READY' and import_id=p_id
						) imp
			on (prj.id=imp.project_id)
			when matched then
			update set
				prj.development_phase_code=imp.development_phase_code,
				prj.sbe_code=imp.sbe_code,
				prj.bay_code=imp.bay_code,
				prj.is_active=nvl(imp.accounting_status_code,prj.is_active),
				prj.pidt_bu_code=imp.gbu_code, --CUC-340
				prj.planning_enabled=nvl(imp.planning_enabled_code,prj.planning_enabled),--only update when is not null
				prj.project_group_code=imp.project_group_code;

		else

			v_program_id:=null;
			v_state_code:=null;
			/* FULL update --> for all PROJECT_AREA even for not typified */
			for imp in (
			select
				project_id,
				development_phase_code,
				sbe_code,
				gbu_code,
				bay_code,
				ipowner_code,
				subgroup_code, -->> table:category_code -->> LC Type
				successor_id,
				to_number(decode(accounting_status_code, '0071','0','0070','1',null)) accounting_status_code,
				upper(program_code) program_code, -- still open issue: only Upper Case?
				program_name,
				decode(planning_enabled_code, '0123','red','0122','green',null) planning_enabled_code,
				decode(collaboration_code,'0','0','1') collaboration_code,
				project_group_code

			from import_masterdata
			where status_code='READY' and import_id=p_id
			)
			loop
				if v_project.area_code in ('PRD-MNT') then--Product Maintenance
					--If AREA_CODE is Maitenance then try to update Program_Id based on provided program_code
					--as a result of this dedicated IF-THEN we will have: v_program_id. If null means no changes required

					--at first, check if the existing Program CODE is different from the new one
					select upper(prg.code) into v_existing_program_code
					from program prg
						join project prj on prg.id=prj.program_id
					where prj.id=v_project.id;

					if v_existing_program_code<>imp.program_code then

						begin
							--check if the New Program exists in ProMIS at all
							select id into v_program_id from program where code=imp.program_code; --must be unique
							exception when no_data_found then
							--create NEW program

							insert into program (name,code) values (imp.program_name,imp.program_code)
							returning id into v_program_id;
							--send BPEL->P6 CreateProgram for PRD-MNT
							program_pkg.send(v_program_id,null,'create');
							v_program2_id:=0;
						end;

					end if;

					--Always check MNT projects
					if imp.program_name is not null and v_program2_id is null then
						begin
							select id,upper(name) into v_program2_id,v_existing_program_name
							from program where code=imp.program_code; --must be unique

							if v_existing_program_name<>upper(imp.program_name) then
								update program set name = imp.program_name where id=v_program2_id;
								program_pkg.send(v_program2_id,null,'create');--Does the Update
							end if;
							v_program2_id:=null;

							exception when others then
							notice_pkg.catch(get_subject, get_summary||' update Program Name failed.');
						end;
					end if;

				elsif v_project.area_code in ('D3-TR') then
					--Dedicated Action/Exception:
					--Automatically set project status of D3 Transition Codes to "completed"
					--if the status changes from active to inactive (triggered by COMBASE)

					if v_project.is_active=1 and imp.accounting_status_code in ('0071','0') then --InActive
						v_state_code := '6'; --Completed
					end if;
				end if;

				log_performance('1_submit_masterdata()');
				begin
					update project prj set
						prj.development_phase_code=imp.development_phase_code,
						prj.sbe_code=imp.sbe_code,
						--if new sbe_code is not null, then update gbu when new gbu is not null
						--prj.gbu_code=NVL2( imp.sbe_code, imp.gbu_code, prj.gbu_code ),
						prj.pidt_bu_code=imp.gbu_code,--CUC-340
						prj.bay_code=imp.bay_code,
						prj.ipowner_code=imp.ipowner_code,
						prj.category_code=imp.subgroup_code,
						prj.successor_project_id=imp.successor_id,
						prj.is_active=nvl(imp.accounting_status_code,prj.is_active),
						prj.import_program_code=imp.program_code,
						--one of options would be to store program name to a separate table, but this solution (with project.attribute)
						--seems to work better for Project Typyfication functionality
						prj.import_program_name=imp.program_name,
						prj.program_id=nvl(v_program_id,prj.program_id),
						prj.planning_enabled=nvl(imp.planning_enabled_code,prj.planning_enabled),--only update when is not null
						prj.is_collaboration=imp.collaboration_code,
						prj.state_code=nvl(v_state_code,prj.state_code),
						prj.project_group_code=imp.project_group_code
					where prj.id=v_project.id
								and
								(
									nvl(prj.development_phase_code,'$$$$')<>nvl(imp.development_phase_code,'$$$$')
									or
									nvl(prj.sbe_code,'$$$$')<>nvl(imp.sbe_code,'$$$$')
									or
									nvl(prj.pidt_bu_code,'$$$$')<>nvl(imp.gbu_code,'$$$$')
									or
									nvl(prj.bay_code,'$$$$')<>nvl(imp.bay_code,'$$$$')
									or
									nvl(prj.ipowner_code,'$$$$')<>nvl(imp.ipowner_code,'$$$$')
									or
									nvl(prj.category_code,'$$$$')<>nvl(imp.subgroup_code,'$$$$')
									or
									nvl(prj.successor_project_id,'$$$$')<>nvl(imp.successor_id,'$$$$')
									or
									prj.is_active<>imp.accounting_status_code--NOT NULL
									or
									nvl(prj.import_program_code,'$$$$')<>nvl(imp.program_code,'$$$$')
									or
									nvl(prj.import_program_name,'$$$$')<>nvl(imp.program_name,'$$$$')
									or
									prj.program_id<>nvl(v_program_id,prj.program_id)
									or
									nvl(prj.planning_enabled,'$$$$')<>nvl(imp.planning_enabled_code,'$$$$')
									or
									nvl(prj.is_collaboration,9)<>nvl(imp.collaboration_code,9)-- Must be NUMBER !
									or
									nvl(prj.state_code,'$$$$')<>nvl(v_state_code,'$$$$')
									or
									nvl(prj.project_group_code,'$$$$')<> nvl(imp.project_group_code,'$$$$')
								)
					;
					exception when others then--remove this exception after testing Update usage
					log_pkg.log(v_where,'OTHERS!TODO!Updating project p_id='||p_id||';v_project.id='||v_project.id,
											/*
					';imp.development_phase_code='||imp.development_phase_code||
					';imp.sbe_code='||imp.sbe_code||
					';imp.gbu_code='||imp.gbu_code||
					';imp.bay_code='||imp.bay_code||
					';imp.ipowner_code='||imp.ipowner_code||
					';imp.subgroup_code='||imp.subgroup_code||
					';imp.successor_id='||imp.successor_id||
					';imp.accounting_status_code='||imp.accounting_status_code||
					';imp.program_code='||imp.program_code||
					';v_program_id='||v_program_id||
					';imp.planning_enabled_code='||imp.planning_enabled_code||
					';imp.collaboration_code='||imp.collaboration_code||
					';v_state_code='||v_state_code||
					';sqlerrm='||
					*/
											sqlerrm);
				end;
				if v_program_id is not null then
					--not null means that progam_id was change in COMBASE for the project
					--and now it should be changed at P6 as well:
					program_pkg.send(v_program_id,' dbms_lock.sleep(5); project_pkg.move('''||v_project.id||''','''||v_program_id||''',null);','create');

					--project_pkg.move(v_project.id,v_program_id,null);
				end if;
			end loop;

		end if;

		update import_masterdata prj set status_code='DONE' where import_id=p_id and status_code='READY';

		log_performance('2_submit_masterdata()');
		return sql%rowcount;
	end;

	/*************************************************************************/
	function submit_headcount(p_id in nvarchar2) return number
	as
	begin
		/* drop old entries */
		delete from headcount
		where
			extract(year from start_date) between
			extract(year from v_import.create_date) - 1
			and extract(year from v_import.create_date) + 1;

		/* transfer headcount */
		insert into headcount(
			subfunction_code,
			type_code,
			demand,
			forecast_year,
			forecast_month,
			start_date, finish_date)
			select
				imp.subfunction_code,
				type_code,
				demand,
				forecast_year,
				forecast_month,
				to_date(year||'-01', 'yyyy-mm') as start_date,
				last_day(to_date(year||'-12', 'yyyy-mm')) as finish_date
			from import_headcount imp
				join subfunction sub on sub.code=imp.subfunction_code
			where status_code='READY' and import_id=p_id;

		/* finish headcount */
		update import_headcount hd set status_code='DONE' where import_id=p_id and status_code='READY';

		return sql%rowcount;
	end;

	/*************************************************************************/
	function submit_lookups(p_id in nvarchar2) return number
	as
		v_where nvarchar2(99):='import_pkg.submit_lookups';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		v_steps_result nvarchar2(4000);
		v_rowcount number:=0;
		v_rowcount1 number:=0;
		v_rowcount2 number:=0;
		v_step_start timestamp := systimestamp;
		v_procedure_start timestamp := systimestamp;
	begin
		log_pkg.log(v_where, v_par,'started.');

		--Do ONLY missing Inserts and BU merge must be before SBE
		--bu
		begin
			v_msg_out:='global_business_unit';
			merge into global_business_unit gbu
			using (
					select
						code,
						name,
						is_active
					from import_bu
					where status_code='READY'
					and import_id=p_id
				) imp
			on (gbu.code = imp.code)
			when matched then
				update set gbu.is_active=imp.is_active
			when not matched then
				insert(gbu.code, gbu.name, gbu.is_active, gbu.description)
				values(imp.code, imp.name, imp.is_active, 'Imported from COMBASE');
			v_rowcount := sql%rowcount;
			log_pkg.log(v_where,v_par,v_msg_out||v_rowcount);
		exception when others then
			log_pkg.catch(v_where,v_par,v_msg_out);
		end;

		begin
			v_msg_out:='loop';
			do_loop
			(
				p_id,
				'begin
					merge into %1 sf
					using (
						select
							code,
							name,
							is_active
						from import_%1
						where status_code=''READY''
						and import_id=:1
					) imp
					on (sf.code = imp.code)
					when matched then
						update set sf.name=imp.name,sf.is_active=imp.is_active
					when not matched then
						insert(sf.code, sf.name, sf.is_active) values(imp.code, imp.name, imp.is_active);
				end;',
				varchar2_table_typ('substance','bay_number','ipowner','topgroup')
			);
			v_rowcount:=0;
			log_pkg.log(v_where,v_par,v_msg_out||v_rowcount);
		exception when others then
			log_pkg.catch(v_where,v_par,v_msg_out);
		end;

		begin
			v_msg_out:='substance_combi';
			--substance_combi
			merge into substance_combi sf
			using (
				select
					substance_code,
					combination_code,
					is_active
				from import_substance_combi
				where status_code='READY'
				and import_id=p_id
				) imp
			on (sf.substance_code = imp.substance_code and sf.combination_code = imp.combination_code)
			when matched then
				update set sf.is_active=imp.is_active
			when not matched then
				insert(sf.substance_code, sf.combination_code, sf.is_active)
				values(imp.substance_code, imp.combination_code, imp.is_active);
			v_rowcount := sql%rowcount;
			log_pkg.log(v_where,v_par,v_msg_out||v_rowcount);
		exception when others then
			log_pkg.catch(v_where,v_par,v_msg_out);
		end;

		begin
			v_msg_out:='smu';
			--smu
			merge into smu sf
			using (
				select
					code,
					substance_code,
					name,
					is_active
				from import_smu
				where status_code='READY'
				and import_id=p_id
				) imp
			on (sf.code = imp.code)
			when matched then
				update set sf.name=imp.name,sf.substance_code=imp.substance_code,sf.is_active=imp.is_active
			when not matched then
				insert(sf.code, sf.substance_code, sf.name, sf.is_active)
				values(imp.code, imp.substance_code, imp.name, imp.is_active);
			v_rowcount := sql%rowcount;
			log_pkg.log(v_where,v_par,v_msg_out||v_rowcount);
		exception when others then
			log_pkg.catch(v_where,v_par,v_msg_out);
		end;

		begin
			v_msg_out:='bay_number';
			--bay_combination
			merge into bay_number sf
			using (
				select
					code,
					name,
					is_active
				from import_bay_combination
				where status_code='READY'
				and import_id=p_id
				) imp
			on (sf.code = imp.code)
			when matched then
				update set sf.name=imp.name,sf.is_active=imp.is_active
			when not matched then
				insert(sf.code, sf.name, sf.is_active)
				values(imp.code, imp.name, imp.is_active);
			v_rowcount := sql%rowcount;
			log_pkg.log(v_where,v_par,v_msg_out||v_rowcount);
		exception when others then
			log_pkg.catch(v_where,v_par,v_msg_out);
		end;

		begin
			v_msg_out:='maingroup';
			--MAINGROUP
			merge into maingroup mg
			using (
				select
					code,
					topgroup_code,
					name,
					is_active
				from import_maingroup
				where status_code='READY'
				and import_id=p_id
				) imp
			on (mg.code = imp.code)
			when matched then
				update set mg.name=imp.name,mg.topgroup_code=imp.topgroup_code,mg.is_active=imp.is_active
			when not matched then
				insert(mg.code, mg.topgroup_code, mg.name, mg.is_active)
				values(imp.code, imp.topgroup_code, imp.name, imp.is_active);
			v_rowcount := sql%rowcount;
			log_pkg.log(v_where,v_par,v_msg_out||v_rowcount);
		exception when others then
			log_pkg.catch(v_where,v_par,v_msg_out);
		end;

		begin
			v_msg_out:='project_category';
			--SUBGROUP
			merge into project_category pc
			using
				(
				select
					code,
					maingroup_code,
					name,
					is_active,
					correlation_id
				from import_subgroup
				where status_code='READY'
				and import_id=p_id
				) imp
			on (pc.code = imp.code)
			when matched then
			update set
				pc.name=decode(is_promis,0,imp.name,pc.name),--update only when is_promis=0
				pc.maingroup_code=imp.maingroup_code,--always update
				pc.is_active=decode(is_promis,0,imp.is_active,pc.is_active),--update only when is_promis=0
				pc.correlation_id=decode(is_promis,0,imp.correlation_id,pc.correlation_id)--update only when is_promis=0
			when not matched then
				insert(pc.code, pc.maingroup_code, pc.name, pc.is_active, pc.description, pc.correlation_id)
				values(imp.code, imp.maingroup_code, imp.name, imp.is_active, 'Imported from COMBASE', imp.correlation_id);
			v_rowcount := sql%rowcount;
			log_pkg.log(v_where,v_par,v_msg_out||v_rowcount);
		exception when others then
			log_pkg.catch(v_where,v_par,v_msg_out);
		end;

		begin
			v_msg_out:='strategic_business_entity';
			--SBE
			merge into strategic_business_entity sbe
			using (
				select
					code,
					gbu_code,
					name,
					is_active
				from import_sbe
				where status_code='READY'
				and import_id=p_id
				) imp
			on (sbe.code = imp.code)
			when matched then
				update set sbe.name=imp.name,sbe.gbu_code=imp.gbu_code,sbe.is_active=imp.is_active
			when not matched then
				insert(sbe.code, sbe.gbu_code, sbe.name, sbe.is_active)
				values(imp.code, imp.gbu_code, imp.name, imp.is_active);
			v_rowcount := sql%rowcount;
			log_pkg.log(v_where,v_par,v_msg_out||v_rowcount);
		exception when others then
			log_pkg.catch(v_where,v_par,v_msg_out);
		end;

		log_pkg.log(v_where, 'Finished the main part.p_id='||p_id,'Finished.');
		---FUNCTION --> oone simple MERGE: JIRA: PROMIS-282
		begin

			-- TOP-functions
			merge into top_function dest
			using (
							select
								code,
								max(decode (seq, 1, name)) name,
								max(decode (seq, 1, valid_from)) valid_from,
								max(decode (seq, 1, valid_to)) valid_to,
								sum(decode (seq, 1, srccnt, dstcnt)) iud
							from (
								select
									code,name,valid_from,valid_to,
									srccnt, dstcnt,row_number() over (partition by code order by dstcnt nulls last) seq
								from (
									select
										code,name,valid_from,valid_to
										,count (src) srccnt, count (dst) dstcnt
									from (
										select
											to_number(kfu1_no) code,
											to_nchar(kfu1_name) name,
											valid_from,
											valid_to,
											1 src,
											to_number (null) dst
										from masterdata.bdo_costcenter_function_top@combase_db
										where valid_from<=sysdate
													and nvl(valid_to,sysdate+1)>sysdate
													and status='ACTIVE'
										union all
										select
											to_number(code) code,
											name,
											valid_from,
											valid_to,
											to_number(null) src,
											2 dst
										from top_function
									)
									group by code,name,valid_from,valid_to
									having count (src) <> count (dst)
								)
							)
							group by code
						) diff
			on (dest.code = to_nchar(diff.code))
			when matched then
			update set
				dest.name = diff.name
				,dest.valid_from = diff.valid_from
				,dest.valid_to = diff.valid_to
				,update_date=sysdate
			--delete where (diff.iud = 0) --Logical Delete--will go separatly in the LOOP below
			when not matched then
			insert (code,name,valid_from,valid_to,create_date,is_active)
			values (diff.code,diff.name,diff.valid_from,diff.valid_to,sysdate,1);

			v_rowcount := sql%rowcount;
			log_pkg.log(v_where, 'Finished TopFunctions MERGE.p_id='||p_id||';v_rowcount='||v_rowcount,'Finished.');

			---Logical DELETE for not Used TOP FUNCTIONS
			for ff in (
			select
				code
			from top_function
			where nvl(valid_to,sysdate+111)>sysdate
			minus
			select to_nchar(to_number(kfu1_no)) code
			from masterdata.bdo_costcenter_function_top@combase_db
			where valid_from<=sysdate
						and nvl(valid_to,sysdate+1)>sysdate
						and status='ACTIVE'
			)
			loop
				update top_function set valid_to=sysdate, is_active=0, update_date=sysdate where code=to_nchar(ff.code);
				v_rowcount:=v_rowcount+1;
			end loop;

			update top_function set is_active=0, update_date=sysdate where nvl(valid_to,sysdate+111)<sysdate and is_active=1;
			v_rowcount1 := sql%rowcount;
			update top_function set is_active=1, update_date=sysdate where nvl(valid_to,sysdate+111)>sysdate and is_active=0;
			v_rowcount2 := sql%rowcount;

			log_pkg.log(v_where, 'Finished TopFunctions logic DELETE.p_id='||p_id||';v_rowcount='||(v_rowcount+v_rowcount1+v_rowcount2),'Finished.');

			-- MAIN-functions
			merge into function dest
			using (
							select
								code,
								max(decode (seq, 1, top_code)) top_code,
								max(decode (seq, 1, name)) name,
								max(decode (seq, 1, valid_from)) valid_from,
								max(decode (seq, 1, valid_to)) valid_to,
								sum(decode (seq, 1, srccnt, dstcnt)) iud
							from (
								select
									code,top_code,name,valid_from,valid_to,
									srccnt, dstcnt,row_number() over (partition by code order by dstcnt nulls last) seq
								from (
									select
										code,top_code,name,valid_from,valid_to
										,count (src) srccnt, count (dst) dstcnt
									from (
										select
											to_number(main.kfu2_no) code,
											to_number(ref.kfu1_no) top_code,
											to_nchar(main.kfu2_name) name,
											main.valid_from,
											main.valid_to,
											1 src,
											to_number (null) dst
										from masterdata.bdo_costcenter_function_main@combase_db main
											left join masterdata.bdr_kfu_t_kfu_m@combase_db ref on main.kfu2_no=ref.kfu2_no and ref.valid_from<=sysdate	and nvl(ref.valid_to,sysdate+1)>sysdate and ref.status='ACTIVE'
										where main.valid_from<=sysdate
													and nvl(main.valid_to,sysdate+1)>sysdate
													and main.status='ACTIVE'
										union all
										select
											to_number(code) code,
											to_number(top_function_code) top_code,
											name,
											valid_from,
											valid_to,
											to_number(null) src,
											2 dst
										from function
										where REGEXP_LIKE(code, '^[[:digit:]]+$')
									)
									group by code,top_code,name,valid_from,valid_to
									having count (src) <> count (dst)
								)
							)
							group by code
						) diff
			on (dest.code = to_nchar(diff.code))
			when matched then
			update set
				dest.top_function_code = diff.top_code
				,dest.name = diff.name
				,dest.valid_from = diff.valid_from
				,dest.valid_to = diff.valid_to
				,update_date=sysdate
			--delete where (diff.iud = 0) --Logical Delete--will go separatly in the LOOP below
			when not matched then
			insert (code,top_function_code,name,valid_from,valid_to,create_date,is_active)
			values (diff.code,diff.top_code,diff.name,diff.valid_from,diff.valid_to,sysdate,1);

			v_rowcount := sql%rowcount;
			log_pkg.log(v_where, 'Finished Functions MERGE.p_id='||p_id||';v_rowcount='||v_rowcount,'Finished.');

			---Logical DELETE for not Used FUNCTIONS
			for ff in (
			select
				code
			from function
			where nvl(valid_to,sysdate+111)>sysdate
			minus
			select to_nchar(to_number(kfu2_no)) code
			from masterdata.bdo_costcenter_function_main@combase_db
			where valid_from<=sysdate
						and nvl(valid_to,sysdate+1)>sysdate
						and status='ACTIVE'
			)
			loop
				update function set valid_to=sysdate, is_active=0, update_date=sysdate where code=to_nchar(ff.code);
				v_rowcount:=v_rowcount+1;
			end loop;

			update function set is_active=0, update_date=sysdate where nvl(valid_to,sysdate+111)<sysdate and is_active=1;
			v_rowcount1 := sql%rowcount;
			update function set is_active=1, update_date=sysdate where nvl(valid_to,sysdate+111)>sysdate and is_active=0;
			v_rowcount2 := sql%rowcount;

			if (v_rowcount+v_rowcount1+v_rowcount2) > 0 then -- then something happend with Functions
				lookup_pkg.send(null);
			end if;

			log_pkg.log(v_where, 'Finished Functions logic DELETE.p_id='||p_id||';v_rowcount='||(v_rowcount+v_rowcount1+v_rowcount2),'Finished.');

			--SUB-Functions
			merge into subfunction dest
			using (
							select
								code,
								max(decode (seq, 1, function_code)) function_code,
								max(decode (seq, 1, name)) name,
								max(decode (seq, 1, valid_from)) valid_from,
								max(decode (seq, 1, valid_to)) valid_to,
								sum(decode (seq, 1, srccnt, dstcnt)) iud
							from (
								select
									code,function_code,name,valid_from,valid_to,
									srccnt, dstcnt,row_number() over (partition by code order by dstcnt nulls last) seq
								from (
									select
										code,function_code,name,valid_from,valid_to
										,count (src) srccnt, count (dst) dstcnt
									from (
										select
											to_nchar(to_number(s.kfu3_no)) as code,
											to_nchar(to_number(r.kfu2_no)) as function_code,
											to_nchar(kfu3_name) as name,
											greatest(s.valid_from, r.valid_from) as valid_from,
											greatest(nvl(s.valid_to, r.valid_to),nvl(r.valid_to, s.valid_to)) as valid_to,
											1 src,
											to_number (null) dst
										from bdo_costcenter_function_sub1@combase_db s
											left join bdr_kfu_m_kfu_s1@combase_db r on (r.kfu3_no=s.kfu3_no)
										--where s.kfu3_no in ('0345')
										where greatest(s.valid_from, r.valid_from)<=sysdate
													and nvl(greatest(nvl(s.valid_to, r.valid_to),nvl(r.valid_to, s.valid_to)),sysdate+111)>sysdate
													--order by s.kfu3_no, greatest(s.valid_to, r.valid_to)
													and s.status='ACTIVE'
													and r.status='ACTIVE'
										union all
										select
											code,
											function_code,
											name,
											valid_from,
											valid_to,
											to_number(null) src,
											2 dst
										from subfunction
										where regexp_like(code, '^[[:digit:]]+$')
									)
									group by code,function_code,name,valid_from,valid_to
									having count (src) <> count (dst)
								)
							)
							group by code
						) diff
			on (dest.code = to_nchar(diff.code))
			when matched then
			update set
				dest.function_code = diff.function_code
				,dest.name = diff.name
				,dest.valid_from = diff.valid_from
				,dest.valid_to = diff.valid_to
				,update_date=sysdate
			--delete where (diff.iud = 0) --Logical Delete--will go separatly in the LOOP below
			when not matched then
			insert (code,function_code,name,valid_from,valid_to,create_date,is_active)
			values (diff.code,diff.function_code,diff.name,diff.valid_from,diff.valid_to,sysdate,1);

			v_rowcount := sql%rowcount;
			log_pkg.log(v_where, 'Finished SUB-Functions MERGE.p_id='||p_id||';v_rowcount='||(v_rowcount+v_rowcount1+v_rowcount2),'Finished.');

			---Logical DELETE for not Used SUB-FUNCTIONS
			for ff in (
			select
				code
			from subfunction
			where regexp_like(code, '^[[:digit:]]+$')
						and nvl(valid_to,sysdate+111)>sysdate
			--and code='101'
			minus
			select
				to_nchar(to_number(s.kfu3_no)) as code
			from bdo_costcenter_function_sub1@combase_db s
				left join bdr_kfu_m_kfu_s1@combase_db r on (r.kfu3_no=s.kfu3_no)
			where greatest(s.valid_from, r.valid_from)<sysdate
						and nvl(greatest(nvl(s.valid_to, r.valid_to),nvl(r.valid_to, s.valid_to)),sysdate+111)>sysdate
						and s.status='ACTIVE'
						and r.status='ACTIVE'
				--and to_nchar(to_number(s.kfu3_no))='101'
			)
			loop
				update subfunction set valid_to=sysdate, is_active=0, update_date=sysdate where code=ff.code;
				v_rowcount:=v_rowcount+1;
			end loop;

			update subfunction set is_active=0, update_date=sysdate where nvl(valid_to,sysdate+111)<sysdate and is_active=1;
			v_rowcount1 := sql%rowcount;
			update subfunction set is_active=1, update_date=sysdate where nvl(valid_to,sysdate+111)>sysdate and is_active=0;
			v_rowcount2 := sql%rowcount;

			log_pkg.log(v_where, 'Finished SUB-Functions logic DELETE.p_id='||p_id||';v_rowcount='||(v_rowcount+v_rowcount1+v_rowcount2),'Finished.');


		exception when others then
			log_pkg.log(v_where, 'FUNCTION-SUB;OTHERS.p_id='||p_id,sqlerrm);
		end;

		begin
			v_msg_out:='project_activity_name';
			merge into project_activity_name pan
			using (
				select
					project_activity_id,
					project_activity_name,
					is_active
				from import_project_activity_name
				where status_code='READY'
				and import_id=p_id
				) imp
			on (pan.id = imp.project_activity_id)
			when matched then
				update set
					pan.name=imp.project_activity_name,
					pan.is_active=imp.is_active,
					pan.update_date=sysdate
			when not matched then
				insert(id,name,is_active)
				values(imp.project_activity_id,imp.project_activity_name,imp.is_active)
			;
			v_rowcount := sql%rowcount;
			log_pkg.log(v_where,v_par,v_msg_out||v_rowcount);
			--todo: should is_active be set to 0 if not exists at the source?
			--context: PROMIS-442
		exception when others then
			log_pkg.catch(v_where,v_par,v_msg_out);
		end;

		--finishing...>>>DONE
		begin
			v_msg_out:='2loop';
			do_loop(
				p_id,
				'begin
					update import_%1 set status_code=''DONE''
					where import_id=:1
					and status_code=''READY'';
				end;',
				varchar2_table_typ
				(
					'substance',
					'sbe',
					'bay_number',
					'bay_combination',
					'substance_combi',
					'smu',
					'ipowner',
					'topgroup',
					'bu',
					'subgroup',
					'maingroup',
					'project_activity_name'
				)
			);
			v_rowcount := 0;
			log_pkg.log(v_where,v_par,v_msg_out||v_rowcount);
		exception when others then
			log_pkg.catch(v_where,v_par,v_msg_out);
		end;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result );

		return 1;

	exception when others then
		notice_pkg.catch(v_where, v_par || ';' || v_steps_result );
		--return 0;
		raise;
	end;

	/*************************************************************************/
	function submit_timeline(p_id in nvarchar2) return number
	as
		v_cnt number;
		v_rowcount pls_integer:=0;
		v_where nvarchar2(99):='import_pkg.submit_timeline';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;

		begin
			log_pkg.steps(null,v_step_start,v_steps_result);

			/* prepare request */
			select insertChildXML(v_timeline, '/*', 'activities', xmltype('<activities '||message_pkg.xmlns_ipms||'/>'))
			into v_timeline
			from dual;

			--v_rowcount := v_rowcount + sql%rowcount;
			log_pkg.steps('a',v_step_start,v_steps_result);

			/* fill in request with activities ready to be transfered into ipms */
			for act in (
			select
				act.id, act.import_id,
				xmltype(
						'<activity id="'||act.activity_id||'" studyElementId="'||act.study_element_id||'" timelineId="'||act.timeline_id||'"'
						||nvl2(act.parent_wbs_id,' wbsId="'||act.parent_wbs_id||'"','')
						||' restricted="'||decode(act.action_code,'APPLY','false','true')||'" '
						||message_pkg.xmlns_ipms||'>'||
						get_element('type', act.activity_type)||
						get_element(decode(act.type_code,'ACT','actualStart','planStart'),get_char_date(act.new_start_date))||
						get_element(decode(act.type_code,'ACT','actualFinish','planFinish'),get_char_date(act.new_finish_date))||
						'</activity>') as payload
			from import_timeline act
			where
				act.import_id=p_id
				and act.status_code='READY'
				/* all active and accepted planned */
				and (act.type_code='ACT' or act.type_code='PLAN' and (act.action_code<>'SKIP' and v_import.is_manual=1 or v_import.is_manual=0) )
				and act.activity_id is not null
			) loop
				select insertchildxml(v_timeline,'//timeline/activities','activity',act.payload,message_pkg.xmlns_ipms)
				into v_timeline from dual;

				update import_timeline set status_code='SEND' where import_id=act.import_id and id=act.id;
			end loop;

			--v_rowcount := v_rowcount + sql%rowcount;
			log_pkg.steps('b',v_step_start,v_steps_result);

			/* count affected rows */
			select count(1)
			into v_cnt
			from import_timeline
			where import_id=p_id and status_code='SEND';

			--v_rowcount := v_rowcount + sql%rowcount;

			log_pkg.steps('END',v_procedure_start,v_steps_result);
			log_pkg.log(v_where, 'p_id='||p_id||';rowcount='||v_cnt, v_steps_result);

			return v_cnt;
		end;

	/*************************************************************************/
	function submit_study(p_id in nvarchar2) return number
	as
		v_rowcount pls_integer:=0;
		v_sum_rowcount pls_integer:=0;
		v_where nvarchar2(99):='import_pkg.submit_study';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;

		begin
			log_pkg.steps(null,v_step_start,v_steps_result);

			merge into import_study trg
			using
				(select
					 wbs.wbs_id,
					 to_char(regexp_substr(regexp_substr(sys_connect_by_path(wca.category_object_id,'|'),'\d+[\|]*$'),'\d+')) nearest_wca_object_id
				 from timeline_wbs wbs
					 left join timeline_wbs_category wca on wca.wbs_id=wbs.wbs_id
				 where wbs.timeline_id = v_project.id|| '-RAW'
				 connect by wbs.parent_wbs_id = prior wbs.wbs_id
				 start with wbs.parent_wbs_id is null
				 union all
				 select to_char(tl.reference_id), to_char(wca.category_object_id) from timeline tl
					 join timeline_wbs_category wca on wca.timeline_id=tl.id and wca.wbs_id is null
				 where tl.id=v_project.id||'-RAW'
				) src
			on (src.wbs_id=trg.parent_wbs_id and (trg.wbs_id is null or trg.wbs_id='#new#'))
			when matched then update
			set trg.wbs_category_object_id=src.nearest_wca_object_id;

			--prepare request
			select
				v_timeline.appendChildXML('/*',
																	xmlelement("wbsNodes",
																						 xmlattributes(message_pkg.nsuri_ipms as "xmlns"),
																						 xmlagg(
																								 xmlelement("wbs",
																														xmlattributes(nvl(s.wbs_id, '#new#') as "id",
																														s.study_id as "studyId",
																														t.id as "timelineId",
																														s.parent_wbs_id as "parentId",
																														decode(s.is_placeholder, 1, 'true', 'false') as "placeholder",
																														s.study_template_id as "templateId"),
																														xmlforest(
																																s.name as "name",
																																s.phase as "studyPhase",--studyPhase can be NULL, so do not generate ELEMENT in that case.
																																s.plan_patients as "planPatients",
																																s.actual_patients as "actualPatients",
																																s.plan_entered_screen as "planEnteredScreen",
																																s.act_entered_screen as "actEnteredScreen",
																																s.study_country_count_plan as "studyCountryCountPlan",
																																s.study_country_count as "studyCountryCount",
																																s.study_unit_count as "studyUnitCount",
																																s.study_unit_count_plan as "studyUnitCountPlan",
																																ltrim(to_char(fte.fte_avg,'99999999990.00')) as "FTEAvg",
																																s.wbs_category_object_id as "categoryObjectId"
																														)
																								 ))
																	))
			into v_timeline
			from import_study s
				join timeline t on (t.project_id=s.project_id and t.type_code='RAW')
				left join
				(
					select
						--project_id, --no need to group by project_id because p_id limits only to one project
						study_id fte_study_id,
						round(avg(fte),2) fte_avg
					from import_study_fte
					where import_id=p_id
					group by study_id
				) fte on fte.fte_study_id=s.study_id --and fte.project_id=s.project_id
			where s.import_id=p_id
						and s.status_code='READY'
						and lnnvl(s.action_code='SKIP')
			--	and nvl(s.wbs_id,'####')<>'#new#' --TODO: BAY_PROMIS-11 delete the line after finishing testing, now it does not send #new#, means autoimport is not working
			;

			v_rowcount := sql%rowcount;
			v_sum_rowcount := v_sum_rowcount + v_rowcount;
			log_pkg.steps('a'||v_rowcount,v_step_start,v_steps_result);

			--store local data
			insert into study_data_vw
			(
				project_id,
				id,
				plan_patients,
				actual_patients,
				int_ext_flag,
				study_modus_no,
				study_modus_name,
				clin_plan_type,
				study_unit_count,
				study_unit_count_plan,
				therapeutic_group_code,
				therapeutic_group_desc,
				is_gpdc_approved,
				is_obligation,
				is_probing,
				volunteer_flag,
				study_country_count,
				study_country_count_plan,
				subject_type,
				plan_entered_screen,
				act_entered_screen,
				--is_timeline_auto_import,
				fte_avg,
				phase_code,
				study_name,
				budget_class,
				branch_flag
			)
				select
					imp.project_id,
					study_id,
					plan_patients,
					actual_patients,
					int_ext_flag,
					study_modus_no,
					study_modus_name,
					clin_plan_type,
					study_unit_count,
					study_unit_count_plan,
					therapeutic_group_code,
					therapeutic_group_desc,
					is_gpdc_approved,
					is_obligation,
					is_probing,
					volunteer_flag,
					study_country_count,
					study_country_count_plan,
					subject_type,
					plan_entered_screen,
					act_entered_screen,
					--decode(is_placeholder,1,0,1), --PROMISIII-138
					fte.fte_avg,
					phase_code,
					study_name,
					budget_class,
					branch_flag
				from import_study imp
					left join
					(
						select
							--project_id,
							study_id fte_study_id,
							round(avg(fte),2) fte_avg
						from import_study_fte
						where import_id=p_id
						group by
							--project_id,
							study_id
					) fte on fte.fte_study_id=imp.study_id --and fte.project_id=imp.project_id
				where imp.import_id=p_id
							and imp.status_code='READY'
							and lnnvl(action_code='SKIP');

			v_rowcount := sql%rowcount;
			v_sum_rowcount := v_sum_rowcount + v_rowcount;
			log_pkg.steps('b'||v_rowcount,v_step_start,v_steps_result);

			merge into fte fte
			using (select * from import_study_fte where import_id=p_id) src
			on (src.study_id=fte.study_id and src.function_id=fte.function_code and src.year=fte.year and src.month=fte.month and src.project_id=fte.project_id)
			when matched then
			update set fte.fte=src.fte
			when not matched then
			insert (project_id,study_id, function_code,year,month,fte)
			values (src.project_id, src.study_id, src.function_id, src.year, src.month, src.fte);

			v_rowcount := sql%rowcount;
			v_sum_rowcount := v_sum_rowcount + v_rowcount;
			log_pkg.steps('c'||v_rowcount,v_step_start,v_steps_result);

			update import_study
			set status_code=decode(action_code, 'SKIP', 'VOID', 'SEND')
			where import_id=p_id
						and status_code='READY';

			v_rowcount := sql%rowcount;
			v_sum_rowcount := v_sum_rowcount + v_rowcount;
			log_pkg.steps('d'||v_rowcount,v_step_start,v_steps_result);

			log_pkg.steps('END',v_procedure_start,v_steps_result);
			log_pkg.slog(v_where, 'p_id='||p_id||';rowcount='||v_sum_rowcount, v_steps_result);

			return v_sum_rowcount;

			exception when others then
			log_pkg.scatch(v_where, 'p_id='||p_id||';rowcount='||v_sum_rowcount, v_steps_result);
			raise;
		end;

	/*************************************************************************/
	procedure finish(p_id in nvarchar2)
	as
		v_timeline_id timeline.id%type;
		v_cnt number;
		v_where nvarchar2(99):='import_pkg.finish';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		--v_rowcount pls_integer:=0;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;

		begin
			log_pkg.steps(null,v_step_start,v_steps_result);
			-- check status
			select * into v_import from import where id=p_id and is_syncing=0 and status_code='READY';

			if v_import.source='FPS' then
				import_qplan_pkg.finish(p_id);
				return;
			end if;

			v_project:=null;
			if v_import.project_id is not null then
				select * into v_project from project where id=v_import.project_id;
			end if;

			log_pkg.steps('a',v_step_start,v_steps_result);

			-- read timeline
			if bitand(v_import.type_mask, type_raw+type_project_activities) > 0 then
				if v_import.project_id is not null then
					begin
						v_timeline_id := get_timeline_id(p_id);
						v_timeline := timeline_pkg.xml(v_timeline_id);
						exception when no_data_found then
						v_timeline_id:=null;
					end;
				elsif v_import.sandbox_id is not null then
					v_timeline_id := get_timeline_id(p_id);
					v_timeline := timeline_pkg.xml(v_timeline_id);
				end if;
				log_pkg.steps('b',v_step_start,v_steps_result);
			end if;

			-- save details
			v_cnt := 0;

			if bitand(v_import.type_mask,type_lookups)=type_lookups then
				v_cnt := v_cnt + submit_lookups(p_id);
				log_pkg.steps('c',v_step_start,v_steps_result);
			end if;

			if bitand(v_import.type_mask,type_study)=type_study then
				v_cnt := v_cnt + submit_study(p_id);
				log_pkg.steps('d',v_step_start,v_steps_result);
			end if;

			if bitand(v_import.type_mask,type_masterdata)=type_masterdata then
				v_cnt := v_cnt + submit_masterdata(p_id);
				log_pkg.steps('e',v_step_start,v_steps_result);
			end if;

			if bitand(v_import.type_mask,type_costs)=type_costs then
				--skip when AREA is null or Research
				if nvl(v_project.area_code,'RS')='RS' then
					null;
				else
					if import_pkg.is_reload_costs=1 then
						v_cnt := v_cnt + import_costs_pkg.submit_costs(p_id);
					end if;
					v_cnt := v_cnt + import_costs_pkg.submit_costs_fps(p_id);
				end if;
				log_pkg.steps('f',v_step_start,v_steps_result);
			end if;

			if bitand(v_import.type_mask,type_headcount)=type_headcount then
				v_cnt := v_cnt + submit_headcount(p_id);
				log_pkg.steps('g',v_step_start,v_steps_result);
			end if;

			if bitand(v_import.type_mask,type_resources)=type_resources then
				v_cnt := v_cnt + import_resources_pkg.submit_resources(p_id);
				v_cnt := v_cnt + import_resources_pkg.submit_resources_cs(p_id);
				v_cnt := v_cnt + import_resources_pkg.submit_resources_ged(p_id);
				log_pkg.steps('h',v_step_start,v_steps_result);
			end if;

			if v_timeline_id is not null then
				if bitand(v_import.type_mask,type_actuals+type_plan+type_plan_auto)>0 then
					v_cnt := v_cnt + submit_timeline(p_id);
				end if;

				if bitand(v_import.type_mask,type_project_activities)=type_project_activities then
					v_cnt := v_cnt + project_activities_pkg.import_submit(v_import,v_timeline);
					log_pkg.steps('h2',v_step_start,v_steps_result);
				end if;

				-- submit timeline if it is not empty
				v_cnt :=
				v_timeline.existsNode('//activity',message_pkg.xmlns_ipms) +
				v_timeline.existsnode('//wbs',message_pkg.xmlns_ipms);

				if v_cnt > 0 then
					timeline_pkg.send(v_timeline.extract('//timeline/@id',message_pkg.xmlns_ipms).getstringval(),
														v_timeline, 'begin import_pkg.send_finish('''||p_id||''',:1); end;');

					update import set is_syncing=1,status_code='SEND' where id=p_id;
					v_msg_out:=v_msg_out||';Timeline send.';
					log_pkg.steps('END',v_procedure_start,v_steps_result);
					log_pkg.slog(v_where, v_par, v_steps_result||v_msg_out);
					return;
				end if;

				log_pkg.steps('i',v_step_start,v_steps_result);
			end if;

			-- save master as complete
			update import set status_code='DONE' where id=p_id;

			if v_import.is_manual=1 then
				v_msg_out:=v_msg_out||';Manual import finished.';
			end if;

			log_pkg.steps('END',v_procedure_start,v_steps_result);
			log_pkg.slog(v_where, v_par, v_steps_result||v_msg_out);

			exception when others then
			log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
			log_pkg.scatch(v_where, v_par, v_steps_result||v_msg_out);
			update import set status_code='FAIL' where id=p_id;
		end;

	/*************************************************************************/
	procedure finish_timeline(p_id in nvarchar2)
	as
		v_rowcount pls_integer:=0;
		v_where nvarchar2(99):='import_pkg.finish_timeline';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		begin
			log_pkg.steps(null,v_step_start,v_steps_result);

			update import_timeline set status_code='DONE'
			where import_id=p_id and status_code='SEND';

			v_rowcount := v_rowcount + sql%rowcount;

			log_pkg.steps('END',v_procedure_start,v_steps_result);
			log_pkg.log(v_where, 'p_id='||p_id||';rowcount='||v_rowcount, v_steps_result);
		end;

	/*************************************************************************/
	procedure finish_study(p_id in nvarchar2, p_payload in xmltype)
	as
		v_rowcount pls_integer:=0;
		v_sum_rowcount pls_integer:=0;
		v_where nvarchar2(99):='import_pkg.finish_study';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		v_root_id varchar2(999);

	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		if configuration_pkg.get_config_number('STUDY-AUTO-IMPORT')=1 then --Do following Insert only when it is set based on Configuration

			--Get Root WBS id, for the cases when study is imported at root level:
			begin
				select xt.reference_id
				into v_root_id
				from xmltable
					(
						xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
						'//timeline' passing p_payload
						columns
							reference_id path '/timeline/@referenceId'
					) xt
				;
			exception when others then
				v_root_id := null;
			end;

			--------------------------------------------------------------------
			--update study, make sure that the import flags are set to true.
			merge into study trg using
				(
					select
						imps.project_id,
						xt.study_id
					from import_study imps
						left join
						(
							select
								xt.study_id,
								xt.parent_wbs_id,
								xt.wbs_id
							from xmltable
									 (
									 xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
									 '//timeline/wbsNodes/wbs' passing p_payload
									 columns
											 wbs_id path '/wbs/@id',
									 parent_wbs_id path '/wbs/@parentId',
									 study_id path '/wbs/@studyId'
									 ) xt
							where xt.study_id is not null
							and xt.wbs_id is not null -- DONE
						) xt on (imps.study_id=xt.study_id and xt.parent_wbs_id=imps.parent_wbs_id)
					where imps.import_id=p_id
					and imps.status_code='SEND'
					and imps.wbs_id='#new#' --was send to P6 with a flag NEW
				) src on
			(
				src.study_id=trg.id and
				trg.project_id=src.project_id --and
				--trg.is_study_auto_import+trg.is_timeline_auto_import<2
			)
			when matched then
			update set
				trg.is_timeline_auto_import=1
			;
			v_rowcount := sql%rowcount;
			v_sum_rowcount := v_sum_rowcount + v_rowcount;
			log_pkg.steps('a'||v_rowcount,v_step_start,v_steps_result);

			--------------------------------------------------------------------
			--prapare task timeline
			if  v_job_id is not null then--create task only when it is nightly job
				insert into import
				(
					project_id,
					type_mask,
					job_id,
					source,
					is_manual
				)
					select
						imps.project_id,
						import_pkg.type_plan_auto,
						v_job_id, --imp.job_id,
						'CMBS',
						0
					from xmltable
							 (
							 xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
							 '//timeline/wbsNodes/wbs' passing p_payload
							 columns
									 wbs_id path '/wbs/@id',
							 parent_wbs_id path '/wbs/@parentId',
							 study_id path '/wbs/@studyId'
							 ) xt
					join import_study imps on (imps.study_id=xt.study_id and xt.parent_wbs_id=imps.parent_wbs_id)
					--join import imp on (imps.import_id=imp.id)
					where imps.import_id=p_id
					and xt.study_id is not null
					and imps.status_code='SEND'
					--and imp.job_id is not null --create task only when it is nightly job
					and xt.wbs_id is not null -- DONE
					and imps.wbs_id='#new#'--was send to P6 with a flag NEW
					group by imps.project_id
				;
				v_rowcount := sql%rowcount;
				v_sum_rowcount := v_sum_rowcount + v_rowcount;
				log_pkg.steps('b'||v_rowcount,v_step_start,v_steps_result);
			end if;

			--------------------------------------------------------------------

			insert into sys_guid
			(
				id,
				user_id,
				ba_code,
				project_id,
				--program_id,
				status_code,
				record_count,
				description
			)
				select
					ba_log_pkg.generate_guid,
					'PROMIS' user_id,
					'autoimportstudy' ba_code,
					imps.project_id,
					decode(xt.wbs_id,null,'ERROR','DONE') status_code,
					decode(xt.wbs_id,null,0,1) record_count,
					substr('Study{'||imps.study_id||':'||imps.study_name
					||'} has been '||decode(xt.wbs_id,null,'NOT ',null)
					||'imported to WBS{'||imps.parent_wbs_id||':'||wbs.name||'}'
					||decode(imps.fpfv_date,null,null,' using FPFV date{'
					||to_char(imps.fpfv_date,'dd.mm.yyyy')||'}'),1,4000) description
				from import_study imps
				left join
						(
							select
								xt.study_id,
								nvl(xt.parent_wbs_id,v_root_id) parent_wbs_id,--if missing then it means top level wbs id=project id
								--xt.parent_wbs_id,
								xt.wbs_id
							from xmltable
									 (xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
									 '//timeline/wbsNodes/wbs' passing p_payload
									 columns
											wbs_id path '/wbs/@id',
											parent_wbs_id path '/wbs/@parentId',
											study_id path '/wbs/@studyId'
									 ) xt
							where xt.study_id is not null
							and xt.wbs_id is not null -- DONE
						) xt on (imps.study_id=xt.study_id and xt.parent_wbs_id=imps.parent_wbs_id)
				left join timeline_wbs wbs on (wbs.project_id=imps.project_id and wbs.timeline_type_code='RAW' and wbs.wbs_id=xt.parent_wbs_id)
				where imps.import_id=p_id
				and imps.study_id is not null
				and imps.status_code='SEND'
				and imps.wbs_id='#new#';

			v_rowcount := sql%rowcount;
			v_sum_rowcount := v_sum_rowcount + v_rowcount;
			log_pkg.steps('c'||v_rowcount,v_step_start,v_steps_result);

		end if;

		update import_study set status_code='DONE'
		where import_id=p_id
		and status_code='SEND';

		v_rowcount := sql%rowcount;
		v_sum_rowcount := v_sum_rowcount + v_rowcount;
		log_pkg.steps('d'||v_rowcount,v_step_start,v_steps_result);

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where, v_par||';sum_rowcount='||v_sum_rowcount, v_steps_result);

	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.scatch(v_where, v_par||';sum_rowcount='||v_sum_rowcount, v_steps_result);
		raise;
	end;

	/*************************************************************************/
	procedure send_finish(p_id in nvarchar2, p_payload in xmltype)
	as
		v_is_ltc_exception int :=0;
		v_timeline_id timeline.id%type :=null;
		begin
			if message_pkg.is_error(p_payload) = 1 then
				update import set status_code='FAIL', timestamp_log=substr(timestamp_log||v_error,1,4000) where id=p_id;
				notice_pkg.catch(get_subject, get_summary||' finish failed.');
				return;
			end if;

			if message_pkg.is_complete(p_payload)=0 then
				return;
			end if;

			--select * into v_import from import where id=p_id and status_code='SEND';
			-- Removing additional filtering against import status. It is done to avoid data corruption when due to SOA fails, request messages are re-run manually. When it is done, import status is already set to FAIL, thus NO_DATA_FOUND
			-- exception is raised and relevant timeline data gets corrupted.
			select * into v_import from import where id=p_id;
			if v_import.project_id is not null then
				select * into v_project from project where id=v_import.project_id;
			end if;

			/* mark master */
			update import set sync_date=sysdate,is_syncing=0 where id=p_id;

			-- finish details
			finish_timeline(p_id);
			finish_study(p_id,p_payload);

			for rr in (select 1 from dual where exists (select project_id from ltc_project where project_id=v_import.project_id)) loop
				v_is_ltc_exception := 1;
			end loop;

			v_timeline_id:=p_payload.extract('//timeline/@id',message_pkg.xmlns_ipms).getStringVal();

			update timeline set details=p_payload.extract('//timeline',message_pkg.xmlns_ipms) where id=v_timeline_id;

			--Refreshing materialized data
			timeline_pkg.refresh_materialized_data(v_timeline_id,v_import.project_id,p_payload);

			project_activities_pkg.import_finish(p_import => v_import);

			finalize(p_id,p_payload);

			exception when others then
			v_error:=substr('finish2();sqlerrm='||sqlerrm,1,4000);

			update import set status_code='FAIL', timestamp_log=substr(timestamp_log||v_error,1,4000) where id=p_id;
			notice_pkg.catch(get_subject, get_summary||' merge failed.');
		end;

	/*************************************************************************/
	procedure cancel(p_id in nvarchar2)
	as
		v_rowcount pls_integer:=0;
		v_where nvarchar2(99):='import_pkg.cancel';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		select * into v_import from import where id=p_id;

		if v_import.project_id is not null then
			select * into v_project from project where id=v_import.project_id;
		end if;

		-- update status
		update import set is_syncing=0,status_code='DROP' where id=p_id;

		-- drop entries
		delete from import_costs where import_id=p_id;
		delete from import_costs_fps where import_id=p_id;
		delete from import_resources where import_id=p_id;
		delete from import_resources_cs where import_id=p_id;
		delete from import_resources_ged where import_id=p_id;
		delete from import_headcount where import_id=p_id;
		delete from import_timeline where import_id=p_id;
		delete from import_study where import_id=p_id;
		delete from import_study_fte where import_id=p_id;
		delete from import_masterdata where import_id=p_id;
		--delete from import_subfu nction where import_id=p_id;
		delete from import_sbe where import_id=p_id;
		delete from import_smu where import_id=p_id;
		delete from import_substance where import_id=p_id;
		delete from import_bay_number where import_id=p_id;
		delete from import_bay_combination where import_id=p_id;
		--delete from import_emp...loyee where import_id=p_id;
		delete from import_substance_combi where import_id=p_id;
		delete from import_ipowner where import_id=p_id;
		delete from import_subgroup where import_id=p_id;
		delete from import_maingroup where import_id=p_id;
		delete from import_topgroup where import_id=p_id;
		delete from import_bu where import_id=p_id;
		delete from import_project_activity_name where import_id=p_id;
		--v_rowcount := sql%rowcount;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result);

	end;

	/*************************************************************************/
	procedure finalize(p_id in nvarchar2, p_payload in xmltype)
	as
		v_rowcount pls_integer:=0;
		v_where nvarchar2(99):='import_pkg.finalize';
		v_par nvarchar2(4000):='p_id='||p_id;
		v_msg_out nvarchar2(4000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		begin
			log_pkg.steps(null,v_step_start,v_steps_result);


			if message_pkg.is_accept(p_payload)=1 then
				return;
			elsif message_pkg.is_complete(p_payload)=1 then

				select * into v_import from import where id=p_id;

				if v_import.is_manual=1 then
					log_pkg.slog(get_subject, get_summary, 'Finished.');
				end if;

				update import set is_syncing=0,status_code='DONE' where id=p_id;
			else
				update import set is_syncing=0, status_code='FAIL', timestamp_log=substr(timestamp_log||v_error,1,4000) where id=p_id;
				notice_pkg.catch(get_subject, get_summary||' finish failed.');
			end if;


			log_pkg.steps('END',v_procedure_start,v_steps_result);
			log_pkg.log(v_where, v_par, v_steps_result);

		end;


end;
/