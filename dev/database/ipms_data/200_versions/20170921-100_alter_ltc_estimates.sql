alter table ltc_estimate add (is_discrepancy_profit number(1) default 0 constraint ltc_estimate_discrep_prf_cnn not null constraint ltc_estimate_discrep_prf_in check(is_discrepancy_profit in (0,1)));
alter table ltc_estimate add (is_discrepancy_p6 number(1) default 0 constraint ltc_estimate_discrep_p6_cnn not null constraint ltc_estimate_discrep_p6_in check(is_discrepancy_p6 in (0,1)));
alter table ltc_estimate drop constraint ltc_estimate_ui;
alter table ltc_estimate drop column is_discrepancy;
alter table ltc_estimate add (is_discrepancy number(1) as (decode(is_discrepancy_profit+is_discrepancy_p6,0,0,1)));
alter table ltc_estimate add constraint ltc_estimate_ui unique (ltc_project_id, project_phase_code, study_id, function_code, scope_code, is_external_fte, is_discrepancy,type_code);