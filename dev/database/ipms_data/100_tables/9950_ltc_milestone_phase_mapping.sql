create table ltc_milestone_phase_mapping (
	milestone_code nvarchar2(20),
	phase_name nvarchar2(100)
);
insert into ltc_milestone_phase_mapping
(
	select 'D3' as milestone_code, 'D3-D4' as phase_name from dual
	union
	select 'M4A' as milestone_code, 'D4-D6' as phase_name from dual
	union
	select 'M6A' as milestone_code, 'D6-D7' as phase_name from dual
	union
	select 'M7A' as milestone_code, 'D7-D8' as phase_name from dual
	union
	select 'M8A' as milestone_code, 'D8-Launch' as phase_name from dual
	union
	select 'M8B' as milestone_code, 'Launch' as phase_name from dual
);