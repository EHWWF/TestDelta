alter table ltc_estimate drop constraint ltc_estimate_ui;
alter table ltc_estimate drop column type;

alter table ltc_estimate add (type_code nvarchar2(10));
update ltc_estimate set type_code='LTC';
commit;
alter table ltc_estimate modify type_code nvarchar2(10) constraint ltc_estimate_type_cnn not null;
alter table ltc_estimate add constraint ltc_estimate_ui unique (ltc_project_id, project_phase_code, study_id, function_code, scope_code, is_external_fte, is_discrepancy,type_code);

alter table ltc_estimate drop constraint LTC_ESTIMATE_SCOPE_CNN;