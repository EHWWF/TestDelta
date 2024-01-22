create table top_function
	(code nvarchar2(10) not null,
	name nvarchar2(100) not null,
	abbreviation nvarchar2(10),
	is_active number(1,0) default 1 not null,
	valid_from date not null,
	valid_to date,
	create_date date default sysdate not null,
	update_date date,
	check (is_active in (0,1)),
	primary key (code));