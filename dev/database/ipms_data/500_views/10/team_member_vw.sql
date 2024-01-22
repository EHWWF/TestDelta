create or replace view team_member_vw as
select
	tm.program_id,
	tmp.project_id,
	tm.id as team_member_id,
	tm.employee_code,
	tm.role_code
from team_member tm
left join team_member_project tmp on (tm.id=tmp.team_member_id);