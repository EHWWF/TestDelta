create sequence Costs_Probability_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;
create sequence Costs_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;

create table Costs_Probability (
	id nvarchar2(20) not null primary key,
	scope_code nvarchar2(10) not null references Costs_Scope(code),
	probability number(20) not null,
	function_code nvarchar2(10) references Function(code),
	phase_code nvarchar2(10) references Phase(code),
	sbe_code nvarchar2(10) references Strategic_Business_Entity(code),
	substance_type_code nvarchar2(10) references Substance_Type(code),
	study_element_id nvarchar2(20),
	project_id nvarchar2(20) references Project(id) on delete cascade,
	lag number(10) check(lag > 0),
	rule_code nvarchar2(10) references Probability_Rule(code),
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date,
	check((scope_code = 'INT' and phase_code is not null) or (scope_code = 'EXT' and function_code is not null and study_element_id is not null and rule_code is not null)),
	check(probability > 0 and probability <= 100),
	unique(scope_code,project_id,phase_code,sbe_code,substance_type_code,function_code,rule_code,lag));

create table Costs (
	id nvarchar2(20) not null primary key,
	project_id nvarchar2(20) not null references Project(id) on delete cascade,
	study_id nvarchar2(20),
	function_code nvarchar2(10) references Function(code),
	subfunction_code nvarchar2(10) references SubFunction(code),
	scope_code nvarchar2(10) not null references Costs_Scope(code),
	method_code nvarchar2(10) not null references Calculation_Method(code),
	status_code nvarchar2(10) references Study_Status(code),
	type_code nvarchar2(10) not null references Costs_Type(code),
	subtype_code nvarchar2(10) references Costs_SubType(code),
	development_phase_code nvarchar2(10) references Development_Phase(code),
	cost number(20,10) not null,
	start_date date not null,
	finish_date date not null,
	comments nvarchar2(500),
	forecast_year number(10),
	forecast_month number(10),
	forecast_number number,
	forecast_version number,
	is_last_forecast number(1) check(is_last_forecast in (0,1)),
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date);

create index Costs_idx1 on Costs(project_id);
create index costs_idx2 on costs(forecast_number, forecast_version);