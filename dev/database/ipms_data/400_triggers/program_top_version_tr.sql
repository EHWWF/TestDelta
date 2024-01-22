create or replace trigger program_top_version_tr
before insert or update on program_top_version
for each row
begin
	if inserting then
		if :new.id is null then
			select program_top_v_id_seq.nextval into :new.id from dual;
		end if;
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		:new.update_user_id := :new.create_user_id;
	end if;
	if updating then
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
	:new.update_date := sysdate;
end;
/