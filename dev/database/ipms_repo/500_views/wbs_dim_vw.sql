create or replace view wbs_dim_vw as
select 
	w.wbs_id as id, 
	w.name, 
	w.project_id, 
	t.sandbox_id, 
	w.timeline_id, 
	w.timeline_type_code, 
	to_number(t.reference_id) as reference_id
from ipms_data.timeline_wbs w
inner join ipms_data.timeline_vw t on t.id=w.timeline_id;