create table import_study_data (
import_id nvarchar2(20) not null references Import(id) on delete cascade,
project_id nvarchar2(20) not null references Project(id) on delete cascade,
study_id nvarchar2(20) not null,
wbs_id nvarchar2(20),
name nvarchar2(100) not null,
start_date DATE,
finish_date DATE,
placeholder NUMBER,
status_code nvarchar2(10) default 'NEW' not null references import_status(code),
status_description nvarchar2(500),
create_date date default sysdate not null,
primary key(project_id,import_id,study_id)
);