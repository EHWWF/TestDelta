create or replace view trace_vw as
with msg as (select id, message_pkg.get_summary(id) summary from message)
select
	rownum as id,
	s.subject,
	s.summary as subject_summary,
	s.details as subject_details,
	nvl2(msg_id, nvl(m.summary, 'Message['||nvl(s.msg_id,'-')||']'), null) as message_summary
from (
	select null as subject, null as msg_id, null as summary, null as details from dual where 1=0
	union all
	select program_pkg.get_subject(id), sync_id, program_pkg.get_summary(id), 'Entity is locked.' from program where is_syncing=1
	union all
	select program_pkg.get_subject(id), sync_id, program_pkg.get_summary(id), 'Entity is unsynchronized.' from program where sync_date is null
	union all
	select project_pkg.get_subject(id), sync_id, project_pkg.get_summary(id), 'Entity is locked.' from project where is_syncing=1
	union all
	select project_pkg.get_subject(id), sync_id, project_pkg.get_summary(id), 'Entity is unsynchronized.' from project where sync_date is null
	union all
	select timeline_pkg.get_subject(id), sync_id, timeline_pkg.get_summary(id), 'Entity is locked.' from timeline where is_syncing=1
	union all
	select timeline_pkg.get_subject(id), sync_id, timeline_pkg.get_summary(id), 'Entity is unsynchronized.' from timeline where sync_date is null
	union all
	select estimates_pkg.get_subject(id), sync_id, estimates_pkg.get_summary(id), 'Entity is locked.' from latest_estimates_process where is_syncing=1
	union all
	select estimates_pkg.get_subject(id), sync_id, estimates_pkg.get_summary(id), 'Entity is unsynchronized.' from latest_estimates_process where sync_date is null
) s
left join msg m on m.id=s.msg_id;