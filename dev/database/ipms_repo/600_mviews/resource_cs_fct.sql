drop materialized view resource_cs_fct;

create materialized view resource_cs_fct as
select x.* from (
select
    t.period_id,
    rsc.project_id,
    rsc.study_id,
    rsc.project_activity_id,
    sf.function_code as fct_id,
    rsc.subfunction_code as subfct_id,
    sum(decode(type,'PLAN-DET',demand,null)) as plan_det,
    sum(decode(type,'ACT-DET',demand,null)) as act_det
from (select rsc.*, type_code||'-'||method_code type from ipms_data.resources_cs rsc where type_code in ('ACT','PLAN')) rsc
join ipms_repo.period_dim t on t.year=extract(year from rsc.finish_date) and t.month_of_year=extract(month from rsc.finish_date)
join ipms_data.subfunction sf on sf.code=rsc.subfunction_code
where demand>0
group by rsc.project_id,rsc.study_id,rsc.project_activity_id,sf.function_code,rsc.subfunction_code,t.period_id
) x
cross join (select 1 from dual);

grant select on resource_cs_fct to mycsd;