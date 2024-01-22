drop materialized view headcount_fct;

create materialized view headcount_fct as
select sf.code as fct_id,
	t.period_id,
	sum(decode(type,'BGT',demand,null)) as plan_headcount,
	sum(decode(type,'FCT',demand,null)) as fc_headcount
from (select hc.*, type_code type from ipms_data.headcount hc where hc.type_code in('FCT','BGT')) hc
join ipms_data.subfunction sf on sf.code=hc.subfunction_code and sf.function_code is not null
join  ipms_repo.period_dim t on t.year=extract(year from hc.finish_date) and t.month_of_year=extract(month from hc.finish_date)
where demand<>0
group by sf.code,t.period_id;

grant select on headcount_fct to mycsd;