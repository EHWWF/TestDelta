alter table ltc_milestone_phase_mapping modify milestone_code nvarchar2(20) constraint ltc_mls_map_phase_mls_code_cc not null;
alter table ltc_milestone_phase_mapping modify phase_code nvarchar2(10) constraint ltc_mls_map_phase_code_cc not null;
alter table ltc_milestone_phase_mapping add create_date date default sysdate constraint ltc_mls_map_phase_cdate_cc not null;
alter table ltc_milestone_phase_mapping add update_date date default sysdate constraint ltc_mls_map_phase_udate_cc not null;
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