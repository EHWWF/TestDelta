drop materialized view cost_fct;
create materialized view cost_fct as
select x.* from (
select
    t.period_id,
    cst.project_id,
    cst.study_id,
    max(status_dim.study_status_id) study_status_id,
    nvl(sf.code,sf.function_code) as fct_id,
    max(prj.program_id) as program_id,
    cst.forecast_number,
    cst.forecast_version,
	cst.forecast_year,
	cst.forecast_month,
	cst.subtype_code,
    sum(decode(type,'BGT-DET-EXT',cost,null)) as budget_ext_det,
    sum(decode(type,'BGT-PROB-EXT',cost,null)) as budget_ext_prob,
    sum(decode(type,'BGT-DET-INT',cost,null)) as budget_int_det,
    sum(decode(type,'BGT-PROB-INT',cost,null)) as budget_int_prob,
    sum(decode(type,'FCT-DET-EXT',cost,null)) as fc_ext_det,
    sum(decode(type,'FCT-PROB-EXT',cost,null)) as fc_ext_prob,
    sum(decode(type,'FCT-DET-INT',cost,null)) as fc_int_det,
    sum(decode(type,'FCT-PROB-INT',cost,null)) as fc_int_prob,
    sum(decode(type,'ACT-DET-EXT',cost,null)) as act_ext_det,
    sum(decode(type,'ACT-PROB-EXT',cost,null)) as act_ext_prob,
    sum(decode(type,'ACT-DET-INT',cost,null)) as act_int_det,
    sum(decode(type,'ACT-PROB-INT',cost,null)) as act_int_prob,
    sum(decode(type,'RR-DET-EXT',cost,null)) as rr_ext_det,
    sum(decode(type,'RR-DET-INT',cost,null)) as rr_int_det,
    sum(decode(type,'CALF-PROB-EXT',cost,null)) as calf_ext_prob,
    sum(decode(type,'CALF-PROB-INT',cost,null)) as calf_int_prob
from (
		select 
			cst.*, 
			type_code||'-'||method_code||'-'||scope_code type 
		from ipms_data.costs cst 
		where type_code in ('FCT','BGT','ACT','RR','CALF')
	) cst
join ipms_data.subfunction sf on sf.code=cst.subfunction_code and sf.function_code is not null
join ipms_repo.period_dim t on t.year=extract(year from cst.finish_date) and t.month_of_year=extract(month from cst.finish_date)
join ipms_data.project prj on prj.id=cst.project_id
left join ipms_data.study_data_vw vstudy on vstudy.project_id = cst.project_id and vstudy.study_id = cst.study_id and vstudy.timeline_type_code = 'CUR'
left join ipms_repo.study_status_dim status_dim on (status_dim.study_status_code = decode(cst.subtype_code, 'OEC', 'OEC', 'OEI', 'OEI', nvl(cst.status_code, vstudy.status_code)))
where cost<>0
group by cst.project_id,cst.study_id,sf.function_code,sf.code,t.period_id,cst.forecast_number,cst.forecast_version,cst.forecast_year,cst.forecast_month,cst.subtype_code
) x
cross join (select 1 from dual)
;
grant select on cost_fct to mycsd;