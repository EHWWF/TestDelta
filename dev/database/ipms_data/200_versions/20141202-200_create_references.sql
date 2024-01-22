create table reference (
	title nvarchar2(100) not null,
	link nvarchar2(255) not null,
	type nvarchar2(10) default 'HTTP' not null check(type in ('HTTP','MAIL')),
	unique(title,link));
