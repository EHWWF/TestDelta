create or replace view member_vw as
select
	tm.program_id,
	tmp.project_id,
	tm.employee_code,
	tm.role_code,
	tm.id as member_id
from team_member tm
join team_member_project tmp on (tm.id=tmp.team_member_id);