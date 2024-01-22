create sequence Resources_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;

create table Resources (
	id nvarchar2(20) not null primary key,
	project_id nvarchar2(20) not null references Project(id) on delete cascade,
	study_id nvarchar2(20),
	function_code nvarchar2(10) references Function(code),
	subfunction_code nvarchar2(10) references SubFunction(code),
	method_code nvarchar2(10) not null references Calculation_Method(code),
	type_code nvarchar2(10) not null references Resources_Type(code),
	demand number(20,10) not null,
	start_date date not null,
	finish_date date not null,
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date);

create index Resources_idx1 on Resources(project_id);

create sequence Headcount_Id_SEQ maxvalue 999999999999999999 minvalue 1 cycle;

create table Headcount (
	id nvarchar2(20) not null primary key,
	function_code nvarchar2(10) references Function(code),
	subfunction_code nvarchar2(10) references SubFunction(code),
	type_code nvarchar2(10) not null references Headcount_Type(code),
	demand number(20,10) not null,
	forecast_year number(10),
	forecast_month number(10),
	start_date date not null,
	finish_date date not null,
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date);