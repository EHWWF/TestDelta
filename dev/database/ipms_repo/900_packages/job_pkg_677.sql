create or replace package job_pkg as
	/**
	 * Schedules all jobs.
	 */
	procedure setup;
	/**
	 * Stops all scheduled jobs.
	 */
	procedure teardown;
	/**
	 * MView refresh job.
	 */
	procedure refresh_mviews;
	procedure refresh_le_fct;
	procedure refresh_wbs_dim;
	procedure refresh_milestone_imp_dim;
	--Add only new instance LTCI data
	procedure insert_new_ltc;
end;
/
create or replace package body job_pkg as

	/*************************************************************************/
	procedure insert_new_ltc as
		v_where nvarchar2(99):='ipms_repo.job_pkg.insert_new_ltc';
		v_rowcount number:=0;
		v_timeline_id nvarchar2(55);
	begin
		ltc_pkg.update_all_ltc;
	exception when others then
		ipms_data.log_pkg.log(v_where, 'ERROR;rowcount='||v_rowcount, sqlerrm);
	end;

	/*************************************************************************/
	procedure refresh_le_fct as
		v_rowcount number;
		v_count_tab number;
		v_count_view number;
		v_where nvarchar2(99):='ipms_repo.job_pkg.refresh_le_fct';

	begin

		merge into latest_estimate_fct dest
		using (
			select
				process_id,--
				period_id,--
				max(decode (seq, 1, program_id)) program_id,
				project_id,--
				study_id,--
				study_status_id,--
				fct_id,--
				dev_phase,--
				max(decode (seq, 1, comment_y)) comment_y,
				max(decode (seq, 1, funding)) funding,
				max(decode (seq, 1, le_ext_det)) le_ext_det,
				max(decode (seq, 1, le_ext_prob)) le_ext_prob,
				max(decode (seq, 1, budget_ext_det)) budget_ext_det,
				max(decode (seq, 1, budget_ext_prob)) budget_ext_prob,
				max(decode (seq, 1, fc_ext_det)) fc_ext_det,
				max(decode (seq, 1, fc_ext_prob)) fc_ext_prob,
				max(decode (seq, 1, act_ext_det)) act_ext_det,
				max(decode (seq, 1, rr_ext_det)) rr_ext_det,
				max(decode (seq, 1, calf_ext_prob)) calf_ext_prob,
				max(decode (seq, 1, study_name)) study_name,
				max(decode (seq, 1, study_trial_phase)) study_trial_phase,
				max(decode (seq, 1, study_status_code)) study_status_code,
				max(decode (seq, 1, poc_date)) poc_date,
				max(decode (seq, 1, study_fpfv)) study_fpfv,
				max(decode (seq, 1, study_lplv)) study_lplv,
				max(decode (seq, 1, subtype_code)) subtype_code,
				max(decode (seq, 1, process_status_code)) process_status_code,
				sum(decode (seq, 1, srccnt, dstcnt)) iud
			from (
				select
					process_id,period_id,program_id,project_id,study_id,study_status_id,fct_id,dev_phase,comment_y,
					funding,le_ext_det,le_ext_prob,budget_ext_det,budget_ext_prob,fc_ext_det,fc_ext_prob,act_ext_det,
					rr_ext_det,calf_ext_prob,study_name,study_trial_phase,study_status_code,poc_date,study_fpfv,study_lplv,subtype_code,
					process_status_code,
					srccnt,
					dstcnt,
					row_number () over (partition by process_id,project_id,study_id,fct_id,study_status_id,period_id,dev_phase order by dstcnt nulls last) seq
				from (
					select
						process_id,period_id,program_id,project_id,study_id,study_status_id,fct_id,dev_phase,comment_y,
						funding,le_ext_det,le_ext_prob,budget_ext_det,budget_ext_prob,fc_ext_det,fc_ext_prob,act_ext_det,
						rr_ext_det,calf_ext_prob,study_name,study_trial_phase,study_status_code,poc_date,study_fpfv,study_lplv,subtype_code,
						process_status_code,
						count (src) srccnt, count (dst) dstcnt
					from (
						select process_id,period_id,program_id,project_id,study_id,study_status_id,fct_id,dev_phase,comment_y,
								funding,le_ext_det,le_ext_prob,budget_ext_det,budget_ext_prob,fc_ext_det,fc_ext_prob,act_ext_det,
								rr_ext_det,calf_ext_prob,study_name,study_trial_phase,study_status_code,poc_date,study_fpfv,study_lplv,subtype_code,
								process_status_code
								,1 src, to_number (null) dst
						from latest_estimate_fct_vw

						union all

						select process_id,period_id,program_id,project_id,study_id,study_status_id,fct_id,dev_phase,comment_y,
								funding,le_ext_det,le_ext_prob,budget_ext_det,budget_ext_prob,fc_ext_det,fc_ext_prob,act_ext_det,
								rr_ext_det,calf_ext_prob,study_name,study_trial_phase,study_status_code,poc_date,study_fpfv,study_lplv,subtype_code,
								process_status_code
								,to_number (null) src, 2 dst
						from latest_estimate_fct
					)
					group by process_id,period_id,program_id,project_id,study_id,study_status_id,fct_id,dev_phase,comment_y,
								funding,le_ext_det,le_ext_prob,budget_ext_det,budget_ext_prob,fc_ext_det,fc_ext_prob,act_ext_det,
								rr_ext_det,calf_ext_prob,study_name,study_trial_phase,study_status_code,poc_date,study_fpfv,study_lplv,subtype_code,
								process_status_code
					having count (src) <> count (dst)
				)
			)
			group by process_id,project_id,study_id,fct_id,study_status_id,period_id,dev_phase
		) diff
		on (
			 nvl(dest.process_id, '#') = nvl(diff.process_id, '#')
		and nvl(dest.project_id, '#') = nvl(diff.project_id, '#')
		and nvl(dest.study_id, '#') = nvl(diff.study_id, '#')
		and nvl(dest.fct_id, '#') = nvl(diff.fct_id, '#')
		and nvl(dest.study_status_id, -1) = nvl(diff.study_status_id, -1)
		and nvl(dest.period_id, -1) = nvl(diff.period_id, -1)
		and nvl(dest.dev_phase, '#') = nvl(diff.dev_phase, '#')
		)
		when matched
		then
			 update set
				  dest.program_id = diff.program_id
				 ,dest.comment_y = diff.comment_y
				 ,dest.funding = diff.funding
				 ,dest.le_ext_det = diff.le_ext_det
				 ,dest.le_ext_prob = diff.le_ext_prob
				 ,dest.budget_ext_det = diff.budget_ext_det
				 ,dest.budget_ext_prob = diff.budget_ext_prob
				 ,dest.fc_ext_det = diff.fc_ext_det
				 ,dest.fc_ext_prob = diff.fc_ext_prob
				 ,dest.act_ext_det = diff.act_ext_det
				 ,dest.rr_ext_det = diff.rr_ext_det
				 ,dest.calf_ext_prob = diff.calf_ext_prob
				 ,dest.study_name = diff.study_name
				 ,dest.study_trial_phase = diff.study_trial_phase
				 ,dest.study_status_code = diff.study_status_code
				 ,dest.poc_date = diff.poc_date
				 ,dest.study_fpfv = diff.study_fpfv
				 ,dest.study_lplv = diff.study_lplv
				 ,dest.subtype_code = diff.subtype_code
				 ,dest.process_status_code = diff.process_status_code
			 delete
					where (diff.iud = 0)
		when not matched
		then
			 insert (process_id,period_id,program_id,project_id,study_id,study_status_id,fct_id,dev_phase,comment_y,
						funding,le_ext_det,le_ext_prob,budget_ext_det,budget_ext_prob,fc_ext_det,fc_ext_prob,act_ext_det,
						rr_ext_det,calf_ext_prob,study_name,study_trial_phase,study_status_code,poc_date,study_fpfv,study_lplv,subtype_code,process_status_code)
			 values (diff.process_id,diff.period_id,diff.program_id,diff.project_id,diff.study_id,diff.study_status_id,diff.fct_id,diff.dev_phase,diff.comment_y,
						diff.funding,diff.le_ext_det,diff.le_ext_prob,diff.budget_ext_det,diff.budget_ext_prob,diff.fc_ext_det,diff.fc_ext_prob,diff.act_ext_det,
						diff.rr_ext_det,diff.calf_ext_prob,diff.study_name,diff.study_trial_phase,diff.study_status_code,diff.poc_date,diff.study_fpfv,diff.study_lplv,diff.subtype_code,diff.process_status_code);

		v_rowcount:=sql%rowcount;
		select count(1) into v_count_tab from latest_estimate_fct;
		select count(1) into v_count_view from latest_estimate_fct_vw;

		ipms_data.log_pkg.log(v_where, 'v_count_view_SRC='||v_count_view||';v_count_tab_DST='||v_count_tab||';v_rowcount='||v_rowcount,'Updated.');

	exception when others then
		ipms_data.log_pkg.log(v_where, 'v_count_view_SRC='||v_count_view||';v_count_tab_DST='||v_count_tab||';v_rowcount='||v_rowcount, sqlerrm);
		raise;
	end;

	/*************************************************************************/
	procedure refresh_mviews as
		v_where nvarchar2(99):='ipms_repo.job_pkg.refresh_mviews';
		v_count pls_integer;
		v_loop pls_integer:=0;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;

	begin
		ipms_data.log_pkg.steps(null,v_step_start,v_steps_result);

		ipms_data.baseline_pkg.get_missing_baselines;
		ipms_data.log_pkg.log(v_where, 'Done.','Done.');


		select count(1) into v_count
		from all_mviews
		where owner like
			(
				select sys_context('userenv', 'current_schema')	from dual
			)
		and mview_name <> 'LATEST_ESTIMATE_FCT'--dedicated table
		and mview_name <> 'WBS_DIM'
		and mview_name <> upper('milestone_impact_fct')
        AND mview_name <> 'STUDY_DIM' --to exclude STUDY_DIM MV and new created job
        ;
             
		for mview_cursor in (
				select mview_name
				from all_mviews
				where owner like
					(
						select sys_context('userenv', 'current_schema') from dual
					)
				and mview_name <> 'LATEST_ESTIMATE_FCT'
				and mview_name <> 'WBS_DIM'
				and mview_name <> upper('milestone_impact_fct')   
                AND mview_name <> 'STUDY_DIM' --to exclude STUDY_DIM MV and new created job
		  order by mview_name
		)
		loop
			begin
				v_loop:=v_loop+1;              
				dbms_mview.refresh(mview_cursor.mview_name, 'c');
				ipms_data.log_pkg.log(v_where, 'DONE.'||v_loop||'/'||v_count, mview_cursor.mview_name);
				ipms_data.sleep(10);--10sec
				--ipms_data.log_pkg.steps(mview_cursor.mview_name,v_step_start,v_steps_result);
			exception when others then
				ipms_data.log_pkg.log(v_where, 'OTHERS.LOOP,mview_cursor.mview_name='||mview_cursor.mview_name, sqlerrm);
			end;
		end loop;
    
       ipms_data.log_pkg.steps('loop('||v_loop||'/'||v_count||')',v_step_start,v_steps_result);

		--Custom refresh-LE!
		begin
			job_pkg.refresh_le_fct;
			--ipms_data.log_pkg.log(v_procedure_name, 'DONE.', 'custom:LE');
		exception when others then
			begin
				execute immediate 'truncate table latest_estimate_fct drop storage';
				job_pkg.refresh_le_fct;
				ipms_data.log_pkg.log(v_where, 'DONE.', 'custom:LE+truncate.');
			exception when others then
				ipms_data.log_pkg.log(v_where, 'OTHERS.CUSTOM.refresh_le_fct', sqlerrm);
			end;
		end;

		ipms_data.log_pkg.steps('le',v_step_start,v_steps_result);

		--Custom refresh-WBS!
		begin
			job_pkg.refresh_wbs_dim;
			--ipms_data.log_pkg.log(v_procedure_name, 'DONE.', 'custom:WBS');
		exception when others then
			begin
				execute immediate 'truncate table wbs_dim drop storage';
				job_pkg.refresh_wbs_dim;
				ipms_data.log_pkg.log(v_where, 'DONE.', 'custom:WBS+truncate.');
			exception when others then
				ipms_data.log_pkg.log(v_where, 'OTHERS.CUSTOM.refresh_wbs_dim', sqlerrm);
			end;
		end;

		ipms_data.log_pkg.steps('wbs',v_step_start,v_steps_result);

		--Custom refresh-MILESTONE!
		begin
			job_pkg.refresh_milestone_imp_dim;
			--ipms_data.log_pkg.log(v_procedure_name, 'DONE.', 'custom:MILESTONE');
		exception when others then
			begin
				execute immediate 'truncate table milestone_impact_fct drop storage';
				job_pkg.refresh_milestone_imp_dim;
				ipms_data.log_pkg.log(v_where, 'DONE.', 'custom:MILESTONE+truncate.');
			exception when others then
				ipms_data.log_pkg.log(v_where, 'OTHERS.CUSTOM-refresh!', sqlerrm);
			end;
		end;

		ipms_data.log_pkg.steps('mile',v_step_start,v_steps_result);

		ltc_pkg.update_ltc_dim(null,null,null,null);

	 --Just in case, it coud happen that during quick fixes GRANTs can be deleted too, run if needed.
		for run in (
			select distinct 'grant select on ipms_repo.'||object_name||' to mycsd' as cmd
			from all_objects
			where owner=upper('ipms_repo')
			and object_type in ('TABLE','MATERIALIZED VIEW')
			and not object_name like 'AQ%'
			and not object_name like '%_QT'
			and not object_name like '%_QT_F'
			and not object_name like '%_TAB'
			and not object_name like 'COMBASE_%'
			and not object_name like 'SOPHIA_%'
			and object_name <>'LATEST_ESTIMATE_FCT_VW'
			and object_name not in
											(select table_name --,owner, grantee, select_priv
											from table_privileges
											where owner =upper('ipms_repo')
											and grantee = upper('mycsd')
											and select_priv='Y')
			order by 1
			)
		loop
			begin
				--ipms_data.log_pkg.log(v_where, 'BEGIN.ROLE', run.cmd);
					execute immediate run.cmd;
				--ipms_data.log_pkg.log(v_where, 'END.ROLE', run.cmd);
			exception when others then
			  ipms_data.log_pkg.log(v_where, 'ERROR-OTHERS.ROLE!,run.cmd='||run.cmd, sqlerrm);
			end;
		end loop;

		ipms_data.log_pkg.steps('grant',v_step_start,v_steps_result);

		if to_number(to_char(sysdate,'hh24'))>20 or to_number(to_char(sysdate,'hh24'))<5 then --sumarrization could run only during not working hours: 20.00 -> 5.00
			--ipms_data.timeline_pkg.summarize_loop(1);
			null;
		end if;

		ipms_data.log_pkg.steps('END',v_procedure_start,v_steps_result);
		ipms_data.log_pkg.log(v_where, ipms_data.log_pkg.g_done, ipms_data.log_pkg.g_done||v_steps_result);

	 exception when others then
		--ipms_data.log_pkg.log(v_procedure_name, 'ERROR-OTHERS!', sqlerrm);
		ipms_data.log_pkg.catch(v_where,'ERROR-OTHERS!',v_steps_result);
		ipms_data.notify_pkg.ipms_repo_job_failed;
		raise;
    end;    
	/*************************************************************************/
	procedure setup as
	begin
		dbms_scheduler.create_job (
			job_name => 'reporting_job',
			job_type => 'plsql_block',
			job_action => 'begin job_pkg.refresh_mviews;commit;  end;',
			start_date => trunc(sysdate+1)+3/24,
			repeat_interval => 'freq=daily; interval=1;',
			end_date => null,
			enabled => true,
			comments => 'Job defined entirely by the create job procedure.');
	end;

	/*************************************************************************/
	procedure teardown as
	begin
		dbms_scheduler.stop_job (
			job_name => 'reporting_job',
			force => true,
			commit_semantics => 'ABSORB_ERRORS');

		dbms_scheduler.drop_job (
			job_name => 'reporting_job',
			force => true);
	end;

	/*************************************************************************/
	procedure refresh_wbs_dim as
		v_rowcount number;
		v_count_tab number;
		v_count_view number;
		v_where nvarchar2(99):='ipms_repo.job_pkg.refresh_wbs_dim';
	begin

		merge into wbs_dim dest
		using (
			select
				id,
				max(decode (seq, 1, name)) name,
				max(decode (seq, 1, project_id)) project_id,
				max(decode (seq, 1, sandbox_id)) sandbox_id,
				max(decode (seq, 1, timeline_id)) timeline_id,
				max(decode (seq, 1, timeline_type_code)) timeline_type_code,
				max(decode (seq, 1, reference_id)) reference_id,
				sum(decode (seq, 1, srccnt, dstcnt)) iud
			from (
				select
					id,name,project_id,sandbox_id,timeline_id,timeline_type_code,reference_id,
					srccnt,
					dstcnt,
					row_number () over (partition by id order by dstcnt nulls last) seq
				from (
					select
						id,name,project_id,sandbox_id,timeline_id,timeline_type_code,reference_id,
						count (src) srccnt, count (dst) dstcnt
					from (
						select id,name,project_id,sandbox_id,timeline_id,timeline_type_code,reference_id
								,1 src, to_number (null) dst
						from wbs_dim_vw

						union all

						select id,name,project_id,sandbox_id,timeline_id,timeline_type_code,reference_id
								,to_number (null) src, 2 dst
						from wbs_dim
					)
					group by id,name,project_id,sandbox_id,timeline_id,timeline_type_code,reference_id
					having count (src) <> count (dst)
				)
			)
			group by id,name,project_id,sandbox_id,timeline_id,timeline_type_code,reference_id
		) diff
		on (dest.id = diff.id)
		when matched
		then
			 update set
				  dest.name = diff.name
				 ,dest.project_id = diff.project_id
				 ,dest.sandbox_id = diff.sandbox_id
				 ,dest.timeline_id = diff.timeline_id
				 ,dest.timeline_type_code = diff.timeline_type_code
				 ,dest.reference_id = diff.reference_id
			 delete
					where (diff.iud = 0)
		when not matched
		then
			 insert (id,name,project_id,sandbox_id,timeline_id,timeline_type_code,reference_id)
			 values (diff.id,diff.name,diff.project_id,diff.sandbox_id,diff.timeline_id,diff.timeline_type_code,diff.reference_id);

		v_rowcount:=sql%rowcount;
		select count(1) into v_count_tab from wbs_dim;
		select count(1) into v_count_view from wbs_dim_vw;

		ipms_data.log_pkg.log(v_where, 'v_count_view_SRC='||v_count_view||';v_count_tab_DST='||v_count_tab||';v_rowcount='||v_rowcount,'Updated.');

	exception when others then
		ipms_data.log_pkg.log(v_where, 'v_count_view_SRC='||v_count_view||';v_count_tab_DST='||v_count_tab||';v_rowcount='||v_rowcount,sqlerrm);
		raise;
	end;

	/*************************************************************************/
	procedure refresh_milestone_imp_dim
	as
		v_rowcount number;
		v_count_tab number;
		v_count_view number;
		v_where nvarchar2(99):='ipms_repo.job_pkg.refresh_milestone_imp_dim';
		v_status nvarchar2(99);
	begin
		merge into milestone_impact_fct dest
		using (
			select
				--max(decode (seq, 1, project_id)) project_id,
				project_id,
				--max(decode (seq, 1, promis_project_id)) promis_project_id,
				study_id,
				study_element_id,
				max(decode (seq, 1, plan_start_date)) plan_start_date,
				max(decode (seq, 1, act_start_date)) act_start_date,
				max(decode (seq, 1, plan_finish_date)) plan_finish_date,
				max(decode (seq, 1, act_finish_date)) act_finish_date,
				sum(decode (seq, 1, srccnt, dstcnt)) iud
			from (
				select
					project_id,
					--promis_project_id,
					study_id,
					study_element_id,
					plan_start_date,
					act_start_date,
					plan_finish_date,
					act_finish_date,
					srccnt,
					dstcnt,
					row_number () over (partition by project_id,study_id,study_element_id order by dstcnt nulls last) seq
				from (
					select
						project_id,
						--promis_project_id,
						study_id,
						study_element_id,
						plan_start_date,
						act_start_date,
						plan_finish_date,
						act_finish_date,
						count (src) srccnt, count (dst) dstcnt
					from (
						select
							project_id,
							--promis_project_id,
							study_id,
							study_element_id,
							plan_start_date,
							act_start_date,
							plan_finish_date,
							act_finish_date
							,1 src, to_number (null) dst
						from ipms_data.sophia_timeline_flat_vw
						where project_id is not null --PROMISIII-435 --skip NULL project_id
							union all
						select
							to_nchar(project_id) project_id,
							--promis_project_id,
							to_nchar(study_id) study_id,
							to_nchar(study_element_id) study_element_id,
							plan_start_date,
							act_start_date,
							plan_finish_date,
							act_finish_date
							,to_number (null) src, 2 dst
						from milestone_impact_fct
					)
					group by
						project_id,
						--promis_project_id,
						study_id,
						study_element_id,
						plan_start_date,
						act_start_date,
						plan_finish_date,
						act_finish_date
					having count (src) <> count (dst)
				)
			)
			group by
				project_id,
				--promis_project_id,
				study_id,
				study_element_id,
				plan_start_date,
				act_start_date,
				plan_finish_date,
				act_finish_date
		) diff
		on (
			nvl(dest.project_id,'###') = nvl(diff.project_id,'###') and
			nvl(dest.study_id,'###') = nvl(diff.study_id,'###') and
			nvl(dest.study_element_id,'###') = nvl(diff.study_element_id,'###')
			)
		when matched
		then
			 update set
					--dest.promis_project_id = diff.promis_project_id
					dest.plan_start_date = diff.plan_start_date
					,dest.act_start_date = diff.act_start_date
					,dest.plan_finish_date = diff.plan_finish_date
					,dest.act_finish_date = diff.act_finish_date
			 delete
					where (diff.iud = 0)
		when not matched
		then
			 insert (project_id,study_id,study_element_id,plan_start_date,act_start_date,plan_finish_date,act_finish_date)
			 values (diff.project_id,diff.study_id,diff.study_element_id,diff.plan_start_date,diff.act_start_date,diff.plan_finish_date,diff.act_finish_date);

		v_rowcount:=sql%rowcount;
		select count(1) into v_count_tab from milestone_impact_fct;--DST
		select count(1) into v_count_view from ipms_data.sophia_timeline_flat_vw where project_id is not null;--SRC

		if v_count_tab<>v_count_view then
			v_status:='ERROR';
		else
			v_status:='SUCCESS.UPDATED.';
		end if;

		ipms_data.log_pkg.log(v_where, 'v_count_view_SRC='||v_count_view||';v_count_tab_DST='||v_count_tab||';v_rowcount='||v_rowcount,v_status);

	exception when others then
		ipms_data.log_pkg.log(v_where, 'v_count_view_SRC='||v_count_view||';v_count_tab_DST='||v_count_tab||';v_rowcount='||v_rowcount,sqlerrm);
		raise;
	end;

end;
/
