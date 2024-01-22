create or replace view costs_function_vw as
select
	cst.project_id,
	cst.study_id,
	sf.function_code,
	cst.scope_code,
	decode(cst.study_id, null, cst.subtype_code, null) as subtype_code,
	extract(year from cst.finish_date) as year
from costs cst
join subfunction sf on sf.code=cst.subfunction_code and sf.function_code is not null
where
	(cst.type_code in ('BGT','ACT','RR','CALF') or cst.type_code='FCT' and cst.is_last_forecast=1)
	and cst.cost <> 0
	and decode(cst.study_id, null, cst.subtype_code, 1) is not null
group by
	cst.project_id,
	cst.study_id,
	sf.function_code,
	cst.scope_code,
	decode(cst.study_id, null, cst.subtype_code, null),
	extract(year from cst.finish_date);

drop table costs_function_tmp;

create global temporary table costs_function_tmp
on commit delete rows
as (select * from costs_function_vw where 1=0);

create index costs_function_tmp_idx1 on costs_function_tmp(project_id);
