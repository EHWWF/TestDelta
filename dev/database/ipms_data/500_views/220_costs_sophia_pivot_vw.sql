create or replace force view costs_sophia_pivot_vw as
select
	min(id) id,
	program_id,
	program_name,
	project_id,
	project_name,
	study_id,
	study_name,
	nvl(project_activity_name,project_activity_id) as project_activity_id,
	function_code,
	function_name,
	scope_code,
	method_code,
	decode(type_code,'FCT','EST',type_code) type_code,
	subtype_code,
	year,
	round(sum(cost),2) cost
from (
	select
		costs.id,
		prj.program_id,
		prg.name as program_name,
		costs.project_id,
		prj.name as project_name,
		nvl(decode(st.name,null,null,costs.study_id),costs.project_id) as study_id,--PROMIS-741, in case study name is missing then group all costs with project ID, same action happens at study_name
		nvl(st.name,decode(costs.study_id,null,prj.name,'Studies missing in Primavera')) as study_name,--BAY_PROMIS-13
		costs.project_activity_id,
		pan.name project_activity_name,--PROMIS-442
		costs.function_code,
		nvl(fnc.name, 'Not available')||decode(nvl(costs.function_code,sf.function_code),null,null,' ('||nvl(costs.function_code,sf.function_code)||')') as function_name,
		costs.scope_code,
		costs.method_code,
		costs.type_code,
		costs.cost cost,
		null subtype_code,--PROMIS-722, the collumn is not needed at all and GROUP BY leads to errors
		extract(year from costs.finish_date) as year
	from costs_fps costs
	join costs_type coststype on (costs.type_code = coststype.code)
	join costs_scope costsscope on (costs.scope_code = costsscope.code)
	join calculation_method calculationmethod on (costs.method_code = calculationmethod.code)
	join project prj on (prj.id=costs.project_id)
	join program prg on (prj.program_id=prg.id)
	left join costs_subtype costssubtype on (costs.subtype_code = costssubtype.code)
	left join subfunction sf on (costs.subfunction_code = sf.code)
	left join function fnc on (sf.function_code = fnc.code)
	left join timeline_wbs st on (st.study_id=costs.study_id and st.project_id=costs.project_id and st.timeline_type_code='RAW')
	left join project_activity_name pan on (pan.id = costs.project_activity_id)
)
group by
	program_id,
	program_name,
	project_id,
	project_name,
	study_id,
	study_name,
	nvl(project_activity_name,project_activity_id),
	function_code,
	function_name,
	scope_code,
	method_code,
	decode(type_code,'FCT','EST',type_code),
	subtype_code,
	year
;