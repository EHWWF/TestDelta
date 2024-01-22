create or replace view ltc_costs_vw as
--with all_costs as (
-- Initial cost mapping and filtering.
-- All! ACT and FCT costs come from one source: Sophia/ProFIT
-- Treat ACT OEI costs as OEC costs.
-- Treat OEC costs as project-level costs even if study id is provided.
-- The view should be used only in one place: LTC prefil from ProFIT
select 
	cst.project_id,
	--null decision_start,
	--decode(cst.subtype_code, 'OEC', to_nchar(null), 'OEI', to_nchar(null), cst.study_id) as study_id, 
	cst.study_id,--PROMISIII-399
	nvl(sfn.function_code, cst.function_code) as function_code,
	decode(cst.subtype_code, null, to_nchar('INT'), 'OEI', to_nchar('OEC'), cst.subtype_code) as cost_type_code,
	cst.start_date,
	cst.finish_date,
	decode(cst.type_code,'ACT',cst.cost,to_number(null)) as act_cost, --ACT
	decode(cst.type_code,'ACT',cst.start_date,to_date(null)) as act_cost_start_date,
	decode(cst.type_code,'ACT',cst.finish_date,to_date(null)) as act_cost_finish_date,
	decode(cst.type_code,'FCT',cst.cost,to_number(null)) as fct_cost_fps, --FCT
	decode(cst.type_code,'FCT',cst.start_date,to_date(null)) as fct_cost_fps_start_date,
	decode(cst.type_code,'FCT',cst.finish_date,to_date(null)) as fct_cost_fps_finish_date
from costs cst
left join subfunction sfn on (sfn.code=cst.subfunction_code)
where cst.method_code='DET'
--and cst.project_id = nvl(ltc_report_pkg.get_project_id,cst.project_id)
--and (scope_code='EXT' and subtype_code in ('ECG','CRO','OEC', 'OEI') or scope_code='INT' and subtype_code is null)
and cst.scope_code||cst.subtype_code in ('EXTECG','EXTCRO','EXTOEC', 'EXTOEI','INT')
and cst.type_code in ('ACT','FCT')
and nvl(sfn.function_code, cst.function_code) is not null
--and cst.project_id in (select ltci.src_project_id from ltc_instance ltci where create_date>sysdate-1)-- PROMISIII-398, Performance LTC Generation
-- the best option to limit DataSet from very beggining. The best Index for that is project_id
-- asumption: user always creates LTC_Instance before any LTC action!
;