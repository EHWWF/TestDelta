drop materialized view export_latest_estimate_vw;
create materialized view export_latest_estimate_vw as
select * from (
select 
	lele.*,
	decode(budget_ny_det||forecast_ny_det||budget_ny_prob||forecast_ny_prob||calculated_forecast_ny_prob||estimate_ny_det||estimate_ny_prob,null,null,current_year+1) next_year
	from (
select
	le.process_id,
	lep.year||'_'||upper(replace(replace(lep.name,' '),'_')) process_code,
	lep.name as process_name,
	le.project_id,
	le.development_phase_code,
	le.subtype_code,
	prj.sbe_code,
	prj.code as project_code,
	le.program_id,
	prg.code as program_code,
	le.study_id,
	le.study_status_code,
	to_char(le.study_name) as study_name,
	std.is_obligation as study_is_obligation,
	std.is_probing as study_is_probing,
	std.is_gpdc_approved as study_is_gpdc_approved,
	to_char(le.study_phase) as study_trial_phase,
	le.comments_curr_year as comments_cy,
	le.comments_next_year as comments_ny,
	le.study_fpfv,
	le.study_lplv,
	le.curr_act_det as actuals_cy_det,
	le.curr_bgt_det as budget_cy_det,
	le.curr_fct_det as forecast_cy_det,
	le.curr_rr_det as runrate_cy_det,
	le.curr_bgt_prob as budget_cy_prob,
	le.curr_fct_prob as forecast_cy_prob,
	le.curr_cfct_prob as calculated_forecast_cy_prob,
	le.next_bgt_det as budget_ny_det,
	le.next_fct_det as forecast_ny_det,
	le.next_bgt_prob as budget_ny_prob,
	le.next_fct_prob as forecast_ny_prob,
	le.next_cfct_prob as calculated_forecast_ny_prob,
	le.estimate_det_curr_year as estimate_cy_det,
	le.estimate_det_next_year as estimate_ny_det,
	le.estimate_prob_curr_year as estimate_cy_prob,
	le.estimate_prob_next_year as estimate_ny_prob,
	fund_y1.amount as funding_cy,
	fund_y2.amount as funding_ny,
	le.poc_date,
	le.function_code,
	lep.termination_date,
	le.is_placeholder,
	lep.year current_year
from latest_estimate le
join latest_estimates_process lep on lep.id=le.process_id
join project prj on prj.id=le.project_id and prj.pidt_release_date is not null and prj.program_id<>'RBIN'
join program prg on prg.id=le.program_id
left join study_data_vw std on std.project_id=le.project_id and std.id=le.study_id and std.timeline_type_code='CUR'
left join funding fund_y1 on fund_y1.project_id=le.project_id and fund_y1.year=lep.year
left join funding fund_y2 on fund_y2.project_id=le.project_id and fund_y2.year=lep.year+1
) lele
);
grant select on export_latest_estimate_vw to ipms_repo;
grant select on export_latest_estimate_vw to mxcbi;
grant select on export_latest_estimate_vw to mycsd;