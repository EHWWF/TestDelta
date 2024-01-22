alter table project disable all triggers;
alter table project add (phase_estimated_code nvarchar2(20) references phase_estimated(code));
comment on column project.phase_estimated_code is 'PROMIS-693, enables BHC to override existing project phase calculation algorithm by setting a custom project phase up in addition to the existing project phase logic.';
alter table project enable all triggers;