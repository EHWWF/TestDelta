create or replace trigger import_study_tr
before insert on import_study
for each row
begin
	select import_study_id_seq.nextval into :new.id from dual;
end;
/