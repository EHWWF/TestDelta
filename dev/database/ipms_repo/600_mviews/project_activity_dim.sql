drop materialized view project_activity_dim
;
create materialized view project_activity_dim as
select
	pa.id,
	pa.project_id,
	pa.project_activity_id,
	pa.project_activity_name,
	pa.study_id,
	pa.p6_activity_id,
	pa.plan_start_date,
	pa.plan_finish_date,
	pa.act_start_date,
	pa.act_finish_date,
	pa.wbs_category
from ipms_data.project_activity pa
join ipms_repo.period_dim t on t.year=extract(year from nvl(pa.act_finish_date,pa.plan_finish_date)) and t.month_of_year=extract(month from nvl(pa.act_finish_date,pa.plan_finish_date))
;
grant select on project_activity_dim to mycsd;