create or replace trigger import_project_activity_tr
before insert
  on import_project_activity
for each row
begin
	select import_project_activity_id_seq.nextval into :new.id from dual;
end;
/
