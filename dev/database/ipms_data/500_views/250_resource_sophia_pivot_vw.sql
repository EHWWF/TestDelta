create or replace view resource_sophia_pivot_vw as
select 	
	min(id) id,
	project_id,
	project_name,
	study_id,
	study_name,
	function_code,
	function_name,
	method_code,
	method_name,
	type_code,
	type_name,
	nvl(project_activity_name,project_activity_id) as project_activity_id,
	round(sum(demand),2) as demand,
	year
from (
	select
		resources.id,
		resources.project_id,
		prj.name as project_name,
		nvl(resources.study_id,resources.project_id) as study_id,
		nvl(st.name,prj.name) as study_name,
		functiondata.code as function_code,
		nvl(functiondata.name,'Not Available') function_name,
		resources.method_code,
		calculationmethod.name as method_name,
		resources.type_code,
		resourcestype.name as type_name,
		project_activity_id,
		pan.name project_activity_name,--PROMIS-442
		resources.demand,
		extract(year from resources.finish_date) as year
	from (
		select
			id,
			project_id,
			study_id,
			function_code,
			subfunction_code,
			method_code,
			type_code,
			project_activity_id,
			finish_date,
			demand
		from resources_ged
			union all
		select
			id,
			project_id,
			study_id,
			function_code,
			subfunction_code,
			method_code,
			type_code,
			project_activity_id,
			finish_date,
			demand
		from resources_cs
	) resources
	left join subfunction subfunction on (resources.subfunction_code = subfunction.code)
	left join function functiondata on (subfunction.function_code=functiondata.code)
	left join study_data_vw st on (st.id=resources.study_id and st.project_id=resources.project_id and st.timeline_type_code='RAW')--BAY_PROMIS-510
	join project prj on (prj.id=resources.project_id)
	join resources_type resourcestype on (resources.type_code = resourcestype.code)
	join calculation_method calculationmethod on (resources.method_code = calculationmethod.code)
	left join project_activity_name pan on (pan.id = resources.project_activity_id)
)
group by project_id,project_name,study_id,study_name,function_code,function_name,method_code,method_name,type_code,type_name,nvl(project_activity_name,project_activity_id),year;