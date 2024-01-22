create table latest_estimates_tag (id nvarchar2(30) not null enable, name nvarchar2(100) not null enable, create_date date not null enable, create_user_id nvarchar2(30) not null enable,
constraint let_pk primary key (id),
constraint let_uk1 unique (name));

create sequence let_id_seq  minvalue 1;