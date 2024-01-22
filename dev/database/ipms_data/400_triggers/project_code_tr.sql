create or replace TRIGGER IPMS_DATA.PROJECT_CODE_CHANGED_TR 
after update on project
for each row-- This trigger should only fire when an existing code changes
 WHEN (old.code is not null and old.code != new.code) begin
	if :new.qplan_release_date is not null then
		notify_pkg.project_code_changed(:new.id, :old.code, :new.code);
	end if;
end;
