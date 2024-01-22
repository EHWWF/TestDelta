create or replace trigger sys_guid_tr
before insert on sys_guid
for each row
begin
	:new.ba_code := lower(:new.ba_code);
end;
/