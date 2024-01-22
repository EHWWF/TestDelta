create or replace view sophia_headcount_vw as
select
	to_char(function_id) as function_id,
	to_char(subfunction_id) as subfunction_id,
	'FCT' as type_code,
	year,
	'FCT'||rownum as scd2_key,
	1 as current_flag,
	sysdate-365 as valid_from,
	sysdate+365 as valid_to,
	forecast_creation_year forecast_year,
	forecast_creation_month forecast_month,
	headcount_forecast as demand
from headcount_forecast@sophia_db
union all
select
	to_char(function_id) as function_id,
	to_char(subfunction_id) as subfunction_id,
	'BGT' as type_code,
	year,
	'BGT'||rownum as scd2_key,
	1 as current_flag,
	sysdate-365 as valid_from,
	sysdate+365 as valid_to,
	forecast_creation_year forecast_year,
	forecast_creation_month forecast_month,
	headcount_budget as demand
from headcount_budget@sophia_db;

drop table sophia_headcount_tmp;

create global temporary table sophia_headcount_tmp
on commit delete rows
as (select * from sophia_headcount_vw where 1=0);

create index sophia_headcount_tmp_idx1 on sophia_headcount_tmp(subfunction_id);