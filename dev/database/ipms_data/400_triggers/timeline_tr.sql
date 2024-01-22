create or replace
trigger timeline_tr
before insert or update on timeline
for each row
begin
	if inserting then
		if :new.id is null then
			select :new.project_id||'-'||:new.type_code into :new.id from dual;
		end if;
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
        :new.notify_id := :old.id||':'||:new.is_syncing;
	end if;
end;
/