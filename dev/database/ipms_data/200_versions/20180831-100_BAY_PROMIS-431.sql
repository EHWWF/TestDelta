truncate table project_activity;
alter table project_activity add (is_manual number(1) default 0 constraint pa_is_manual_cnn not null);
truncate table import_project_activity;
alter table import_project_activity add (is_manual number(1) default 0 constraint ipa_is_manual_cnn not null);
alter table import_project_activity drop constraint ipact_uk1;
alter table import_project_activity  add constraint ipact_uk1 unique (import_id, project_id, project_activity_id, study_id, wbs_category,is_manual);
drop index pact_idx1;
create unique index pact_idx1 on project_activity(lower(project_id||':'||project_activity_id||':'||study_id||':'|| wbs_category||':'||is_manual));
alter table project_activity drop constraint pact_uk1;
alter table project_activity  add constraint pact_uk1 unique (project_id, project_activity_id, study_id, wbs_category);
alter table import_project_activity add (is_cat_reset number(1) default 0 constraint ipa_is_cat_reset_cnn not null);
alter table import_project_activity add (is_to_be_deleted number(1) default 0 constraint ipa_is_to_be_deleted_cnn not null);
alter table timeline add(is_pa_conflict number(1) default 0 constraint timeline_is_pa_conflict_cnn not null);