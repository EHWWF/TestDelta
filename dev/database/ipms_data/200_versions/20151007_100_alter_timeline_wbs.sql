alter table timeline_wbs add (sandbox_id nvarchar2(100));
alter table timeline_wbs add (root_wbs_id nvarchar2(100));
update timeline_wbs w set sandbox_id = (select id from program_sandbox where snd_timeline_id=w.timeline_id);
update timeline_wbs w set root_wbs_id = (select reference_id from timeline where id=w.timeline_id);