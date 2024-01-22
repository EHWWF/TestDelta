create or replace trigger sbe_biu_tr
before insert or update on strategic_business_entity for each row
  begin
    if inserting then
      :new.create_date := sysdate;
	end if;
	
	:new.update_date := sysdate;
	select decode(:new.is_active,0,0,:new.is_visible) into :new.is_visible from dual; --if InActive then IsVisible also must be False: PROMIS-519
  end;
/