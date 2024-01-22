drop materialized view export_regulatory_type_vw;
--Dedicated View for Sophia along with another view: export_project_vw
create materialized view export_regulatory_type_vw as
select
	rt.code as regulatory_code,
	rt.name as regulatory_name,
	rt.is_active
from ipms_data.regulatory_type rt
;
grant select on export_regulatory_type_vw to mxcbi;
grant select on export_regulatory_type_vw to mycsd;