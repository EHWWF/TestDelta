create or replace view sophia_study_fte_vw as
select
  project_id,
  study_id,
  function_id,
  year,
  month,
  sum(fte) fte
from fps_fte_forecast@sophia_db
where study_id <> 0
      and study_id <> -1
group by project_id, study_id, function_id, year, month;