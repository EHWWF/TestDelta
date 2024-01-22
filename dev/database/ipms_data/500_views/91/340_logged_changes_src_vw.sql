create or replace view logged_changes_src_vw as
select
	project_audit.id id,
	project_audit.parent_id parent_id,
	project_audit.project_id project_id, 
	project_audit.prj_update_user_id prj_update_user_id, 
	project_audit.details details, 
	project_audit.create_user_id create_user_id, 
	project_audit.create_date create_date, 
	projectstate.code state_code,
	projectstate.name state_name,
	priority.code priority_code,
	priority.name priority_name,
	project_audit.change_comment change_comment,
	phase.code phase_code,
	phase.name phase_name
from project_audit
left join project_state projectstate on projectstate.code = extractvalue(project_audit.details, '/PROJECT/@STATE')
left join priority priority on priority.code = extractvalue(project_audit.details, '/PROJECT/@PRIORITY')
left join phase phase on phase.code = extractvalue(project_audit.details, '/PROJECT/@PHASE')
where project_audit.record_type = 'IPMS'
;