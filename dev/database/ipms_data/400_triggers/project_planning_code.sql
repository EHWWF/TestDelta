create or replace trigger project_planning_code_biu_tr
before insert or update on project_planning_code for each row
  begin
    if inserting then
      :new.create_date := sysdate;
	end if;
	
	:new.update_date := sysdate;
  end;
/