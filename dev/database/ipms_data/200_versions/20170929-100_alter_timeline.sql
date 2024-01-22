alter table timeline_activity add root_study_wbs_id varchar2(100);
create index timeline_act_root_std_wbs_idx on timeline_activity(root_study_wbs_id);
comment on column timeline_activity.root_study_wbs_id is 'In order to link study milestones e.g. FPFV the JOIN need linking to the wbs_id node of the study, not only at first level but for all levels.';
create or replace view study_milestone_vw as
select
	tm.*,
	nvl(tm.actual_date,tm.plan_date) as milestone_date
from (
	select
		ta.project_id,
		ta.timeline_id,
		ta.timeline_type_code,
		ta.activity_id,
		ta.milestone_code,
		ta.code activity_code,
		ta.name as milestone_name,
		ta.type as milestone_type,
		ta.root_study_wbs_id as wbs_id,
		ta.study_element_id as milestone_id,
		decode(ta.type,'Start Milestone',ta.plan_start,'Finish Milestone',ta.plan_finish,null) as plan_date,
		decode(ta.type,'Start Milestone',ta.actual_start,'Finish Milestone',ta.actual_finish,null) as actual_date
	from timeline_activity ta
	where ta.type in ('Start Milestone','Finish Milestone')
	and ta.root_study_wbs_id is not null
) tm;