drop materialized view cost_cs_fct;
drop materialized view cost_ged_fct;
drop materialized view cost_fps_fct;

create materialized view cost_fps_fct as
select x.* from (
select
    t.period_id,
    cst.project_id,
    cst.study_id,
    sf.function_code as fct_id,
    cst.subfunction_code as subfct_id,
    sum(decode(type,'FCT-EXT-DET-CMT',cost,null)) as fct_ext_det_cmt,
    sum(decode(type,'FCT-EXT-DET-UMT',cost,null)) as fct_ext_det_umt,
    sum(decode(type,'FCT-EXT-PROB-CMT',cost,null)) as fct_ext_prob_cmt,
    sum(decode(type,'FCT-EXT-PROB-UMT',cost,null)) as fct_ext_prob_umt,
    sum(decode(type,'ACT-EXT-DET',cost,null)) as act_ext_det,
    sum(decode(type,'FCT-INT-DET',cost,null)) as fct_int_det,
    sum(decode(type,'ACT-INT-DET',cost,null)) as act_int_det
from (
	select 
		cst.*, 
		type_code||'-'||scope_code||'-'||method_code||decode(committed_state,'Committed','-CMT', 'Not Committed','-UMT', '') type 
	from ipms_data.costs_fps cst 
	where type_code in ('FCT','ACT')) cst
	join ipms_repo.period_dim t on t.year=extract(year from cst.finish_date) and t.month_of_year=extract(month from cst.finish_date)
	join ipms_data.subfunction sf on sf.code=cst.subfunction_code
	where cost<>0
	group by cst.project_id,cst.study_id,sf.function_code,cst.subfunction_code,t.period_id
) x
cross join (select 1 from dual);