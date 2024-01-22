create or replace view sophia_all_resources_vw as
select 
	cast(project_id as nvarchar2(20)) project_id,
	cast(study_id as nvarchar2(20)) study_id,
	cast(function_id as nvarchar2(20)) function_id,
	cast(subfunction_id as nvarchar2(20)) subfunction_id,
	cast(prob_det_code as nvarchar2(10)) prob_det_code,
	--1 as current_flag,
	--sysdate-365 as valid_from,
	--sysdate+365 as valid_to,
	year,
	month,
	cast(type_code as nvarchar2(20)) type_code,
	demand,
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
			res.year,
			res.month,
			'ACT' as type_code,
			res.time_amount as demand
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
			res.year,
			res.month,
			'PLAN' as type_code,
			res.time_amount as demand
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
		res.year,
		res.month,
		'ACT' as type_code,
		res.time_amount as demand
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
		res.year,
		res.month,
		'PLAN' as type_code,
		res.time_amount as demand
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
		to_char(decode(res.ged_study_id,'0',null,res.ged_study_id)) as study_id,
		to_char(res.function_id) as function_id,
		to_char(subfunction_id) as subfunction_id,
		'DET' as prob_det_code,
		res.year,
		res.month,
		'ACT' as type_code,
		res.time_amount as demand
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
		to_char(decode(res.ged_study_id,'0',null,res.ged_study_id)) as study_id,
		to_char(res.function_id) as function_id,
		to_char(subfunction_id) as subfunction_id,
		decode(res.prob_det_code,'PROP','PROB',res.prob_det_code) as prob_det_code,
		res.year,
		res.month,
		'PLAN' as type_code,
		res.time_amount as demand
	from ged_resources_plan@sophia_db res
	) ged2
)
;
--drop table sophia_all_resources_merge;
create table sophia_all_resources_merge as select * from sophia_all_resources_vw;
comment on table sophia_all_resources_merge is 'Can be used only in import_resources_pkg. Data is being refreshed before every data import.';
alter table sophia_all_resources_merge add (create_date date default sysdate, update_date date);
create unique index sophia_all_resources_m_ukidx on sophia_all_resources_merge (id);
create index sophia_all_resources_m_idx1 on sophia_all_resources_merge(project_id);
create index sophia_all_resources_m_idx2 on sophia_all_resources_merge(study_id);
create index sophia_all_resources_m_idx3 on sophia_all_resources_merge(function_id);
create index sophia_all_resources_m_idx4 on sophia_all_resources_merge(subfunction_id);
create index sophia_all_resources_m_idx5 on sophia_all_resources_merge(year);
create index sophia_all_resources_m_idx6 on sophia_all_resources_merge(month);
create index sophia_all_resources_m_idx7 on sophia_all_resources_merge(view_type);
drop table sophia_resources_cs_tmp;
drop table sophia_resources_ged_tmp;
drop table sophia_resources_tmp;