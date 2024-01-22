drop materialized view timeline;

create materialized view timeline as
select
	t.project_id,
	t.type_code as plan_type,
	t.id as plan_id,
	t.reference_id as plan_object_id,
	nvl(p.program_id,s.program_id) program_id,
	s.id sandbox_id
from ipms_data.timeline t
left join ipms_data.program_sandbox s on (t.id=s.snd_timeline_id)
left join ipms_data.project p on (t.project_id=p.id);