drop index sophia_costs_vw_merge_prj_i;
alter table sophia_costs_vw_merge modify project_id nvarchar2(20);
create index sophia_c_vw_merge_prj_idx on sophia_costs_vw_merge (project_id);
create index sophia_c_vw_merge_cost_idx on sophia_costs_vw_merge (cost);
create index sophia_c_vw_merge_year_idx on sophia_costs_vw_merge (year);
create index sophia_c_vw_merge_tcode_idx on sophia_costs_vw_merge (cost_type_code);
create index sophia_c_vw_merge_fyear_idx on sophia_costs_vw_merge (forecast_year);