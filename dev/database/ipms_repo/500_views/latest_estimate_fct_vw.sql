create or replace view latest_estimate_fct_vw as
select
	lep.id as process_id,
	t.period_id,
	p.program_id as program_id,
	le.project_id,
	le.study_id,
	status_dim.study_status_id,
	le.function_code as fct_id,
	dp.name as dev_phase,
	case when ny.lvl = 0 then le.comments_curr_year else le.comments_next_year end comment_y,
	case when ny.lvl = 0 then fund_y1.amount else fund_y2.amount end funding,
	sum(decode(ny.lvl, 0, le.estimate_det_curr_year, le.estimate_det_next_year)) le_ext_det,
	sum(decode(ny.lvl, 0, le.estimate_prob_curr_year, le.estimate_prob_next_year)) le_ext_prob,
	sum(decode(ny.lvl, 0, le.curr_bgt_det, le.next_bgt_det)) budget_ext_det,
	sum(decode(ny.lvl, 0, le.curr_bgt_prob, le.next_bgt_prob)) budget_ext_prob,
	sum(decode(ny.lvl, 0, le.curr_fct_det, le.next_fct_det)) fc_ext_det,
	sum(decode(ny.lvl, 0, le.curr_fct_prob, le.next_fct_prob)) fc_ext_prob,
	sum(decode(ny.lvl, 0, le.curr_act_det, null)) act_ext_det,
	sum(decode(ny.lvl, 0, le.curr_rr_det, null)) rr_ext_det,
	sum(decode(ny.lvl, 0, le.curr_cfct_prob, le.next_cfct_prob)) calf_ext_prob,
	to_char(max(le.study_name)) as study_name,
	to_char(max(le.study_phase)) as study_trial_phase,
	le.study_status_code,
	le.poc_date,
	max(le.study_fpfv) as study_fpfv,
	max(le.study_lplv) as study_lplv,
	nvl(le.subtype_code, le.study_status_code) as subtype_code,
	lep.status_code process_status_code
from ipms_data.latest_estimates_process lep
join (select level-1 lvl from dual connect by level<3) ny on ny.lvl=0 or ny.lvl=1 and lep.is_next_year=1
join ipms_repo.period_dim t on t.year=(lep.year+ny.lvl) and t.month_of_year=1
join ipms_data.latest_estimate le on le.process_id=lep.id and
    (ny.lvl=0 and (le.estimate_det_curr_year is not null or le.estimate_prob_curr_year is not null) or ny.lvl=1 and (le.estimate_det_next_year is not null or le.estimate_prob_next_year is not null))
join ipms_data.project p on p.id=le.project_id
left join ipms_repo.study_status_dim status_dim on status_dim.study_status_code = nvl(le.subtype_code, le.study_status_code)
left outer join ipms_data.development_phase dp on le.development_phase_code=dp.code
left join ipms_data.funding fund_y1 on fund_y1.project_id=le.project_id and fund_y1.year=lep.year
left join ipms_data.funding fund_y2 on fund_y2.project_id=le.project_id and fund_y2.year=lep.year+1
--where lep.status_code='FIN' --commented out, for more info see jira: PROMIS-568
group by 
	lep.id,
	t.period_id,
	dp.name,
	p.program_id,
	le.project_id,
	le.study_id,
	status_dim.study_status_id,
	le.function_code,
	le.comments_curr_year,
	le.comments_next_year,
	fund_y1.amount,
	fund_y2.amount,
	case when ny.lvl = 0 then le.comments_curr_year else le.comments_next_year end,
	case when ny.lvl = 0 then fund_y1.amount else fund_y2.amount end,
	le.study_status_code,
	le.poc_date,nvl(le.subtype_code, le.study_status_code),
	lep.status_code
;