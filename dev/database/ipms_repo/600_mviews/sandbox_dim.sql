drop materialized view sandbox_dim;

create materialized view sandbox_dim as
select
id
,program_id
,timeline_id source_plan_id
,snd_id source_sandbox_id
,code
,name
,description
,reference_id plan_object_id
,snd_timeline_id target_plan_id
from ipms_data.program_sandbox
where reference_id is not null and snd_timeline_id is not null;

grant select on sandbox_dim to mycsd;