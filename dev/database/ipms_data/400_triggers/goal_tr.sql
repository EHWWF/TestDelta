create or replace trigger goal_tr
before insert or update on goal
for each row
begin
	if inserting then
		if :new.id is null then
			select goal_id_seq.nextval into :new.id from dual;
		end if;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		:new.create_date := sysdate;
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
	if inserting or updating then
		goal_pkg.update_ref_date_after_st(:new.id,:new.project_id,:new.plan_reference,
		:new.study_id,:new.target_date,:new.plan_reference_date,:new.status,:new.ref_date_type);
	end if;
end;
/