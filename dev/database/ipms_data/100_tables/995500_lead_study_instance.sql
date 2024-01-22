create table lead_study_instance (
	id nvarchar2(50) not null primary key,
	project_id nvarchar2(30) not null references project(id),
	is_syncing number(1) default 0 not null,
	create_user_id nvarchar2(20) default 'IPMS' not null,
	create_date date default sysdate not null);

create sequence lead_study_instance_id_seq maxvalue 9999999999999999999 minvalue 1 cycle;	