alter table timeline add ltc_process_id number;
alter table timeline_baseline add ltc_process_id number;
comment on column timeline.ltc_process_id is 'Soft reference to ltc_process in order to have a link with process that was running during ltci_id timestamp.';
comment on column timeline_baseline.ltc_process_id is 'Soft reference to ltc_process in order to have a link with process that was running during ltci_id timestamp.';