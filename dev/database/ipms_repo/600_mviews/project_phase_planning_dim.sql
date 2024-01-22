drop materialized view project_phase_planning_dim;

create materialized view project_phase_planning_dim as
select
	ppp.id,
	ppp.project_id,
	ppp.phase_planning_code,
	ppt.name as phase_planning_name
from ipms_data.project_phase_planning ppp
join ipms_data.phase_planning_type ppt on (ppt.code = ppp.phase_planning_code);

grant select on project_phase_planning_dim to mycsd;