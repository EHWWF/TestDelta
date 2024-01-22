create or replace trigger phase_duration_tr
before insert or update on phase_duration
for each row
begin
	if inserting then
		select phase_duration_id_seq.nextval into :new.id from dual;
		:new.create_date := sysdate;
		:new.update_date := :new.create_date;
	end if;
	if updating then
		:new.update_date := sysdate;
	end if;
end;
/