--------------------------------------------------------
--  DDL for Trigger PROJECT_ROADMAP_TR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER IPMS_DATA.PROJECT_ROADMAP_TR 
before insert or update on project_roadmap for each row
begin
	if inserting then
		if :new.id is null then
			select roadmap_id_seq.nextval into :new.id from dual;
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
ALTER TRIGGER IPMS_DATA.PROJECT_ROADMAP_TR ENABLE;