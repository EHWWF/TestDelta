create or replace view logged_changes_vw as
select
	id,
	project_id,
	prj_update_user_id,
	details,
	create_user_id,
	create_date,
	state_code,
	decode(state_name,prev_state_name,state_name, prev_state_name||' >>> '||state_name) state_name,
	priority_code,
	decode(priority_name,prev_priority_name,priority_name, prev_priority_name||' >>> '||priority_name) priority_name,
	change_comment,
	phase_code,
	decode(phase_name,prev_phase_name,phase_name, prev_phase_name||' >>> '||phase_name) phase_name
from (
	select
		sele.*,
		prev.state_name prev_state_name,
		prev.priority_name prev_priority_name,
		prev.phase_name prev_phase_name
	from logged_changes_src_vw sele
	left join logged_changes_src_vw prev on (sele.parent_id = prev.id)
)
;