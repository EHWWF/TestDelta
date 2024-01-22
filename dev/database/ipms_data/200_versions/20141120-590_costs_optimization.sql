create or replace view sophia_costs2_vw as
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
	'FCT'||to_char(row_number() over (order by project_id||study_id||subfunction_id||cost_subtype_code||int_ext_code||prob_det_code||year||month||forecast_number||forecast_version||forecast_creation_year||forecast_creation_month||cost_forecast)) as merge_key,
	1 as current_flag,
	forecast_number,
	forecast_version,
	cost_forecast as cost,
	forecast_creation_year forecast_year,
	forecast_creation_month forecast_month,
	to_date('01.01.01','DD.MM.YY') create_date,
	to_date('01.01.01','DD.MM.YY') update_date
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
	'BGT'||to_char(row_number() over (order by project_id||study_id||subfunction_id||cost_subtype_code||int_ext_code||prob_det_code||year||month||forecast_number||forecast_version)) as merge_key,
	1 as current_flag,
	forecast_number,
	forecast_version,
	cost_budget as cost,
	null,
	null,
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
	'RR'||to_char(row_number() over (order by project_id||study_id||subfunction_id||cost_subtype_code||int_ext_code||year||month)) as merge_key,
	1 as current_flag,
	null,
	null,
	cost_actual as cost,
	null,
	null,
	null,
	null	
from cost_actual@sophia_db;

create table sophia_costs_vw_merge as select * from sophia_costs2_vw;
comment on table sophia_costs_vw_merge is 'Can be used only in IMPORT_PKG and only for performance issues. Data is being refreshed before every data import.';
create unique index sophia_costs_vw_merge_ui on sophia_costs_vw_merge (merge_key);
create index sophia_costs_vw_merge_prj_i on sophia_costs_vw_merge (project_id);