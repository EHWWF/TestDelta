alter table project add(qplan_release_date date);
comment on column project.qplan_release_date is 'The datetime for successful release to QPlan/FPS.';