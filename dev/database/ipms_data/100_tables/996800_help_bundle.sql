create table help_bundle(
	code nvarchar2(100) primary key,
	name nvarchar2(500) not null,
	definition nvarchar2(2000) not null,
	url nvarchar2(2000) not null);
