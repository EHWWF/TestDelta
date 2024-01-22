create table baseline_type (
id nvarchar2(20) not null, 
name nvarchar2(200) not null, 
create_date date default sysdate not null, 
update_date date,
is_active number(1,0) default 1 not null,
sequence_number number default 1 not null,
is_selectable number(1,0) default 1 not null,
constraint baseline_type_pk primary key (id),
constraint baseline_type_uk1 unique (name)
);
comment on table baseline_type is 'The table is used for storing Baseline types taken directly from P6. The source is P6, so, all changes should be done only at P6. config.BPEL is responsible for making changes here.';
comment on column baseline_type.id is 'It is ObjectId taken from P6.';
comment on column baseline_type.name is 'Name must be unique same as at P6.';