alter table import_resources add (project_activity_id varchar2(100));
alter table import_resources_cs add (project_activity_id varchar2(100));
alter table import_resources_ged add (project_activity_id varchar2(100));
alter table resources add (project_activity_id varchar2(100));
alter table resources_cs add (project_activity_id varchar2(100));
alter table resources_ged add (project_activity_id varchar2(100));
alter table sophia_all_resources_merge add (project_activity_id varchar2(100));

create index sophia_all_resources_m_idx8  on sophia_all_resources_merge (project_activity_id);