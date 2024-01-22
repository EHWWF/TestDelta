create or replace trigger latest_estimates_project_tr
before insert on latest_estimates_project
for each row
begin
	if :new.id is null then
		select le_project_id_seq.nextval into :new.id from dual;
	end if;
end;
/