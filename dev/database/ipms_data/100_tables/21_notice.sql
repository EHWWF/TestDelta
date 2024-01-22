create sequence Notice_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;

create table Notice (
	id nvarchar2(20) not null primary key,
	subject nvarchar2(50),
	create_date date default sysdate not null,
	create_user_id nvarchar2(20) default 'IPMS' not null,
	severity_code nvarchar2(10) not null references Notice_Severity(code),
	content nvarchar2(2000) not null,
	user_id nvarchar2(20),
	role_code nvarchar2(10),
	details clob);
