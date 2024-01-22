create or replace trigger device_phase_biu_tr
before insert or update on device_phase for each row
  begin
    if inserting then
      :new.create_date := sysdate;
	end if;
	:new.update_date := sysdate;
	:new.code := replace(upper(:new.code),' ');
  end;
/