create or replace view costs_vw as
select
	project_id,study_id,function_code,subtype_code,year,month,
	max(forecast_number) as forecast_number,
	max(forecast_version) as forecast_version,
	max(forecast_month) as forecast_month,
	max(forecast_year) as forecast_year,
	sum(
		case when month<forecast_month and year=forecast_year then nvl(ext_det_act,0)
			when month>=forecast_month and year=forecast_year or year>forecast_year then nvl(ext_prob_fct,0)
		end
		) as ext_prob_fct,
	sum(
		case when month<forecast_month and year=forecast_year then nvl(ext_det_act,0)
			when month>=forecast_month and year=forecast_year or year>forecast_year  then nvl(ext_det_fct,0)
		end
		) as ext_det_fct,
	sum(ext_prob_cfct) as ext_prob_cfct,
	sum(nvl(int_prob_fct,int_prob_act)) as int_prob_fct,
	sum(nvl(int_det_fct,int_det_act)) as int_det_fct,
	sum(ext_prob_bgt) as ext_prob_bgt,
	sum(ext_det_bgt) as ext_det_bgt,
	sum(int_prob_bgt) as int_prob_bgt,
	sum(int_det_bgt) as int_det_bgt,
	sum(ext_prob_act) as ext_prob_act,
	sum(ext_det_act) as ext_det_act,
	sum(int_prob_act) as int_prob_act,
	sum(int_det_act) as int_det_act,
	sum(nvl(ext_prob_act,ext_prob_rr)) as ext_prob_rr,
	sum(nvl(ext_det_act,ext_det_rr)) as ext_det_rr,
	sum(nvl(int_prob_act,int_prob_rr)) as int_prob_rr,
	sum(nvl(int_det_act,int_det_rr)) as int_det_rr
from (
	select
		project_id,study_id,nvl(sf.function_code,cst.function_code) function_code,subtype_code,
		extract(year from finish_date) as year,
		extract(month from finish_date) as month,
		max(fy) as forecast_year,
		max(fm) as forecast_month,
		max(decode(type_code,'FCT',forecast_number,null)) as forecast_number,
		max(decode(type_code,'FCT',forecast_version,null)) as forecast_version,
		sum(decode(type,'FCT-PROB-EXT',cost,null)) as ext_prob_fct,
		sum(decode(type,'FCT-DET-EXT',cost,null)) as ext_det_fct,
		sum(decode(type,'FCT-PROB-INT',cost,null)) as int_prob_fct,
		sum(decode(type,'FCT-DET-INT',cost,null)) as int_det_fct,
		sum(decode(type,'CALF-PROB-EXT',cost,null)) as ext_prob_cfct,
		sum(decode(type,'BGT-PROB-EXT',cost,null)) as ext_prob_bgt,
		sum(decode(type,'BGT-DET-EXT',cost,null)) as ext_det_bgt,
		sum(decode(type,'BGT-PROB-INT',cost,null)) as int_prob_bgt,
		sum(decode(type,'BGT-DET-INT',cost,null)) as int_det_bgt,
		sum(decode(type,'ACT-PROB-EXT',cost,null)) as ext_prob_act,
		sum(decode(type,'ACT-DET-EXT',cost,null)) as ext_det_act,
		sum(decode(type,'ACT-PROB-INT',cost,null)) as int_prob_act,
		sum(decode(type,'ACT-DET-INT',cost,null)) as int_det_act,
		sum(decode(type,'RR-PROB-EXT',cost,null)) as ext_prob_rr,
		sum(decode(type,'RR-DET-EXT',cost,null)) as ext_det_rr,
		sum(decode(type,'RR-PROB-INT',cost,null)) as int_prob_rr,
		sum(decode(type,'RR-DET-INT',cost,null)) as int_det_rr
	from (
		select cst.*,type_code||'-'||method_code||'-'||scope_code as type
		from costs cst
		where type_code in ('BGT','ACT','RR','CALF') or type_code='FCT' and is_last_forecast=1
	) cst
	cross join (select to_number(cfg_year.value) fy, to_number(cfg_month.value) fm from configuration cfg_year
				cross join configuration cfg_month
				where cfg_year.code = 'LAST-FCT-YEAR' and cfg_month.code='LAST-FCT-MONTH')
	left join subfunction sf on sf.code=cst.subfunction_code
	where cost<>0 and (sf.function_code is not null or cst.function_code is not null)
	group by project_id,study_id,nvl(sf.function_code,cst.function_code),subtype_code,code,extract(year from finish_date),extract(month from finish_date)
) group by project_id,study_id,function_code,subtype_code,year,rollup(month);

drop table costs_tmp;

create global temporary table costs_tmp
on commit delete rows
as (select * from costs_vw where 1=0);

create index costs_tmp_idx1 on costs_tmp(project_id);
