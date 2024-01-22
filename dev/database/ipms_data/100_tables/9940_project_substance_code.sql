create table project_substance_code
( id nvarchar2(20) not null 
, substance_code nvarchar2(120) not null 
, project_id nvarchar2(20) not null 
, constraint project_substance_code_pk primary key (id) enable );

alter table project_substance_code add constraint project_substance_code_fk1 foreign key 
(substance_code) references substance(code) on delete cascade enable;

alter table project_substance_code add constraint project_substance_code_fk2 foreign key
(project_id) references project (id) on delete cascade enable;

create sequence project_substance_code_id_seq minvalue 1 maxvalue 999999999999999999 increment by 1 start with 1;

create unique index project_substance_code_uidx on project_substance_code (substance_code, project_id);