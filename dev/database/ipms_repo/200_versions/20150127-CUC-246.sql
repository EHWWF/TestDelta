drop materialized view project_dim;

create materialized view project_dim as
select
	p.id,
	p.program_id,
	p.code,
	p.name,
	p.abbreviation as short_name,
	p.state_code as project_state_code,
	pstate.name as project_state,
	p.is_active,
	p.is_lead,
	p.development_phase_code as le_overview_code,
	devphase.name as le_overview,
	p.sbe_code,
	sbe.name as sbe,
	p.gbu_code,
	gbu.name as gbu,
	p.ta_code as therapeutic_area_code,
	pta.name as therapeutic_area,
	p.area_code as project_area_code,
	area.name as project_area,
	p.phase_code,
	phase.name as phase,
	p.priority_code,
	prio.name as priority,
	p.category_code as lc_type_code,
	category.name as lc_type,
	p.substance_type_code,
	substance_type.name as substance_type,
	p.source_code,
	source.name as source,
	p.enpv,
	p.npv,
	p.peak_sales,
	p.is_portfolio as portfolio_project,
	p.is_hpr as hpr,
	p.is_regional,
	p.is_orphan_drug,
	p.is_direct_phase3,
	p.is_combined_phase2,
	p.is_collaboration as collaboration,
	p.is_pip as pip_project,
	p.pip_date,
	p.pdco_date,
	p.is_pdco_positive,
	p.is_waiver,
	p.pip_activities,
	termination.name as termination_name,
	p.termination_code,
	p.termination_date,
	p.termination_reason,
	pts_preclinical.probability as pts_preclinical,
	pts_phase1.probability as pts_phase1,
	pts_phase2.probability as pts_phase2,
	pts_phase3.probability as pts_phase3,
	pts_submission.probability as pts_submission,
	round(100 * nvl(pts_preclinical.probability / 100, 0) * nvl(pts_phase1.probability / 100, 0) * nvl(pts_phase2.probability / 100, 0) * nvl(pts_phase3.probability / 100, 0) * nvl(pts_submission.probability / 100, 0)) as pts_total,
	p.review_date as review_meeting_date,
	p.details_partner,
	p.details_progress,
	p.progress_date,
	p.details_criteria,
	p.details_mesh,
	p.details_indication,
	p.details_product,
	p.details_goal,
	p.details_action,
	p.details_competition,
	p.details_patent,
	p.details_sales,
	p.details_pmo,
	combination.combination_code,
	combination.combination_name as combination_id,
	pbay.name as preferred_bay_no,
	p.id||'-RAW' as p6_raw_plan,
	p.id||'-CUR' as p6_current_plan,
	p.id||'-APR' as p6_approved_plan,
  p.planning_enabled,
  p.ipowner_code as ip_owner_code,
  ipowner.name as ip_owner
from ipms_data.project p
left join ipms_data.combination_vw combination on combination.project_id = p.id
left join ipms_data.bay_number pbay on pbay.code = p.bay_code
left join ipms_data.project_state pstate on pstate.code = p.state_code
left join ipms_data.display_state displaystate on displaystate.code = p.display_state_code
left join ipms_data.development_phase devphase on devphase.code = p.development_phase_code
left join ipms_data.strategic_business_entity sbe on sbe.code = p.sbe_code
left join ipms_data.global_business_unit gbu on gbu.code = p.gbu_code
left join ipms_data.therapeutic_area pta on pta.code = p.ta_code
left join ipms_data.project_area area on area.code = p.area_code
left join ipms_data.phase phase on phase.code = p.phase_code
left join ipms_data.priority prio on prio.code = p.priority_code
left join ipms_data.project_category category on category.code = p.category_code
left join ipms_data.substance_type substance_type on substance_type.code = p.substance_type_code
left join ipms_data.project_source source on source.code = p.source_code
left join ipms_data.termination_reason termination on termination.code = p.termination_code
left join ipms_data.costs_probability pts_preclinical on pts_preclinical.project_id = p.id and pts_preclinical.phase_code = '1' and pts_preclinical.scope_code = 'INT'
left join ipms_data.costs_probability pts_phase1 on pts_phase1.project_id = p.id and pts_phase1.phase_code = '2' and pts_phase1.scope_code = 'INT'
left join ipms_data.costs_probability pts_phase2 on pts_phase2.project_id = p.id and pts_phase2.phase_code = '34' and pts_phase2.scope_code = 'INT'
left join ipms_data.costs_probability pts_phase3 on pts_phase3.project_id = p.id and pts_phase3.phase_code = '5' and pts_phase3.scope_code = 'INT'
left join ipms_data.costs_probability pts_submission on pts_submission.project_id = p.id and pts_submission.phase_code = '6' and pts_submission.scope_code = 'INT'
left join ipms_data.ipowner ipowner on ipowner.code = p.ipowner_code;



