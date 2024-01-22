create sequence Comments_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;

create table Comments (
	id nvarchar2(20) not null primary key,
	subject nvarchar2(100) not null,
	text nvarchar2(500) not null,
	create_user_id nvarchar2(20) default 'IPMS' not null,
	create_date date default sysdate not null,
	update_user_id nvarchar2(20),
	update_date date);

create index comments_idx1 on Comments(subject);

create sequence Announcement_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;

create table Announcement (
	id nvarchar2(20) not null primary key,
	text nvarchar2(500) not null,
	start_date date default sysdate not null,
	finish_date date not null,
	create_user_id nvarchar2(20) default 'IPMS' not null,
	create_date date default sysdate not null,
	update_user_id nvarchar2(20),
	update_date date);

create index Announcement_idx1 on Announcement(start_date,finish_date);
