create or replace trigger project_area_tr
before insert or update on project_area
for each row
begin
	:new.is_running_import := upper(:new.is_running_import);
end;
/