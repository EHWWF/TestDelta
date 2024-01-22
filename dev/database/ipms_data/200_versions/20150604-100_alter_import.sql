alter table import 
	add(sandbox_id nvarchar2(10) references program_sandbox(id) on delete cascade)
	add(constraint import_chk1 check (project_id is null or sandbox_id is null));

alter table import_timeline 
	add (timeline_id nvarchar2(20) references timeline(id) on delete cascade)
	modify (project_id null);

update import_timeline itml
set timeline_id = (select id from timeline where project_id = itml.project_id and itml.type_code='RAW') where timeline_id is null;

commit;