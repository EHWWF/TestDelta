drop materialized view funding_fct;

create materialized view funding_fct as
select
	f.project_id||'-'||f.year as id,
	f.project_id,
	f.year,
	f.amount
from ipms_data.funding f;

grant select on funding_fct to mycsd;