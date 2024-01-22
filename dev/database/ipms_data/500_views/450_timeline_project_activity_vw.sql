create or replace view timeline_project_activity_vw as
select
  act.project_id||':'||act.study_element_id||':'||act.study_id||':'||wcat.category_name artificial_id,
  act.timeline_id,
  act.project_id,
  act.timeline_type_code,
  act.activity_id,
  act.parent_wbs_id,
  wbs.name wbs_name,
  act.study_element_id,
  act.study_id,
  act.name,
  act.plan_start,
  act.plan_finish,
  act.actual_start,
  act.actual_finish,
  wcat.category_name wbs_category,
  wcat.category_object_id,
  act.create_user
from timeline_activity act
  join timeline_wbs wbs on wbs.wbs_id = act.parent_wbs_id and wbs.name like 'Project Activities%'
  left join timeline_wbs_category wcat on wcat.timeline_id = wbs.timeline_id and wcat.wbs_id = wbs.wbs_id
where act.study_element_id is not null;