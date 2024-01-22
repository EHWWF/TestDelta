create or replace trigger ltc_milestone_phasemap_biu_tr
before insert or update on ltc_milestone_phase_mapping for each row
begin
	if inserting then
		:new.create_date := sysdate;
	end if;
	if updating then
		:new.update_date := sysdate;
	end if;
end;
/