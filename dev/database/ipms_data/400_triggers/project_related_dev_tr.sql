--------------------------------------------------------
--  DDL for Trigger PROJECT_RELATED_DEV_TR
--------------------------------------------------------

create or replace TRIGGER IPMS_DATA.PROJECT_RELATED_DEV_TR
for insert or update on PROJECT_RELATED_DEV
compound trigger
before each row is
begin
	if inserting then
		if :new.id is null then
			select PRJ_REL_DEV_ID_SEQ.nextval into :new.id from dual;
		end if;
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		:new.update_user_id := :new.create_user_id;
	end if;
	if updating then
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
	:new.update_date := sysdate;
end before each row;

after each row is
begin
	if inserting then
		insert into project_related_msp(project_id, rel_msp_project_id)
		values (:new.dev_project_id , :new.project_id);
	end if;
--    if deleting then 
--        delete from project_related_msp prm where prm.project_id = :old.dev_project_id;
--    end if;   
    end after each row;
    end;
/
ALTER TRIGGER IPMS_DATA.PROJECT_RELATED_DEV_TR ENABLE;