drop materialized view export_subgroup_vw;
create materialized view export_subgroup_vw as
select correlation_id as id,code,name,description,is_active
from project_category
where is_promis=0;
grant select on export_subgroup_vw to mxcbi;
grant select on export_subgroup_vw to mycsd;