alter table ltc_estimate add (base_cost_source varchar2(10) default 'PROMIS' constraint ltc_base_source2_cnn not null);
update ltc_estimate set base_cost_source='PROFIT';
commit;
alter table ltc_estimate add constraint ltc_base_source_chk check (base_cost_source in ('PROFIT','FPS','PROMIS'));

drop table ltc_estimate_tmp;
create global temporary table ltc_estimate_tmp on commit delete rows as (select * from ltc_estimate where 1=0);
create index ltc_estimate_tmp_idx1 on ltc_estimate_tmp(ltc_project_id, project_phase_code, study_id, function_code, scope_code, is_external_fte, is_discrepancy, type_code);

create index ltc_estimate_idx1 on ltc_estimate(base_cost_source);