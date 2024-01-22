truncate table project_activity;
alter table project_activity add (artificial_id varchar2(1000) constraint pa_artificial_id_cnn not null,
                                  is_to_be_deleted number(1) default 0 constraint pa_is_to_be_deleted_cnn not null,
                                  create_user varchar2(100) constraint pa_create_user_cnn not null);
truncate table import_project_activity;
alter table import_project_activity add (artificial_id varchar2(1000) constraint ipa_artificial_id_cnn not null);
alter table import_project_activity add (create_user varchar2(100) constraint ipa_create_user_cnn not null);
alter table import_project_activity drop  constraint ipact_uk1;
alter table import_project_activity drop column milestone_code;
alter table import_project_activity add constraint ipact_uk1 unique(import_id,project_id,project_activity_id,study_id, wbs_category);