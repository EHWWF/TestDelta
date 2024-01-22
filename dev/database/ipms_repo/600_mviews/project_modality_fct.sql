drop materialized view project_modality_fct;
create materialized view project_modality_fct as
with proje as 
(select
	prj.id,
	prj.code,
	trim(regexp_substr(prj.details_modality, '[^;]+', 1, lines.column_value)) pm_code
from ipms_data.project prj,
	TABLE (CAST (MULTISET(
		SELECT LEVEL FROM dual CONNECT BY instr(prj.details_modality, ';', 1, LEVEL - 1) > 0
						) AS sys.odciNumberList ) 
			) lines
   where prj.details_modality is not null
) 
select 
	proje.id as project_id,
	proje.code as project_code,
	pm.code as modality_code,
	pm.name as modality_name
from proje
join ipms_data.project_modality pm on (pm.code = proje.pm_code);
grant select on project_modality_fct to mycsd;