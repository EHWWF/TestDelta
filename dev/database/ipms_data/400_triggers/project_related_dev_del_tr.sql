--------------------------------------------------------
--  DDL for Trigger PROJECT_RELATED_DEV_DEL_TR
--------------------------------------------------------

create or replace TRIGGER IPMS_DATA.PROJECT_RELATED_DEV_DEL_TR
before delete on PROJECT_RELATED_DEV for each row
begin
    delete from project_related_msp prm where prm.project_id = :old.dev_project_id;
end;
/
ALTER TRIGGER IPMS_DATA.PROJECT_RELATED_DEV_DEL_TR ENABLE;