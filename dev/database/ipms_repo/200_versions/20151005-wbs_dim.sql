drop materialized view wbs_dim;
drop table wbs_dim;

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

create table wbs_dim as select * from wbs_dim_vw;
create unique index wbs_dim_unidx on wbs_dim (id);
grant select on wbs_dim to mycsd;