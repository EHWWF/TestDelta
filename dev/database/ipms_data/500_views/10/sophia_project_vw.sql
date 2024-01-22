create or replace view sophia_project_vw as
select
	to_char(prj.project_id) as project_id,
	dev.code as le_overview,
	to_char(rownum) as scd2_key,
	1 as current_flag,
	sysdate-365 as valid_from,
	sysdate+365 as valid_to
from le_overview@sophia_db prj
join development_phase dev on dev.code=to_char(prj.late_est_overview_id);

drop table sophia_project_tmp;

create global temporary table sophia_project_tmp
on commit delete rows
as (select * from sophia_project_vw where 1=0);

create index sophia_project_tmp_idx1 on sophia_project_tmp(project_id);