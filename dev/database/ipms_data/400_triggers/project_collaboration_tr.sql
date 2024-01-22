--------------------------------------------------------
--  DDL for Trigger PROJECT_COLLABORATION_TR
--------------------------------------------------------

create or replace TRIGGER IPMS_DATA.PROJECT_COLLABORATION_TR 
before insert or update on collaboration_details for each row
begin
	if inserting then
		if :new.id is null then
			select collaboration_id_seq.nextval into :new.id from dual;
		end if;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		:new.update_user_id := :new.create_user_id;
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
end;
/
ALTER TRIGGER IPMS_DATA.PROJECT_COLLABORATION_TR ENABLE;