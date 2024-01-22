delete from ltc_estimate where project_phase_code is null or project_phase_code not in (select code from phase);
commit;
alter table ltc_estimate modify(project_phase_code nvarchar2(100) constraint ltc_estimate_prj_phase_code_nn not null);
alter table ltc_estimate add constraint ltc_estimate_prj_phase_code_fk foreign key (project_phase_code) references phase (code);
alter table ltc_estimate add constraint ltc_estimate_type_code_chk check (type_code in ('LTC','FTE'));