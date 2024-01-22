drop materialized view license_dim;

create materialized view license_dim as
select
	l.id,
	l.project_id,
	l.region_code,
	region.name as region,
	l.type_code,
	ltype.name as type,
	l.expiry_date
from ipms_data.license l
left join ipms_data.license_type ltype on ltype.code = l.type_code
left join ipms_data.region region on region.code = l.region_code;

grant select on license_dim to mycsd;