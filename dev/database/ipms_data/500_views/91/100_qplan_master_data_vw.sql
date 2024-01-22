create or replace view qplan_master_data_vw as
select
	prj.id project_id,
	pac.element_code,
	pact.name element_name,
	qobject.var2 element_show_value,
	qobject.var3 element_xml_send_value,
	qobject.var4 element_is_blocking,
	pac.is_mandatory
from project_area_qplan_config pac
join project prj on pac.area_code = prj.area_code
join qplan_element_type pact on (pact.code = pac.element_code and pact.milestone_code is null and pact.is_active=1)
join table(qplan_pkg.get_element_value(prj.id, pac.element_code, pac.is_mandatory, pact.name)) qobject on (qobject.var1=prj.id)
order by prj.id, pact.order_by;