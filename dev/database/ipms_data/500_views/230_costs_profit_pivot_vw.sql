create or replace force view costs_profit_pivot_vw as
select min(id) id, program_id, program_name, project_id, project_name, study_id, study_name, function_id, function_name, scope_code, method_code, type_code, year, round(sum(cost),2) cost from (
select
	cst.id||'-'||st.wbs_id id,
	prj.program_id,
	prg.name as program_name,
	cst.project_id,
	prj.name as project_name,
	nvl(cst.study_id,cst.project_id) as study_id,
	nvl(st.name,prj.name)||decode(cst.status_code,null,null,' ('||cst.status_code||')') as study_name,--Name has status code to show issues when study exists with different statuses
	nvl(cst.function_code, sf.function_code) as function_id,
	nvl(nvl(f.name,f2.name),'Function name not available/LE Placeholder')||replace(' ('||nvl(cst.function_code, sf.function_code)||')',' ()') as function_name,
	cst.scope_code,
	cst.method_code,
	cst.type_code,
	extract(year from cst.finish_date) as year,
	cost
from costs cst
join project prj on prj.id=cst.project_id
join program prg on (prj.program_id=prg.id)
left join subfunction sf on sf.code=cst.subfunction_code
left join function f on f.code=sf.function_code
left join function f2 on f2.code=cst.function_code--in case subFunction is not able to JOIN Function
left join timeline_wbs st on (st.study_id=cst.study_id and st.project_id=cst.project_id and st.timeline_type_code='RAW')
)
group by  program_id, program_name, project_id, project_name, study_id, study_name, function_id, function_name, scope_code, method_code, type_code, year;