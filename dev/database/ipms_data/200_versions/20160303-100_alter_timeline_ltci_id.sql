alter table timeline disable all triggers;
alter table timeline add (baseline_type_id nvarchar2(20) references baseline_type(id));
alter table timeline add (ltci_id number references ltc_instance(id));
comment on column timeline.ltci_id is 'Reference to LTC for selected timeline.';
alter table timeline enable all triggers;