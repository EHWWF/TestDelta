create or replace view milestone_all_vw as
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
           ta.parent_wbs_id as wbs_id,
           ta.study_element_id as milestone_id,
           decode(ta.type,'Start Milestone',ta.plan_start,'Finish Milestone',ta.plan_finish,null) as plan_date,
           decode(ta.type,'Start Milestone',ta.actual_start,'Finish Milestone',ta.actual_finish,null) as actual_date,
           mls.wbs_category,
           mls.is_active
         from timeline_activity ta
           join milestone mls on mls.code=ta.milestone_code
         where ta.type in ('Start Milestone','Finish Milestone')
       ) tm;