drop materialized view export_lc_type_vw;
create materialized view export_lc_type_vw as
select correlation_id as id,code,name,description,is_active
from project_category
where is_promis=1;
grant select on export_lc_type_vw to mxcbi;
grant select on export_lc_type_vw to mycsd;