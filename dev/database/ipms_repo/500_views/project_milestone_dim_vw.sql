create or replace view project_milestone_dim_vw as
select
	upper(
		vmilestone.timeline_id 
		||'-'||
		nvl(vmilestone.milestone_id,nvl(milestone.code, vmilestone.milestone_code))
		||'-'||
		decode(vmilestone.milestone_id,null,null,nvl(milestone.code, vmilestone.milestone_code)||'-')
		||vmilestone.activity_code
	) as id,
	vmilestone.project_id,
	vmilestone.timeline_id,
	vmilestone.timeline_type_code,
	timelinetype.name as timeline_type,
	nvl(milestone.code, vmilestone.milestone_code) as milestone_code,
	nvl(milestone.name, vmilestone.milestone_name) as milestone_name,
	milestone.type_code as milestone_type_code,
	mtype.name as milestone_type,
	vmilestone.activity_id,
	vmilestone.plan_date,
	vmilestone.actual_date,
	nvl(vmilestone.actual_date, vmilestone.plan_date) as milestone_date,
	pgf.goal_factor
from ipms_data.milestone_all_vw vmilestone
left join ipms_data.timeline_type timelinetype on timelinetype.code = vmilestone.timeline_type_code
left join ipms_data.milestone milestone on milestone.code = vmilestone.milestone_code
left join ipms_data.milestone_type mtype on mtype.code = milestone.type_code
left join ipms_data.project_goal_factor pgf on (vmilestone.project_id = pgf.project_id and pgf.milestone_code=nvl(milestone.code, vmilestone.milestone_code))
where vmilestone.timeline_type_code = 'CUR'
and vmilestone.milestone_code is not null
and (vmilestone.is_active=1 or vmilestone.milestone_code in ('TCC','cD6','cD7'))
	union all
select
	prj.id||'-'||prj.area_code as id,
	prj.id as project_id,
	null as timeline_id,
	null as timeline_type_code,
	null as timeline_type,
	prj.area_code as milestone_code,
	prj.area_code as milestone_name,
	to_nchar('DEC') as milestone_type_code,
	to_nchar('Decision') as milestone_type,
	null as activity_id,
	null as plan_date,
	prj.d1_decision_date as actual_date,
	prj.d1_decision_date as milestone_date,
	pgfd1.goal_factor
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
	to_nchar('D1-HTS') as milestone_code,
	to_nchar('D1-HTS') as milestone_name,
	null as milestone_type_code,
	null as milestone_type,
	null as activity_id,
	null as plan_date,
	prj.start_hts_date as actual_date,
	prj.start_hts_date as milestone_date,
	null as goal_factor
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
	to_nchar('D1-LSA') as milestone_code,
	to_nchar('D1-LSA') as milestone_name,
	null as milestone_type_code,
	null as milestone_type,
	null as activity_id,
	null as plan_date,
	prj.LSA_date as actual_date,
	prj.LSA_date as milestone_date,
	null as goal_factor
from ipms_data.project prj
where prj.LSA_date is not null
and prj.area_code='D1'
	union all
select
	prj.id||'-D2' as id,
	prj.id as project_id,
	null as timeline_id,
	null as timeline_type_code,
	null as timeline_type,
	to_nchar('D2') as milestone_code,
	to_nchar('Start Lead Optimization') as milestone_name,
	to_nchar('DEC') as milestone_type_code,
	to_nchar('Decision') as milestone_type,
	null as activity_id,
	prj.d2_planned_date as plan_date,
	prj.d2_achieved_date as actual_date,
	nvl(prj.d2_achieved_date,prj.d2_planned_date) as milestone_date,
	null as goal_factor
from ipms_data.project prj
where prj.area_code='D1'
and (prj.d2_achieved_date is not null or prj.d2_planned_date is not null)
;