--------------------------------------------------------
--  DDL for Trigger PROJECT_LICENSE_TR
--------------------------------------------------------

create or replace TRIGGER IPMS_DATA.PROJECT_LICENSE_TR 
for insert or update on license_details
compound trigger
before each row is
begin
	if inserting then
		if :new.id is null then
			select license_id_seq.nextval into :new.id from dual;
		end if;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		:new.update_user_id := :new.create_user_id;
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
end before each row;
end;

/
ALTER TRIGGER IPMS_DATA.PROJECT_LICENSE_TR ENABLE;