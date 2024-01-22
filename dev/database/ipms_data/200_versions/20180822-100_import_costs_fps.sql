alter table import_costs_fps add project_activity_id varchar2(100);
comment on column import_costs_fps.project_activity_id is 'Column needed for Activity Based Planning.';
alter table costs_fps add project_activity_id varchar2(100);
comment on column costs_fps.project_activity_id is 'Column needed for Activity Based Planning.';
create index imp_costs_fps_actid_fki on import_costs_fps(project_activity_id);
create index costs_fps_actid_fki on costs_fps(project_activity_id);