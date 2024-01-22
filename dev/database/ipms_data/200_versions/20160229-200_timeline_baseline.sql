create table timeline_baseline (
id nvarchar2(20) not null,
timeline_id nvarchar2(20) not null,
baseline_type_id nvarchar2(20),
ltci_id number,
create_date_p6 date not null,
description nvarchar2(500),
create_date date default sysdate not null, 
update_date date,
constraint timeline_baseline_pk primary key (id),
constraint timeline_baseline_fk1 foreign key (ltci_id) references ltc_instance(id),
constraint timeline_baseline_fk2 foreign key (baseline_type_id) references baseline_type(id),
constraint timeline_baseline_fk3 foreign key (timeline_id) references timeline(id) on delete cascade
);
comment on table timeline_baseline is 'The table is used for storing Baseline taken directly from P6. The source is P6, so, all changes should be done only at P6. Only ltci_id should be updated based on local-ProMIS data.';
comment on column timeline_baseline.id is 'It is ObjectId taken from P6.';
comment on column timeline_baseline.create_date_p6 is 'Baseline creation at P6.';
comment on column timeline_baseline.description is 'Baseline comment taken from P6. Original name of the column at P6 is Description';