/*
grant select on timeline_type to ipms_repo with grant option;
grant select on study_milestone_vw to ipms_repo with grant option;
grant select on timeline_wbs to ipms_repo with grant option;
grant select on PROJECT_GOAL_FACTOR to ipms_repo with grant option;
grant select on PROJECT to ipms_repo with grant option;
*/
create or replace view study_milestone_fct_vw as
select
	distinct
	upper(
		vmilestone.timeline_id 
		||'-'||
		--nvl(vmilestone.milestone_id,nvl(milestone.code, vmilestone.milestone_code))
		nvl(vmilestone.milestone_id,vmilestone.milestone_code)
		||'-'||
		vmilestone.activity_code||'-'||wbs.code
	) as id,
	vmilestone.project_id,
	vmilestone.timeline_id,
	vmilestone.timeline_type_code,
	timelinetype.name as timeline_type,
	--nvl(milestone.code, vmilestone.milestone_code) as milestone_code,
	--nvl(milestone.name, vmilestone.milestone_name) as milestone_name,
	--milestone.type_code as milestone_type_code,
	--mtype.name as milestone_type,
	vmilestone.activity_id,
	vmilestone.plan_date,
	vmilestone.actual_date,
	nvl(vmilestone.actual_date, vmilestone.plan_date) as milestone_date,
	pgf.goal_factor,
	vmilestone.milestone_id as study_element_id,
	wbs.study_id,
	wbs.study_phase,
	vmilestone.wbs_id,
	wbs.code as wbs_code,
	wbs.name as wbs_name
from ipms_data.study_milestone_vw vmilestone
left join ipms_data.timeline_type timelinetype on (timelinetype.code = vmilestone.timeline_type_code)
left join ipms_data.timeline_wbs wbs on (vmilestone.wbs_id=wbs.wbs_id and wbs.project_id=vmilestone.project_id)
--left join (select distinct p.name phase_name, pm.milestone_code from ipms_data.phase p join ipms_data.phase_milestone pm on (p.code=pm.phase_code)) phase on (phase.phase_name=wbs.study_phase)
--left join ipms_data.milestone milestone on milestone.code = nvl(vmilestone.milestone_code, phase.milestone_code)
--left join ipms_data.milestone_type mtype on mtype.code = milestone.type_code
--left join ipms_data.project_goal_factor pgf on (vmilestone.project_id = pgf.project_id and pgf.milestone_code=nvl(milestone.code, vmilestone.milestone_code))
left join ipms_data.project_goal_factor pgf on (vmilestone.project_id = pgf.project_id and pgf.milestone_code=vmilestone.milestone_code)
where wbs.study_id is not null
--and (milestone.is_active=1 or milestone.code in ('TCC','cD6','cD7'))
	union all
select
	prj.id||'-'||prj.area_code as id,
	prj.id as project_id,
	null as timeline_id,
	null as timeline_type_code,
	null as timeline_type,
	--prj.area_code as milestone_code,
	--prj.area_code as milestone_name,
	--to_nchar('DEC') as milestone_type_code,
	--to_nchar('Decision') as milestone_type,
	null as activity_id,
	null as plan_date,
	prj.d1_decision_date as actual_date,
	prj.d1_decision_date as milestone_date,
	pgfd1.goal_factor,
	null as study_element_id,
	null as study_id,
	null as study_phase,
	null as wbs_id,
	null as wbs_code,
	null as wbs_name
from ipms_data.project prj
left join ipms_data.project_goal_factor pgfd1 on (prj.id = pgfd1.project_id) and pgfd1.milestone_code='D1' and prj.area_code='D1'
where prj.d1_decision_date is not null
and prj.area_code='D1'
	union all
select
	prj.id||'-D1-HTS' as id,
	prj.id as project_id,
	null as timeline_id,
	null as timeline_type_code,
	null as timeline_type,
	--to_nchar('D1-HTS') as milestone_code,
	--to_nchar('D1-HTS') as milestone_name,
	--null as milestone_type_code,
	--null as milestone_type,
	null as activity_id,
	null as plan_date,
	prj.start_hts_date as actual_date,
	prj.start_hts_date as milestone_date,
	null as goal_factor,
	null as study_element_id,
	null as study_id,
	null as study_phase,
	null as wbs_id,
	null as wbs_code,
	null as wbs_name
from ipms_data.project prj
where prj.start_hts_date is not null
and prj.area_code='D1'
	union all
select
	prj.id||'-D1-LSA' as id,
	prj.id as project_id,
	null as timeline_id,
	null as timeline_type_code,
	null as timeline_type,
	--to_nchar('D1-LSA') as milestone_code,
	--to_nchar('D1-LSA') as milestone_name,
	--null as milestone_type_code,
	--null as milestone_type,
	null as activity_id,
	null as plan_date,
	prj.LSA_date as actual_date,
	prj.LSA_date as milestone_date,
	null as goal_factor,
	null as study_element_id,
	null as study_id,
	null as study_phase,
	null as wbs_id,
	null as wbs_code,
	null as wbs_name
from ipms_data.project prj
where prj.lsa_date is not null
and prj.area_code='D1'
;