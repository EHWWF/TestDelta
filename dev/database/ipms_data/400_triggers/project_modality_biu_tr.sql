create or replace trigger project_modality_biu_tr
before insert or update on project_modality for each row
  begin
    if inserting then
      :new.create_date := sysdate;
	end if;
	
	:new.update_date := sysdate;
	:new.code := replace(upper(:new.code),' '); --clean CODE
  end;
/