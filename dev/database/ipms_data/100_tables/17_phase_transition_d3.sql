create table phase_transition_d3 (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));