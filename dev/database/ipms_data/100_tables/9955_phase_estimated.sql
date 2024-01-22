create table phase_estimated (
code nvarchar2(20) not null enable,
name nvarchar2(100) not null enable,
is_active number(1,0) default 1 not null enable,
ordering number(10,0) default 50 not null,
check (is_active in (0,1)) enable,
primary key (code)
);