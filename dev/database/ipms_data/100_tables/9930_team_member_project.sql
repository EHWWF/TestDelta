create table team_member_project 
( id nvarchar2(20) not null 
, team_member_id nvarchar2(20) not null 
, project_id nvarchar2(20) not null 
, constraint team_member_project_pk primary key (id) enable );

alter table team_member_project add constraint team_member_project_fk1 foreign key 
(team_member_id) references team_member (id) on delete cascade enable;

alter table team_member_project add constraint team_member_project_fk2 foreign key
(project_id) references project (id) on delete cascade enable;

create sequence team_member_project_id_seq minvalue 1 maxvalue 999999999999999999 increment by 1 start with 1;

create unique index team_member_project_uidx on team_member_project (team_member_id, project_id);