drop materialized view cost_cs_fct;

create materialized view cost_cs_fct as
select x.* from (
select
    t.period_id,
    cst.project_id,
    cst.study_id,
    sf.function_code as fct_id,
    cst.subfunction_code as subfct_id,
    sum(decode(type,'FCT-EXT-DET-CMT',cost,null)) as fct_ext_det_cmt,
    sum(decode(type,'FCT-EXT-DET-UMT',cost,null)) as fct_ext_det_umt,
    sum(decode(type,'FCT-EXT-PROB-CMT',cost,null)) as fct_ext_prob_cmt,
    sum(decode(type,'FCT-EXT-PROB-UMT',cost,null)) as fct_ext_prob_umt,
    sum(decode(type,'ACT-EXT-DET',cost,null)) as act_ext_det,
    sum(decode(type,'FCT-INT-DET',cost,null)) as fct_int_det,
    sum(decode(type,'ACT-INT-DET',cost,null)) as act_int_det
from (select cst.*, type_code||'-'||scope_code||'-'||method_code||decode(committed_state,'Committed','-CMT', 'Not Committed','-UMT', '') type from ipms_data.costs_cs cst where type_code in ('FCT','ACT')) cst
join ipms_repo.period_dim t on t.year=extract(year from cst.finish_date) and t.month_of_year=extract(month from cst.finish_date)
join ipms_data.subfunction sf on sf.code=cst.subfunction_code
where cost<>0
group by cst.project_id,cst.study_id,sf.function_code,cst.subfunction_code,t.period_id
) x
cross join (select 1 from dual);



drop materialized view cost_ged_fct;

create materialized view cost_ged_fct as
select x.* from (
select
    t.period_id,
    cst.project_id,
    cst.study_id,
    sf.function_code as fct_id,
    cst.subfunction_code as subfct_id,
    sum(decode(type,'FCT-EXT-DET-CMT',cost,null)) as fct_ext_det_cmt,
    sum(decode(type,'FCT-EXT-DET-UMT',cost,null)) as fct_ext_det_umt,
    sum(decode(type,'ACT-EXT-DET',cost,null)) as act_ext_det,
    sum(decode(type,'FCT-INT-DET',cost,null)) as fct_int_det,
    sum(decode(type,'ACT-INT-DET',cost,null)) as act_int_det
from (select cst.*, type_code||'-'||scope_code||'-'||method_code||decode(committed_state,'Committed','-CMT', 'Not Committed','-UMT', '') type from ipms_data.costs_ged cst where type_code in ('FCT','ACT')) cst
join ipms_repo.period_dim t on t.year=extract(year from cst.finish_date) and t.month_of_year=extract(month from cst.finish_date)
join ipms_data.subfunction sf on sf.code=cst.subfunction_code
where cost<>0
group by cst.project_id,cst.study_id,sf.function_code,cst.subfunction_code,t.period_id
) x
cross join (select 1 from dual);



drop materialized view resource_cs_fct;

create materialized view resource_cs_fct as
select x.* from (
select
    t.period_id,
    rsc.project_id,
    rsc.study_id,
    sf.function_code as fct_id,
    rsc.subfunction_code as subfct_id,
    sum(decode(type,'PLAN-DET',demand,null)) as plan_det,
    sum(decode(type,'ACT-DET',demand,null)) as act_det
from (select rsc.*, type_code||'-'||method_code type from ipms_data.resources_cs rsc where type_code in ('ACT','PLAN')) rsc
join ipms_repo.period_dim t on t.year=extract(year from rsc.finish_date) and t.month_of_year=extract(month from rsc.finish_date)
join ipms_data.subfunction sf on sf.code=rsc.subfunction_code
where demand>0
group by rsc.project_id,rsc.study_id,sf.function_code,rsc.subfunction_code,t.period_id
) x
cross join (select 1 from dual);



drop materialized view resource_ged_fct;

create materialized view resource_ged_fct as
select x.* from (
select
    t.period_id,
    rsc.project_id,
    rsc.study_id,
    sf.function_code as fct_id,
    rsc.subfunction_code as subfct_id,
    sum(decode(type,'PLAN-DET',demand,null)) as plan_det,
    sum(decode(type,'ACT-DET',demand,null)) as act_det
from (select rsc.*, type_code||'-'||method_code type from ipms_data.resources_ged rsc where type_code in ('ACT','PLAN')) rsc
join ipms_repo.period_dim t on t.year=extract(year from rsc.finish_date) and t.month_of_year=extract(month from rsc.finish_date)
join ipms_data.subfunction sf on sf.code=rsc.subfunction_code
where demand>0
group by rsc.project_id,rsc.study_id,sf.function_code,rsc.subfunction_code,t.period_id
) x
cross join (select 1 from dual);


