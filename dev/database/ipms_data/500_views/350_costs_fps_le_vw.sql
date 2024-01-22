create or replace view costs_fps_le_vw as
------------------------------------
----------The View is needed for LE excel -> for including FPS values
----------EST=Forecast
------------------------------------
select
	project_id,
	study_id,
	function_code,
	subtype_code,
	year,
	month,
	forecast_number,
	forecast_version,
	forecast_month,
	forecast_year,
	ext_prob_fct,
	ext_det_fct,
	ext_prob_cfct,
	int_prob_fct,
	int_det_fct,
	ext_prob_bgt,
	ext_det_bgt,
	int_prob_bgt,
	int_det_bgt,
	ext_prob_act,
	ext_det_act,
	int_prob_act,
	int_det_act,
	ext_prob_rr,
	ext_det_rr,
	int_prob_rr,
	int_det_rr,
	to_number(null) fps_est_comm_inc_act,
	to_number(null) fps_est_uncomm,
	to_number(null) fps_est_total_inc_unspec_y1,
	to_number(null) fps_est_comm,
	to_number(null) fps_est_total_inc_unspec_y2
from costs_vw 
where subtype_code||decode(study_id,null,'#',null) != 'OEI'
	union all
select
	project_id,
	study_id,
	function_code,
	subtype_code,
	year,
	month,
	to_number(null) forecast_number,
	to_number(null) forecast_version,
	to_number(null) forecast_month,
	to_number(null) forecast_year,
	to_number(null) ext_prob_fct,
	to_number(null) ext_det_fct,
	to_number(null) ext_prob_cfct,
	to_number(null) int_prob_fct,
	to_number(null) int_det_fct,
	to_number(null) ext_prob_bgt,
	to_number(null) ext_det_bgt,
	to_number(null) int_prob_bgt,
	to_number(null) int_det_bgt,
	to_number(null) ext_prob_act,
	to_number(null) ext_det_act,
	to_number(null) int_prob_act,
	to_number(null) int_det_act,
	to_number(null) ext_prob_rr,
	to_number(null) ext_det_rr,
	to_number(null) int_prob_rr,
	to_number(null) int_det_rr,
	act_det_ext_all+nvl(fct_det_ext_com,0) as fps_est_comm_inc_act,--1
	fct_det_ext_noncom as fps_est_uncomm,--2+5
	act_det_ext_all+nvl(fct_det_ext_com,0)+nvl(fct_det_ext_noncom,0)+nvl(fct_det_ext_uns,0) as fps_est_total_inc_unspec_y1,--3
	fct_det_ext_com as fps_est_comm,--4
	nvl(fct_det_ext_com,0)+nvl(fct_det_ext_noncom,0)+nvl(fct_det_ext_uns,0) as fps_est_total_inc_unspec_y2 --6
from (
	select
		project_id,
		study_id,
		function_code,
		subtype_code,
		year,
		month,
		--act_det_ext_com,
		--act_det_ext_noncom,
		--act_det_ext_uns,
		fct_det_ext_com,
		fct_det_ext_noncom,
		fct_det_ext_uns,
		--nvl(act_det_ext_com,0)+nvl(act_det_ext_noncom,0)+nvl(act_det_ext_uns,0) as act_det_ext_all
		nvl(act_det_ext_com,0) as act_det_ext_all
	from (
		select
			project_id,
			study_id,
			function_code,
			subtype_code,
			year,
			month,
			sum(act_det_ext_com) as act_det_ext_com,
			sum(act_det_ext_noncom) as act_det_ext_noncom,
			sum(act_det_ext_uns) as act_det_ext_uns,
			sum(fct_det_ext_com) as fct_det_ext_com,
			sum(fct_det_ext_noncom) as fct_det_ext_noncom,
			sum(fct_det_ext_uns) as fct_det_ext_uns
		from (
			select
				project_id,
				study_id,
				nvl(sf.function_code,cst.function_code) function_code,
				subtype_code,
				extract(year from finish_date) as year,
				extract(month from finish_date) as month,
				sum(decode(type,'ACT-DET-EXT-C',cost,null)) as act_det_ext_com,
				sum(decode(type,'ACT-DET-EXT-N',cost,null)) as act_det_ext_noncom,
				sum(decode(type,'ACT-DET-EXT-U',cost,null)) as act_det_ext_uns,
				sum(decode(type,'FCT-DET-EXT-C',cost,null)) as fct_det_ext_com,
				sum(decode(type,'FCT-DET-EXT-N',cost,null)) as fct_det_ext_noncom,
				sum(decode(type,'FCT-DET-EXT-U',cost,null)) as fct_det_ext_uns
			from (
				select
					cstf.cost,
					cstf.function_code,
					cstf.subfunction_code,
					cstf.finish_date,
					cstf.subtype_code,
					cstf.study_id,
					cstf.project_id,
					cstf.type_code||'-'||cstf.method_code||'-'||cstf.scope_code||'-'||upper(nvl(substr(cstf.committed_state,1,1),'U')) as type
				--C=committed
				--N=not committed
				--U=unspecified=NULL=missing
				from costs_fps cstf
				where cstf.scope_code='EXT'
				and cstf.method_code='DET'
				and cstf.cost<>0
				and cstf.type_code||'-'||cstf.method_code||'-'||cstf.scope_code||'-'||upper(nvl(substr(cstf.committed_state,1,1),'U')) <>'ACT-DET-EXT-C'--Must be taken from ProFIT=COSTS table
					union all
				select
					cstn.cost,
					cstn.function_code,
					cstn.subfunction_code,
					cstn.finish_date,
					cstn.subtype_code,
					cstn.study_id,
					cstn.project_id,
					cstn.type_code||'-'||cstn.method_code||'-'||cstn.scope_code||'-C' as type
				--C=it is committed by default
				from costs cstn
				where cstn.scope_code='EXT'
				and cstn.method_code='DET'
				and cstn.cost<>0
				and cstn.type_code ='ACT'--type
			) cst
			left join subfunction sf on (sf.code=cst.subfunction_code)
			where cost<>0
			and sf.function_code||cst.function_code is not null
			group by project_id,study_id,nvl(sf.function_code,cst.function_code),subtype_code,code,extract(year from finish_date),extract(month from finish_date)
	) group by project_id,study_id,function_code,subtype_code,year,rollup(month)
	)
) 
where subtype_code||decode(study_id,null,'#',null) != 'OEI'
;


drop table costs_fps_le_tmp;

create global temporary table costs_fps_le_tmp
on commit delete rows
as (select * from costs_fps_le_vw where 1=0);

create index costs_fps_le_tmp_idx1 on costs_fps_le_tmp(project_id);