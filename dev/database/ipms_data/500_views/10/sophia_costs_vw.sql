create or replace view sophia_costs_vw as
select
	to_char(project_id) as project_id,
	to_char(decode(study_id,'0',null,study_id)) as study_id,
	to_char(function_id) as function_id,
	to_char(subfunction_id) as subfunction_id,
	'FCT' as cost_type_code,
	decode(cost_subtype_code,'0',null,cost_subtype_code) as cost_subtype_code,
	int_ext_code,
	decode(prob_det_code,'PROP','PROB',prob_det_code) as prob_det_code,
	year,
	month,
	'FCT'||to_char(rownum) as scd2_key,
	1 as current_flag,
	sysdate-365 as valid_from,
	sysdate+365 as valid_to,
	forecast_number,
	forecast_version,
	cost_forecast as cost,
	forecast_creation_year forecast_year,
	forecast_creation_month forecast_month
from cost_forecast@sophia_db
union all
select
	to_char(project_id),
	to_char(decode(study_id,'0',null,study_id)),
	to_char(function_id),
	to_char(subfunction_id) as subfunction_id,
	'BGT',
	decode(cost_subtype_code,'0',null,cost_subtype_code),
	int_ext_code,
	decode(prob_det_code,'PROP','PROB',prob_det_code),
	year,
	month,
	'BGT'||to_char(rownum) as scd2_key,
	1 as current_flag,
	sysdate-365 as valid_from,
	sysdate+365 as valid_to,
	forecast_number,
	forecast_version,
	cost_budget as cost,
	null,
	null
from cost_budget@sophia_db
union all
select
	to_char(project_id),
	to_char(decode(study_id,'0',null,study_id)),
	to_char(function_id),
	to_char(subfunction_id) as subfunction_id,
	decode(act_run_code,'RUN','RR',act_run_code),
	decode(cost_subtype_code,'0',null,cost_subtype_code) as cost_subtype_code,
	int_ext_code,
	'DET',
	year,
	month,
	'RR'||to_char(rownum) as scd2_key,
	1 as current_flag,
	sysdate-365 as valid_from,
	sysdate+365 as valid_to,
	null,
	null,
	cost_actual as cost,
	null,
	null
from cost_actual@sophia_db;

drop table sophia_costs_tmp;

create global temporary table sophia_costs_tmp
on commit delete rows
as (select * from sophia_costs_vw where 1=0);

create index sophia_costs_tmp_idx1 on sophia_costs_tmp(project_id);