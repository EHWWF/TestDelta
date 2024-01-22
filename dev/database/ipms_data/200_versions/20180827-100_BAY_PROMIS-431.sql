truncate table import_project_activity;
alter table import_project_activity drop constraint ipact_uk1;
alter table import_project_activity  add constraint ipact_uk1 unique(import_id,project_id,project_activity_id,study_id, milestone_code);
alter table project_activity drop constraint pact_uk1;
alter table project_activity  add constraint pact_uk1 unique (project_id, project_activity_id, study_id, wbs_category);
drop index pact_idx1;
create unique index pact_idx1 on project_activity(lower(project_id||':'||project_activity_id||':'||study_id||':'|| wbs_category));