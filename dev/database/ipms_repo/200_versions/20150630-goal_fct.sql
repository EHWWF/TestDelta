drop materialized view goal_fct;

create materialized view goal_fct as
select 
 t.period_id
,g.id
,g.project_id
,p.program_id
,g.goal goal_name
,g.type
,g.phase
,g.plan_reference
,g.plan_reference_date
,g.status status_id
,gs.name status_name
,g.target_date
,g.achieved_date
,g.revised_date
from ipms_data.goal g
join ipms_data.goal_status gs on (g.status=gs.code)
join ipms_data.project p on (g.project_id=p.id)
join ipms_repo.period_dim t on t.year=extract(year from g.target_date) and t.month_of_year=extract(month from g.target_date);