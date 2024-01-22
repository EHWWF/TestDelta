create or replace view baseline_study_data_vw as
select
	t.project_id,
	null sandbox_id,
	replace(replace(replace(xt.timeline_id,'-RAW'),'-CUR'),'-APR')||'-'||xt.baseline_id||'-BSL' as timeline_id,
	xt.baseline_id,
	xt.timeline_id as root_timeline_id,
	xt.timeline_type_code,
	xt.wbs_id,
	xt.study_id,
	xt.study_id as id,
	xt.code,
	xt.name,
	st.study_name,
	xt.start_date,
	xt.finish_date,
	xt.study_phase as phase,
	xt.placeholder,
	case
		when trunc(nvl(fp.milestone_date, xt.start_date)) <= trunc(last_day(sysdate))
		then 'RUN'
		when trunc(nvl(fp.milestone_date, xt.start_date)) <= trunc(last_day(add_months(sysdate,cs.value)))
		then 'COMM'
		when trunc(nvl(fp.milestone_date, xt.start_date)) > trunc(last_day(add_months(sysdate,cs.value))) or xt.placeholder=0 and fp.milestone_date is null
		then 'PLAN'
		else 'OTHER'
	end as status_code,
	count(distinct xt.wbs_id) over(partition by xt.timeline_id,xt.study_id) as wbs_count,
	fp.milestone_date as fpfv,
	lp.milestone_date as lplv,
	dmc_actual.milestone_date as dmc_actual,
	dmc_plan.milestone_date as dmc_plan,
	csrapp.milestone_date as csrapp,
	prcompl.milestone_date as prcompl,
	cdblock.milestone_date as cdblock,
	nvl(st.is_obligation,0) as is_obligation,
	nvl(st.is_probing,0) as is_probing,
	nvl(st.is_gpdc_approved,0) as is_gpdc_approved,
		xt.plan_patients,
		xt.actual_patients,
	st.int_ext_flag,
	st.study_modus_no,
	st.study_modus_name,
	st.clin_plan_type,
		xt.study_unit_count,
		xt.study_unit_count_plan,
	st.therapeutic_group_code,
	st.therapeutic_group_desc,
	st.is_timeline_auto_import,
	st.is_study_auto_import,
	st.volunteer_flag,
		xt.study_country_count,
		xt.study_country_count_plan,
	st.subject_type,
		xt.plan_entered_screen,
		xt.act_entered_screen,
	st.is_lead,
		xt.fte_avg
from baseline_wbs_vw xt
join configuration cs on cs.code='STD-MM'
join timeline t on (xt.timeline_id=t.id)
left join study st on st.project_id=t.project_id and st.id=xt.study_id
left join (
	select
		ms.timeline_id,
		ms.wbs_id,
		ms.milestone_date,
		row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.milestone_date desc) as rn
	from baseline_milestone_vw ms
	join configuration cf on cf.code='FPFV' and lower(cf.value)=lower(ms.milestone_id)
) fp on fp.timeline_id=xt.timeline_id and fp.wbs_id=xt.wbs_id and fp.rn=1
left join (
	select
		ms.timeline_id,
		ms.wbs_id,
		ms.milestone_date,
		row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.milestone_date desc) as rn
	from baseline_milestone_vw ms
	join configuration cf on cf.code='LPLV' and lower(cf.value)=lower(ms.milestone_id)
) lp on lp.timeline_id=xt.timeline_id and lp.wbs_id=xt.wbs_id and lp.rn=1
left join (
	select
		ms.timeline_id,
		ms.wbs_id,
		ms.actual_date as milestone_date,
		row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.actual_date desc) as rn
	from baseline_milestone_vw ms
	join configuration cf on cf.code='DMC' and lower(cf.value)=lower(ms.milestone_id)
	where ms.actual_date is NOT null
) dmc_actual on dmc_actual.timeline_id=xt.timeline_id and dmc_actual.wbs_id=xt.wbs_id and dmc_actual.rn=1
left join (
	select
		ms.timeline_id,
		ms.wbs_id,
		ms.plan_date as milestone_date,
		row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.plan_date desc) as rn
	from baseline_milestone_vw ms
	join configuration cf on cf.code='DMC' and lower(cf.value)=lower(ms.milestone_id)
	where ms.actual_date is null
) dmc_plan on dmc_plan.timeline_id=xt.timeline_id and dmc_plan.wbs_id=xt.wbs_id and dmc_plan.rn=1
left join (--PROMISiii-101
	select
		ms.timeline_id,
		ms.wbs_id,
		ms.milestone_date,
		row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.milestone_date desc) as rn
	from baseline_milestone_vw ms
	join configuration cf on cf.code='CSRAPP' and lower(cf.value)=lower(ms.milestone_id)
) csrapp on csrapp.timeline_id=xt.timeline_id and csrapp.wbs_id=xt.wbs_id and csrapp.rn=1
left join (--PROMISiii-101
	select
		ms.timeline_id,
		ms.wbs_id,
		ms.milestone_date,
		row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.milestone_date desc) as rn
	from baseline_milestone_vw ms
	join configuration cf on cf.code='PRCOMPL' and lower(cf.value)=lower(ms.milestone_id)
) prcompl on prcompl.timeline_id=xt.timeline_id and prcompl.wbs_id=xt.wbs_id and prcompl.rn=1
left join (--PROMISiii-101
	select
		ms.timeline_id,
		ms.wbs_id,
		ms.milestone_date,
		row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.milestone_date desc) as rn
	from baseline_milestone_vw ms
	join configuration cf on cf.code='CDBLOCK' and lower(cf.value)=lower(ms.milestone_id)
) cdblock on cdblock.timeline_id=xt.timeline_id and cdblock.wbs_id=xt.wbs_id and cdblock.rn=1
where xt.study_id is not null;