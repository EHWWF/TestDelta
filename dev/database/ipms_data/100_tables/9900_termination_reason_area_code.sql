create table termination_reason_area_code
(
termination_code nvarchar2(10) not null,
area_code nvarchar2(10) not null, 
constraint ter_reason_area_code_fk1 foreign key (termination_code) references termination_reason (code) on delete cascade, 
constraint ter_reason_area_code_fk2 foreign key (area_code) references project_area (code) on delete cascade
);
create unique index ter_reason_area_code_uidx on termination_reason_area_code (termination_code,area_code);