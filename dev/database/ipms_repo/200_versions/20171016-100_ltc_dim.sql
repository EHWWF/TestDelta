drop index cost_ltc_process_dim_ui;
alter table cost_ltc_process_dim modify (process_id not null);
alter table cost_ltc_process_dim modify (tag_id not null);
alter table cost_ltc_process_dim add constraint cost_ltc_process_dim_pk primary key (process_id) enable;
alter table cost_ltc_fte_fct drop column estimate_create_date;
alter table cost_ltc_fte_fct drop column estimate_update_date;