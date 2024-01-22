--------------------------------------------------------
--  DDL for Trigger PROJECT_RELATED_MSP_TR
--------------------------------------------------------

create or replace TRIGGER IPMS_DATA.PROJECT_RELATED_MSP_TR 
before insert or update on PROJECT_RELATED_MSP
for each row
begin
	if inserting then
		if :new.id is null then
			select PRJ_REL_MSP_ID_SEQ.nextval into :new.id from dual;
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
ALTER TRIGGER IPMS_DATA.PROJECT_RELATED_MSP_TR ENABLE;