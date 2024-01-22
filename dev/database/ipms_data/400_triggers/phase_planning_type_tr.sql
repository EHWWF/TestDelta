create or replace trigger phase_planning_type_tr
before insert or update on phase_planning_type
for each row
begin
	if inserting then
		:new.create_date := sysdate;
	end if;
	:new.update_date := sysdate;
	:new.code := replace(lower(:new.code),' ');
end;
/