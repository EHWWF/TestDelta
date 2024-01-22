create or replace
trigger project_substance_code_tr
before insert on project_substance_code
for each row
begin
	if :new.id is null then
		select project_substance_code_id_seq.nextval into :new.id from dual;
	end if;
end;
/