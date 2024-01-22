drop materialized view team_member_dim;

create materialized view team_member_dim as
select
	distinct 
	substr(m.project_id || '-' || m.employee_code || '-' || m.role_code,1,100) as id,
	m.program_id,
	substr(m.project_id,1,20) as project_id,
	m.employee_code as cwid,
	substr(emp.name,1,200) as cwid_name,
	ur.role_code as program_role,
	m.role_code,
	tr.name as role
from ipms_data.team_member_vw m
left join ipms_data.team_role tr on tr.code = m.role_code
left join ipms_data.employee emp on emp.code = m.employee_code
left join ipms_data.user_role ur on ur.user_id = m.employee_code and ur.program_id = m.program_id
where m.project_id is not null;

comment on materialized view team_member_dim is 'After moving data to: team_member_project should not be the case for NULL project_id';

grant select on team_member_dim to mycsd;