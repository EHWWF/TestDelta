create or replace trigger program_sandbox_tr
before insert or update on program_sandbox
for each row
begin
	if inserting then
		if :new.id is null then
			select sandbox_id_seq.nextval into :new.id from dual;
		end if;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		:new.create_date := sysdate;
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
end;
/