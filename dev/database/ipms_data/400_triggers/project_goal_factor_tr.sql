create or replace trigger project_goal_factor_tr
before insert or update on project_goal_factor
for each row
begin
	if inserting then
		if :new.id is null then
			select prj_goal_factor_seq.nextval into :new.id from dual;
		end if;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		:new.create_date := sysdate;
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
end;
/