create or replace
trigger license_tr
before insert or update on license
for each row
begin
	if inserting then
		select license_id_seq.nextval into :new.id from dual;
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
end;
/