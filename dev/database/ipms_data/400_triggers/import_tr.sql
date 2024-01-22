create or replace
trigger import_tr
before insert or update on import
for each row
begin
	if inserting then
		select import_id_seq.nextval into :new.id from dual;
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		:new.notify_id := :new.id||':'||:new.status_code;
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
		:new.notify_id := :old.id||':'||:new.status_code;
	end if;
end;
/