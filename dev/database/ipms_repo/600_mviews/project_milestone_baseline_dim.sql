drop materialized view project_milestone_baseline_dim;

create materialized view project_milestone_baseline_dim as
select --the very TOP Select is just for formating
	cast(id as nvarchar2(200)) id,
	cast(project_id as nvarchar2(20)) project_id,
	cast(timeline_id as nvarchar2(20)) timeline_id,
	cast(timeline_type_code as nvarchar2(10)) timeline_type_code,
	cast(timeline_type as nvarchar2(100)) timeline_type,
	cast(milestone_code as nvarchar2(100)) milestone_code,
	cast(milestone_name as nvarchar2(500)) milestone_name,
	cast(milestone_type_code as nvarchar2(10)) milestone_type_code,
	cast(milestone_type as nvarchar2(100)) milestone_type,
	cast(activity_id as varchar2(100)) activity_id,
	plan_date,
	actual_date,
	milestone_date,
	goal_factor
from (
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
	where vmilestone.timeline_type_code = 'APR'--we take here APR because in the main one DIM: PROJECT_MILESTONE_DIM we have analogical filter for CUR
	and vmilestone.milestone_code is not null
	and (vmilestone.is_active=1 or vmilestone.milestone_code in ('TCC','cD6','cD7'))
		union all
	select 
		id,
		project_id,
		timeline_id,
		timeline_type_code,
		timeline_type,
		milestone_code,
		milestone_name,
		milestone_type_code,
		milestone_type,
		max(activity_id) as activity_id,--there some cases for BSL in P^, probably by mistake that have duplicates, the only diff is activity_id
		plan_date,
		actual_date,
		milestone_date,
		goal_factor
	from (
		select
			upper(
				to_nchar(vmilestone.project_id||'-'||vmilestone.baseline_id||'-BSL') 
				||'-'||
				nvl(vmilestone.milestone_id,nvl(milestone.code, vmilestone.milestone_code))
				||'-'||
				decode(vmilestone.milestone_id,null,null,nvl(milestone.code, vmilestone.milestone_code)||'-')
				||vmilestone.activity_code
				||'-'||vmilestone.activity_id
			) as id,
			vmilestone.project_id,
			to_nchar(vmilestone.project_id||'-'||vmilestone.baseline_id||'-BSL') timeline_id,
			to_nchar('BSL') as timeline_type_code,
			to_nchar('Baseline') as timeline_type,
			nvl(milestone.code, vmilestone.milestone_code) as milestone_code,
			nvl(milestone.name, vmilestone.milestone_name) as milestone_name,
			milestone.type_code as milestone_type_code,
			mtype.name as milestone_type,
			vmilestone.activity_id,
			vmilestone.plan_date,
			vmilestone.actual_date,
			nvl(vmilestone.actual_date, vmilestone.plan_date) as milestone_date,
			pgf.goal_factor
		from ipms_data.baseline_milestone_vw vmilestone
		--left join ipms_data.timeline_type timelinetype on timelinetype.code = vmilestone.timeline_type_code --hardcoded name Baseline, because Baseline type does not exists in this table
		left join ipms_data.milestone milestone on milestone.code = vmilestone.milestone_code
		left join ipms_data.milestone_type mtype on mtype.code = milestone.type_code
		left join ipms_data.project_goal_factor pgf on (vmilestone.project_id = pgf.project_id and pgf.milestone_code=nvl(milestone.code, vmilestone.milestone_code))
		where vmilestone.milestone_code is not null
		) group by 	
				id,
				project_id,
				timeline_id,
				timeline_type_code,
				timeline_type,
				milestone_code,
				milestone_name,
				milestone_type_code,
				milestone_type,
				plan_date,
				actual_date,
				milestone_date,
				goal_factor
union all --plus ADD all rows from DIM: project_milestone_dim_vw
	select 
		id,
		project_id,
		timeline_id,
		timeline_type_code,
		timeline_type,
		milestone_code,
		milestone_name,
		milestone_type_code,
		milestone_type,
		activity_id,
		plan_date,
		actual_date,
		milestone_date,
		goal_factor
	from project_milestone_dim_vw
)
;

grant select on project_milestone_baseline_dim to mycsd;