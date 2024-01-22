drop index pact_idx1;
create unique index pact_idx1 on project_activity(lower(project_id||':'||project_activity_id||':'||study_id||':'|| wbs_category));