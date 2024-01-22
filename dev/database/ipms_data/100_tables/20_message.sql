create sequence Message_Id_SEQ maxvalue 999999999999999999 minvalue 1 cycle;

create table Message (
	id nvarchar2(20) not null primary key,
	request xmltype not null,
	request_date date default sysdate not null,
	request_user_id nvarchar2(20) default 'IPMS' not null,
	response xmltype,
	response_date date,
	subject nvarchar2(100) not null,
	composite_id nvarchar2(20),
	callback varchar2(1000));

create index message_idx1 on Message(subject);
