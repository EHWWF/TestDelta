create or replace view sophia_all_resources_vw as
select 
	cast(project_id as nvarchar2(20)) project_id,
	cast(study_id as nvarchar2(20)) study_id,
	cast(function_id as nvarchar2(20)) function_id,
	cast(subfunction_id as nvarchar2(20)) subfunction_id,
	cast(prob_det_code as nvarchar2(10)) prob_det_code,
	cast(project_activity_id as varchar2(100)) project_activity_id,
	--1 as current_flag,
	--sysdate-365 as valid_from,
	--sysdate+365 as valid_to,
	year,
	month,
	cast(type_code as nvarchar2(20)) type_code,
	demand,
	cast(decision_start as varchar2(100)) decision_start,
	cast(commit_state as varchar2(100)) commit_state,
	view_type, --1="normal" resources,2=CS,3=GED
	cast(scd2_key as nvarchar2(200)) id
from (
	select 
		a1.*,
		'ACT'||to_char(row_number() over (order by project_id||study_id||function_id||subfunction_id||year||month)) as scd2_key,
		1 as view_type
	from (
		select
			to_char(res.project_id) as project_id,
			to_char(decode(res.study_id,'0',null,res.study_id)) as study_id,
			to_char(res.function_id) as function_id,
			to_char(subfunction_id) as subfunction_id,
			'DET' as prob_det_code,
			null as project_activity_id,
			res.year,
			res.month,
			'ACT' as type_code,
			res.time_amount as demand,
			null decision_start,
			null commit_state
		from resources_actual@sophia_db res
	) a1
		union all
	select 
		a2.*,
		'PLAN'||to_char(row_number() over (order by project_id||study_id||function_id||subfunction_id||year||month)) as scd2_key,
		1 as view_type
	from (
		select
			to_char(res.project_id) as project_id,
			to_char(decode(res.study_id,'0',null,res.study_id)) as study_id,
			to_char(res.function_id) as function_id,
			to_char(subfunction_id) as subfunction_id,
			decode(res.prob_det_code,'PROP','PROB',res.prob_det_code) as prob_det_code,
			to_char(res.project_activity_id) as project_activity_id,
			res.year,
			res.month,
			'PLAN' as type_code,
			res.time_amount as demand,
			null decision_start,
			null commit_state
		from resources_plan@sophia_db res
	) a2
		union all
	select 
		cs1.*,
		'CSACT'||to_char(row_number() over (order by project_id||study_id||function_id||subfunction_id||year||month)) as scd2_key,
		2 as view_type
	from (
	select
		to_char(res.project_id) as project_id,
		to_char(decode(res.study_id,'0',null,res.study_id)) as study_id,
		to_char(res.function_id) as function_id,
		to_char(subfunction_id) as subfunction_id,
		'DET' as prob_det_code,
		to_char(res.project_activity_id) as project_activity_id,
		res.year,
		res.month,
		'ACT' as type_code,
		res.time_amount as demand,
		null decision_start,
		null commit_state
	from cs_resources_actual@sophia_db res
	) cs1
		union all
	select 
		cs2.*,
		'CSPLAN'||to_char(row_number() over (order by project_id||study_id||function_id||subfunction_id||year||month)) as scd2_key,
		2 as view_type
	from (
	select
		to_char(res.project_id) as project_id,
		to_char(decode(res.study_id,'0',null,res.study_id)) as study_id,
		to_char(res.function_id) as function_id,
		to_char(subfunction_id) as subfunction_id,
		decode(res.prob_det_code,'PROP','PROB',res.prob_det_code) as prob_det_code,
		to_char(res.project_activity_id) as project_activity_id,
		res.year,
		res.month,
		'PLAN' as type_code,
		res.time_amount as demand,
		null decision_start,
		null commit_state
	from cs_resources_plan@sophia_db res
	) cs2
		union all
	select 
		ged1.*,
		'GEDACT'||to_char(row_number() over (order by project_id||study_id||function_id||subfunction_id||year||month)) as scd2_key,
		3 as view_type
	from (
	select
		to_char(res.project_id) as project_id,
		to_char(decode(res.study_id,'0',null,res.study_id)) as study_id,
		to_char(res.function_id) as function_id,
		to_char(subfunction_id) as subfunction_id,
		'DET' as prob_det_code,
		to_char(res.project_activity_id) as project_activity_id,
		res.year,
		res.month,
		'ACT' as type_code,
		res.time_amount as demand,
		decision_start,
		null commit_state
	from ged_resources_actual@sophia_db res
	) ged1
		union all
	select 
		ged2.*,
		'GEDPLAN'||to_char(row_number() over (order by project_id||study_id||function_id||subfunction_id||year||month)) as scd2_key,
		3 as view_type
	from (
	select
		to_char(res.project_id) as project_id,
		to_char(decode(res.study_id,'0',null,res.study_id)) as study_id,
		to_char(res.function_id) as function_id,
		to_char(subfunction_id) as subfunction_id,
		decode(res.prob_det_code,'PROP','PROB',res.prob_det_code) as prob_det_code,
		to_char(res.project_activity_id) as project_activity_id,
		res.year,
		res.month,
		'PLAN' as type_code,
		res.time_amount as demand,
		decision_start,
		commit_state
	from ged_resources_plan@sophia_db res
	) ged2
)
;