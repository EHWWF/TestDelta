create table project_audit_pidt (
project_id nvarchar2(20) not null primary key,
state_code nvarchar2(20) not null,
finishing_date date,
pidt_release_date date,
create_date date default sysdate not null
);