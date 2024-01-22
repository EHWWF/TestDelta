create or replace
trigger import_timeline_tr
before insert on import_timeline
for each row
begin
	select import_timeline_id_seq.nextval into :new.id from dual;
end;
/