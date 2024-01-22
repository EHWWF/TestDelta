drop materialized view project_device_dim;

create materialized view project_device_dim as
select
	pd.id,
	pd.project_id,
	pd.related_project_id
from ipms_data.project_device pd;

grant select on project_device_dim to mycsd;