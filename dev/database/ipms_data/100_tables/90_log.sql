create sequence Log_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;

create table Log (
	id nvarchar2(20) not null primary key,
	subject nvarchar2(100) not null,
	event_date date default sysdate not null,
	user_id nvarchar2(20) default 'IPMS' not null,
	summary nvarchar2(200) not null,
	details clob not null);
