drop table ltc_estimate_tmp;
create global temporary table ltc_estimate_tmp on commit delete rows as (select * from ltc_estimate where 1=0);
create index ltc_estimate_tmp_idx1 on ltc_estimate_tmp(ltc_project_id, project_phase_code, study_id, function_code, scope_code, is_external_fte, is_discrepancy, type_code);