drop materialized view resource_fct;

create materialized view resource_fct as
select t.period_id,
	rs.project_id,
	rs.study_id,
	rs.project_activity_id,
	nvl(sf.code,sf.function_code) as fct_id,
	max(prj.program_id) as program_id,
	sum(decode(type,'PLAN-DET',demand,null)) as plan_det,
	sum(decode(type,'ACT-DET',demand,null)) as actual_det,
	sum(decode(type,'PLAN-PROB',demand,null)) as plan_prob,
	sum(decode(type,'ACT-PROB',demand,null)) as actual_prob
from (select rs.*, type_code||'-'||method_code type from ipms_data.resources rs where rs.type_code in('ACT','PLAN')) rs
join ipms_data.subfunction sf on sf.code=rs.subfunction_code and sf.function_code is not null
join  ipms_repo.period_dim t on t.year=extract(year from rs.finish_date) and t.month_of_year=extract(month from rs.finish_date)
join ipms_data.project prj on prj.id=rs.project_id
where demand<>0
group by rs.project_id,rs.study_id,rs.project_activity_id,sf.function_code,sf.code,t.period_id;

grant select on resource_fct to mycsd;