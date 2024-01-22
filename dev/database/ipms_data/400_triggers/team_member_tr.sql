create or replace
trigger team_member_tr
before insert or update on team_member
for each row
declare
 v_count number;
begin
	if inserting then
		if :new.id is null then
			select team_member_id_seq.nextval into :new.id from dual;
		end if;
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
	if :new.unique_assignment is null then
		select count(1) into v_count from program where id=:new.program_id and code='RESERVED-PT-D2-PRJ';
		if v_count = 1 then
			:new.unique_assignment:=:new.id;
		else
			:new.unique_assignment:=:new.program_id||'|'||:new.employee_code;
		end if;
	end if;
end;
/