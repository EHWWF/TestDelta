create sequence Program_Id_SEQ maxvalue 999999999 minvalue 1 cycle;

create table Program (
	id nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	code nvarchar2(20) not null,
	substance nvarchar2(500),
	description nvarchar2(500),
	create_date date default sysdate not null,
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_date date,
	update_user_id nvarchar2(20),
	sync_date date,
	is_syncing number(1) default 0 not null check(is_syncing in (0,1)),
	sync_id nvarchar2(20));
