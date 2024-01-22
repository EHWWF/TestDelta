drop materialized view cost_fps_fct;

create materialized view cost_fps_fct as
select x.* from (
	select 
		t.period_id,
		cst.project_id,
		substr(to_nchar(decode(sf.function_code,'45',null,cst.study_id)),1,100) as study_id,--PROMIS-553
		substr(decode(sf.function_code,'45',cst.study_id,null),1,100) as ged_study_id,--PROMIS-553
		cst.project_activity_id,
		sf.function_code as fct_id,
		cst.subfunction_code as subfct_id,
		decode(scope_code,'EXT',decode(lower(committed_state),'committed','committed','not committed','not committed',null),null) as committed_state,
		sum(decode(type,'FCT-EXT-DET',cost,null)) as fct_ext_det,--new:all deterministic costs
		sum(decode(type,'FCT-EXT-PROB',cost,null)) as fct_ext_prob,--new:all probabilistic costs
		sum(decode(type,'ACT-EXT-DET',cost,null)) as act_ext_det,
		sum(decode(type,'FCT-INT-DET',cost,null)) as fct_int_det,
		sum(decode(type,'ACT-INT-DET',cost,null)) as act_int_det
	from (
		select 
			cst.*, 
			type_code||'-'||scope_code||'-'||method_code type 
		from ipms_data.costs_fps cst 
		where type_code in ('FCT','ACT')
		) cst
		join ipms_repo.period_dim t on (t.year=extract(year from cst.finish_date) and t.month_of_year=extract(month from cst.finish_date))
		join ipms_data.subfunction sf on (sf.code=cst.subfunction_code)
		where cost<>0
		group by
			cst.project_id,
			cst.study_id,
			cst.project_activity_id,
			sf.function_code,
			cst.subfunction_code,
			t.period_id,
			decode(scope_code,'EXT',decode(lower(committed_state),'committed','committed','not committed','not committed',null),null)
) x
cross join (select 1 from dual);

grant select on cost_fps_fct to mycsd;