create or replace
trigger lead_study_instance_tr
before insert or update on lead_study_instance
for each row
begin
	if inserting then
		select lead_study_instance_id_seq.nextval into :new.id from dual;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		:new.notify_id := :new.id||':'||:new.status_code;
	end if;
	
	if updating then
		:new.notify_id := :old.id||':'||:new.status_code;
	end if;
end;
/