create or replace
trigger study_tr
before insert or update on study
for each row
begin
	if inserting then
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
	:new.is_delete:=nvl(:new.is_delete,0);
end;
/