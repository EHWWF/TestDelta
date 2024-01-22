create or replace trigger phase_estimated_tr
before insert or update on phase_estimated
for each row
begin
	:new.code := replace(upper(:new.code),' ');
end;
/