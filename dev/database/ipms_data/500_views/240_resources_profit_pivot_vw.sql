create or replace force view resources_profit_pivot_vw as 
select
	min(id) id,
	project_id,
	project_name,
	study_id,
	study_name,
	function_code,
	function_name,
	method_code,
	type_code,
	project_activity_id,
	year,
	round(sum(demand),2) demand
from (
	select
		rsc.id,
		rsc.project_id,
		prj.name as project_name,
		nvl(rsc.study_id,rsc.project_id) as study_id,
		nvl(st.name,prj.name) as study_name,
		fncd.code as function_code,
		nvl(fncd.name,'Not available') function_name,
		rsc.method_code,
		rsc.type_code,
		nvl(pan.name,rsc.project_activity_id) as project_activity_id,
		extract(year from rsc.finish_date) as year,
		rsc.demand
	from resources rsc
	join project prj on prj.id=rsc.project_id
	left join subfunction sbf on rsc.subfunction_code = sbf.code
	left join function fncd on sbf.function_code=fncd.code
	left join timeline_wbs st on (st.study_id=rsc.study_id and st.project_id=rsc.project_id and st.timeline_type_code='RAW')
	left join project_activity_name pan on (pan.id = rsc.project_activity_id)
)
group by project_id,project_name,study_id,study_name,function_code,function_name,method_code,type_code,project_activity_id,year
;