create or replace procedure sleep(p_seconds in number)
as
begin
--ipms_repo does not have access to dbms_lock but it is needed for making waits between MView refresh
	if p_seconds is not null then
		dbms_lock.sleep(p_seconds);--sec
	end if;
exception when others then
	null;
end;
/