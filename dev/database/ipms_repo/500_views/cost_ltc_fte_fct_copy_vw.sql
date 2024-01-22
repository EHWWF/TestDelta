create or replace view cost_ltc_fte_fct_copy_vw as
select 
	ltc.ltci_id,
	ltc.estimate_id,
	ltc.period_id,
	ltc.tag_id,
	ltc.ltc_process_id,
	ltc.ltc_year,
	ltc.project_id,
	ltc.timeline_id,
	ltc.wbs_id,
	ltc.study_id,
	ltc.study_name,
	ltc.study_fpfv,
	ltc.study_lplv,
	ltc.project_phase_code,
	ltc.function_code,
	ltc.function_name,
	ltc.top_function_name,
	ltc.function_cost_rate,
	--ltc.int_scope_code,
	--ltc.ext_scope_code,
	sc.scope_code,
	ltc.is_external_fte,
	decode(ltc.min_period_id,null,null,to_date(minm.year||'-'||minm.month_of_year||'-'||1,'yyyy-mm-dd')) as cost_start_date,
	decode(ltc.max_period_id,null,null,to_date(maxm.year||'-'||maxm.month_of_year||'-'||1,'yyyy-mm-dd')) as cost_finish_date,
	ltc.project_phase_name,
	ltc.study_phase_code,
	ltc.comments,
	decode(sc.scope_code,'INT',ltc.fct_int_det,ltc.fct_ext_det) as fct_det,
	decode(sc.scope_code,'INT',ltc.ltc_int_det,ltc.ltc_ext_det) as ltc_det
from (
select
	cst.ltci_id,
	null as estimate_id, --todo
	pe.period_id,
	0 tag_id,
	0 ltc_process_id,
	pp.year ltc_year,
	cst.project_id,
	cst.timeline_id,
	cst.wbs_id,
	cst.study_id,
	nvl(st.study_name,st.name) as study_name,
	st.fpfv as study_fpfv,
	st.lplv as study_lplv,
	cst.phase as project_phase_code,
	cst.function_code,
	fun.name function_name,
	tfun.name top_function_name,
	fun.cost_rate function_cost_rate,
	decode(cst.fct_int_det||cst.ltc_int,null,null,'INT') as int_scope_code,
	decode(cst.fct_ext_oec_det||cst.fct_ext_cro_det||cst.fct_ext_ecg_det||cst.ltc_ext_oec_det||cst.ltc_ext_cro_det||cst.ltc_ext_ecg_det,null,null,'EXT') as ext_scope_code,
	decode(cst.fct_ext_oec_det, null, 0, 1) as is_external_fte,
	min(cst.period_id) min_period_id,
	max(cst.period_id) max_period_id,
	cst.phase project_phase_name,
	st.phase as study_phase_code,
	comm.comments,
	sum(nvl(cst.fct_ext_oec_det,0)+nvl(cst.fct_ext_cro_det,0)+nvl(cst.fct_ext_ecg_det,0)) as fct_ext_det,
	sum(nvl(cst.fct_int_det,0)) as fct_int_det,
	sum(nvl(cst.ltc_ext_oec_det,0)+nvl(cst.ltc_ext_cro_det,0)+nvl(cst.ltc_ext_ecg_det,0)) as ltc_ext_det,
	sum(nvl(cst.ltc_int,0)) as ltc_int_det
from cost_ltc_fct cst
join month_dim pp on (cst.period_id=pp.period_id)
join month_dim pe on (pe.year=pp.year and pe.month_of_year=1)
join ipms_data.function fun on (cst.function_code=fun.code)
join ipms_data.top_function tfun on (fun.top_function_code=tfun.code)
left join study_dim st on (cst.study_id=st.study_id and cst.project_id=st.project_id)
left join cost_ltc_comments_dim comm on (cst.ltci_id=comm.ltci_id and cst.wbs_id=comm.wbs_id and cst.function_code=comm.function_code)
where cst.fct_int_det||cst.ltc_int||cst.fct_ext_oec_det||cst.fct_ext_cro_det||cst.fct_ext_ecg_det||cst.ltc_ext_oec_det||cst.ltc_ext_cro_det||cst.ltc_ext_ecg_det is not null
group by cst.ltci_id,pe.period_id,pp.year,cst.project_id,cst.timeline_id,cst.wbs_id,cst.study_id
,nvl(st.study_name,st.name),st.fpfv,st.lplv,cst.phase,cst.function_code,fun.name,tfun.name,fun.cost_rate,decode(cst.fct_ext_oec_det, null, 0, 1)
,decode(cst.fct_int_det||cst.ltc_int,null,null,'INT')
,decode(cst.fct_ext_oec_det||cst.fct_ext_cro_det||cst.fct_ext_ecg_det||cst.ltc_ext_oec_det||cst.ltc_ext_cro_det||cst.ltc_ext_ecg_det,null,null,'EXT')
,st.phase,comm.comments
) ltc
left join month_dim minm on (minm.period_id=ltc.min_period_id)
left join month_dim maxm on (maxm.period_id=ltc.max_period_id)
cross join (select 'INT' as scope_code from dual union all select 'EXT' as scope_code from dual) sc
where (sc.scope_code=int_scope_code or sc.scope_code=ext_scope_code)
--and ltc.period_id=193 and ltc.function_code=40 and ltc.ltci_id=5550 --5643 
;