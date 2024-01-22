create sequence resources_cs_id_seq maxvalue 9999999999999999999 minvalue 1 cycle;

create table resources_cs (
	id nvarchar2(20) not null primary key,
	project_id nvarchar2(20) not null references project(id) on delete cascade,
	study_id nvarchar2(20),
	function_code nvarchar2(10) references function(code),
	subfunction_code nvarchar2(10) references subfunction(code),
	method_code nvarchar2(10) not null references calculation_method(code),
	type_code nvarchar2(10) not null references resources_type(code),
	demand number(20,10) not null,
	start_date date not null,
	finish_date date not null,
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date);

create index resources_cs_idx1 on resources_cs(project_id);