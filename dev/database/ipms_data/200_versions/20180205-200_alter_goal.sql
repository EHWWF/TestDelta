alter table goal drop constraint goal_type;

alter table goal add constraint goal_type check (type in ('T', 'K', 'B','DC'));