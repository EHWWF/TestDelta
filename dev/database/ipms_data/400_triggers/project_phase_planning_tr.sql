create or replace trigger project_phase_planning_tr
before insert or update on project_phase_planning
for each row
begin
	if inserting then
		if :new.id is null then
			select prj_phase_plan_id_seq.nextval into :new.id from dual;
		end if;
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		:new.update_user_id := :new.create_user_id;
	end if;
	if updating then
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
	:new.update_date := sysdate;
end;
/