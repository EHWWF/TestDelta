alter table ltc_project drop constraint ltc_project_proc_id_fk;
alter table ltc_project modify ltc_process_id number constraint ltc_project_proc_id_fk references ltc_process(id) on delete cascade;
alter table ltc_estimate drop constraint ltc_estimate_ltc_project_fk;
alter table ltc_estimate modify ltc_project_id number constraint ltc_estimate_ltc_project_fk references ltc_project(id) on delete cascade;