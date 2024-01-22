create sequence costs_id_ged_seq maxvalue 9999999999999999999 minvalue 1 cycle;

create table costs_ged (
	id nvarchar2(20) not null primary key,
	project_id nvarchar2(20) not null references project(id) on delete cascade,
	study_id nvarchar2(20),
	subfunction_code nvarchar2(10) references subfunction(code),
	scope_code nvarchar2(10) not null references costs_scope(code),
	method_code nvarchar2(10) not null references calculation_method(code),
	type_code nvarchar2(10) not null references costs_type(code),
	subtype_code nvarchar2(10) references costs_subtype(code),
	cost number(20,10) not null,
	committed_state	nvarchar2(1),
	start_date date not null,
	finish_date date not null,
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date);

create index costs_ged_idx1 on costs_ged(project_id);