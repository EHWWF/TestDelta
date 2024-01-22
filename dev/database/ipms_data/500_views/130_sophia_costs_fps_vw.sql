create or replace view sophia_costs_fps_vw as--TODO remove the whole VIEW when SOPHIA is ready
select
	project_id,
	study_id,
	project_activity_id,
	function_id,
	subfunction_id,
	cost_type_code,
	cost_subtype_code,
	int_ext_code,
	prob_det_code,
	year,
	month,
	scd2_key,
	current_flag,
	valid_from,
	valid_to,
	cost,
	commited_state,
	decision_start
from 
	(
	select
		to_char(f.project_id) as project_id,
		to_char(nullif(f.study_id, '0')) as study_id,
		cast(null as varchar2(60)) project_activity_id,--TODO remove the whole VIEW when SOPHIA is ready
		nvl(s.function_code,to_char(f.function_id)) as function_id,
		to_char(f.subfunction_id) as subfunction_id,
		'FCT' as cost_type_code,
		nullif(f.cost_subtype_code,'0') as cost_subtype_code,
		f.int_ext_code,
		decode(f.prob_det_code, 'PROP', 'PROB', f.prob_det_code) as prob_det_code,
		f.year,
		f.month,
		'FCT'||to_char(rownum) as scd2_key,
		1 as current_flag,
		sysdate-365 as valid_from,
		sysdate+365 as valid_to,
		f.cost_forecast as cost,
		f.commited_state,
		f.decision_start
	from fps_cost_forecast@sophia_db f
	left join subfunction s on (to_char(s.code)=to_char(f.subfunction_id))
	)
	union all
select
	project_id,
	study_id,
	project_activity_id,
	function_id,
	subfunction_id,
	cost_type_code,
	cost_subtype_code,
	int_ext_code,
	prob_det_code,
	year,
	month,
	scd2_key,
	current_flag,
	valid_from,
	valid_to,
	cost,
	commited_state,
	decision_start
from 
	(
	select
		to_char(project_id) as project_id,
		to_char(nullif(ac.study_id, '0')) as study_id,--just eliminates 0=nulls
		cast(null as varchar2(60)) project_activity_id,--TODO remove the whole VIEW when SOPHIA is ready
		nvl(s.function_code,to_char(function_id)) as function_id,
		to_char(subfunction_id) as subfunction_id,
		decode(act_run_code, 'RUN', 'RR',act_run_code) as cost_type_code,
		null as cost_subtype_code,
		int_ext_code,
		'DET' as prob_det_code,
		year,
		month,
		'RR'||to_char(rownum) as scd2_key,
		1 as current_flag,
		sysdate-365 as valid_from,
		sysdate+365 as valid_to,
		cost_actual as cost,
		null commited_state,
		null decision_start
	from fps_cost_actual@sophia_db ac
	left join subfunction s on (to_char(s.code)=to_char(ac.subfunction_id))
	)
;
create or replace view sophia_costs_fps_vw as
select
	project_id,
	study_id,
	project_activity_id,
	function_id,
	subfunction_id,
	cost_type_code,
	cost_subtype_code,
	int_ext_code,
	prob_det_code,
	year,
	month,
	scd2_key,
	current_flag,
	valid_from,
	valid_to,
	cost,
	commited_state,
	decision_start
from 
	(
	select
		to_char(f.project_id) as project_id,
		to_char(nullif(f.study_id, '0')) as study_id,
		project_activity_id,
		nvl(s.function_code,to_char(f.function_id)) as function_id,
		to_char(f.subfunction_id) as subfunction_id,
		'FCT' as cost_type_code,
		nullif(f.cost_subtype_code,'0') as cost_subtype_code,
		f.int_ext_code,
		decode(f.prob_det_code, 'PROP', 'PROB', f.prob_det_code) as prob_det_code,
		f.year,
		f.month,
		'FCT'||to_char(rownum) as scd2_key,
		1 as current_flag,
		sysdate-365 as valid_from,
		sysdate+365 as valid_to,
		f.cost_forecast as cost,
		f.commited_state,
		f.decision_start
	from fps_cost_forecast@sophia_db f
	left join subfunction s on (to_char(s.code)=to_char(f.subfunction_id))
	)
	union all
select
	project_id,
	study_id,
	project_activity_id,
	function_id,
	subfunction_id,
	cost_type_code,
	cost_subtype_code,
	int_ext_code,
	prob_det_code,
	year,
	month,
	scd2_key,
	current_flag,
	valid_from,
	valid_to,
	cost,
	commited_state,
	decision_start
from 
	(
	select
		to_char(project_id) as project_id,
		to_char(nullif(ac.study_id, '0')) as study_id,--just eliminates 0=nulls
		project_activity_id,
		nvl(s.function_code,to_char(function_id)) as function_id,
		to_char(subfunction_id) as subfunction_id,
		decode(act_run_code, 'RUN', 'RR',act_run_code) as cost_type_code,
		null as cost_subtype_code,
		int_ext_code,
		'DET' as prob_det_code,
		year,
		month,
		'RR'||to_char(rownum) as scd2_key,
		1 as current_flag,
		sysdate-365 as valid_from,
		sysdate+365 as valid_to,
		cost_actual as cost,
		null commited_state,
		null decision_start
	from fps_cost_actual@sophia_db ac
	left join subfunction s on (to_char(s.code)=to_char(ac.subfunction_id))
	)
;
drop table sophia_costs_fps_tmp;
create global temporary table sophia_costs_fps_tmp
on commit delete rows
as (select * from sophia_costs_fps_vw where 1=0);
create index sophia_costs_fps_tmp_idx1 on sophia_costs_fps_tmp(project_id);