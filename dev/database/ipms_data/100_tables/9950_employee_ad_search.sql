create table sys_guid
(id nvarchar2(100), 
user_id nvarchar2(20), 
ba_code nvarchar2(100), 
create_date date default sysdate, 
primary key (id));

create table employee_ad_search (
guid nvarchar2(150) not null references sys_guid(id),
cwid nvarchar2(20) not null,
forename nvarchar2(200) not null,
surname nvarchar2(200) not null,
create_date date default sysdate not null ,
primary key (guid,cwid));