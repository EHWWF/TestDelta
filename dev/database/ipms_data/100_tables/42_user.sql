create sequence User_Role_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;
create sequence Team_Member_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;

create table User_Role (
	id nvarchar2(20) not null primary key,
	user_id nvarchar2(20) not null,
	role_code nvarchar2(20) not null,
	program_id nvarchar2(10) references Program(id) on delete cascade,
	create_user_id nvarchar2(20) default 'IPMS' not null,
	create_date date default sysdate not null,
	update_user_id nvarchar2(20),
	update_date date,
	unique(user_id,program_id));

create table Team_Member (
	id nvarchar2(20) not null primary key,
	program_id nvarchar2(10) not null references Program(id),
	project_ids nvarchar2_table_typ default nvarchar2_table_typ(),
	employee_code nvarchar2(10) not null references Employee(code),
	role_code nvarchar2(20) not null references Team_Role(code),
	create_user_id nvarchar2(20) default 'IPMS' not null,
	create_date date default sysdate not null,
	update_user_id nvarchar2(20),
	update_date date,
	unique(employee_code,program_id))
	nested table project_ids store as team_member_project_ids_tab;