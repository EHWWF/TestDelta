create or replace
trigger announcement_tr
before insert or update on announcement
for each row
begin
	if inserting then
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		select announcement_id_seq.nextval into :new.id from dual;
	else
		:new.update_date:=sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
end;
/