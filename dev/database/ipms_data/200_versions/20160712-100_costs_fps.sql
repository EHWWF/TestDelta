alter table import_costs_fps add (decision_start nvarchar2(12));
create index costs_fps_decision_start_idx on costs_fps (decision_start);