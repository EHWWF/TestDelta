alter table timeline disable all triggers;
alter table timeline add (create_date_p6 date);
comment on column timeline.create_date_p6 is 'Baseline creation at P6.';
alter table timeline enable all triggers;