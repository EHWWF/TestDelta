drop materialized view project_regulatory_dim
;
create materialized view project_regulatory_dim as
with rcode as (
	select 
		distinct id, regulatory_code 
	from (
		select id, trim(regexp_substr(regulatory_code, '[^;]+', 1, level)) regulatory_code
		from (select id, regulatory_code from ipms_data.project where regulatory_code is not null )
		connect by instr(regulatory_code, ';', 1, level - 1) > 0
	)
)
select
	prj.id,
	prj.program_id,
	prj.code,
	prj.name,
	rcode.regulatory_code,
	rt.name as regulatory_name,
	prj.regulatory_other
from ipms_data.project prj
join rcode on (rcode.id = prj.id)
join ipms_data.regulatory_type rt on (rt.code = rcode.regulatory_code)
where prj.regulatory_code is not null
;
grant select on project_regulatory_dim to mycsd;