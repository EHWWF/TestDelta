create or replace TRIGGER IPMS_DATA.TEAM_ROLE_TR 
before insert or update on team_role
for each row
begin
	--PROMISIII-337
	--- it is still not clear what are default values (when UI does not provide explicit select,
	--- but it is less risky to allow at least for DEV type of projects, the rest could be -disabled
	:new.is_dev_relevant := nvl(:new.is_dev_relevant,1);
	:new.is_prdmnt_relevant := nvl(:new.is_prdmnt_relevant,0);
	:new.is_d2prj_relevant := nvl(:new.is_d2prj_relevant,0);
    -- PROMIS 604
    :new.is_samd_relevant := nvl(:new.is_samd_relevant,0);
end;