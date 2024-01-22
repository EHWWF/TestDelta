drop materialized view export_project_license_vw;

create materialized view export_project_license_vw as
select 
	prj.id as project_id,
	prj.code as project_code,
	prj.program_id,
	lict.code license_type_code,
	lict.name license_type_name,
	region.code as region_code,
	region.name as region_name,
	lic.expiry_date as expiry_date
from project prj
join license lic on (prj.id=lic.project_id)
join license_type lict on (lic.type_code = lict.code)
left join region on (lic.region_code = region.code)
where prj.pidt_release_date is not null
and prj.program_id<>'RBIN';

grant select on export_project_license_vw to mxcbi;
grant select on export_project_license_vw to mycsd;