create synonym ipms_data.export_cost_ltc_process_dim for ipms_repo.cost_ltc_process_dim;
grant select on ipms_data.export_cost_ltc_process_dim to mxcbi;
grant select on ipms_data.export_cost_ltc_process_dim to mycsd;
create synonym ipms_data.export_cost_ltc_fte_fct for ipms_repo.cost_ltc_fte_fct;
grant select on ipms_data.export_cost_ltc_fte_fct to mxcbi;
grant select on ipms_data.export_cost_ltc_fte_fct to mycsd;
prompt 
prompt ----> ERROR, FEHLER: assure that DBA runs missing grants for IPMS_REPO two tables for two users: mxcbi, mycsd
prompt