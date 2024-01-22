alter table project add (accounting_status nvarchar2(20));
alter table project add (successor_project_id nvarchar2(20));
alter table project add (planning_enabled nvarchar2(20));
alter table project add (current_comment nvarchar2(254));
alter table project add (comment_previous_fc nvarchar2(254));
alter table project add (controlling_project_type nvarchar2(50));