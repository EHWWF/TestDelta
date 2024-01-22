create sequence Import_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;
create sequence Import_Timeline_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;

create table Import (
	id nvarchar2(20) not null primary key,
	project_id nvarchar2(20) references Project(id) on delete cascade,
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	type_mask number(20) default 0 not null,
	is_manual number(1) default 0 not null check(is_manual in (1,0)),
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date,
	sync_date date,
	is_syncing number(1) default 0 not null check(is_syncing in (1,0)),
	sync_id nvarchar2(20));

create index Import_idx1 on Import(project_id);

create table Import_Costs (
	reference_id nvarchar2(20) not null,
	import_id nvarchar2(20) not null references Import(id) on delete cascade,
	project_id nvarchar2(20) not null references Project(id) on delete cascade,
	study_id nvarchar2(20),
	subfunction_code nvarchar2(10),
	type_code nvarchar2(10) not null references Costs_Type(code),
	subtype_code nvarchar2(10) references Costs_SubType(code),
	scope_code nvarchar2(10) not null references Costs_Scope(code),
	method_code nvarchar2(10) not null references Calculation_Method(code),
	year number(10) not null,
	month number(10) not null,
	cost number(20,10) not null,
	forecast_year number(10),
	forecast_month number(10),
	forecast_number number,
	forecast_version number,
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(reference_id,project_id,import_id,type_code));

create index Import_Costs_idx1 on Import_Costs(import_id);
create index Import_Costs_idx2 on Import_Costs(project_id);

create table Import_Resources (
	reference_id nvarchar2(20) not null,
	import_id nvarchar2(20) not null references Import(id) on delete cascade,
	project_id nvarchar2(20) not null references Project(id) on delete cascade,
	study_id nvarchar2(20),
	subfunction_code nvarchar2(10),
	method_code nvarchar2(10) not null references Calculation_Method(code),
	type_code nvarchar2(10) not null references Resources_Type(code),
	year number(10) not null,
	month number(10) not null,
	demand number(20,10),
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(reference_id,project_id,import_id,type_code));

create index Import_Resources_idx1 on Import_Resources(import_id);
create index Import_Resources_idx2 on Import_Resources(project_id);

create table Import_Headcount (
	reference_id nvarchar2(20) not null,
	import_id nvarchar2(20) not null references Import(id) on delete cascade,
	subfunction_code nvarchar2(10),
	type_code nvarchar2(10) not null references Headcount_Type(code),
	year number(10) not null,
	demand number(20,10),
	forecast_year number(10),
	forecast_month number(10),
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(reference_id,import_id,type_code));

create index Import_HeadCount_idx1 on Import_Headcount(import_id);

create table Import_SubFunction (
	import_id nvarchar2(20) not null references Import(id) on delete cascade,
	code nvarchar2(10) not null,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)),
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(import_id,code));

create index Import_SubFunction_idx1 on Import_SubFunction(import_id);

create table Import_Timeline (
	id nvarchar2(20) not null primary key,
	reference_id nvarchar2(20),
	import_id nvarchar2(20) not null references Import(id) on delete cascade,
	project_id nvarchar2(20) not null references Project(id) on delete cascade,
	parent_wbs_id nvarchar2(20),
	activity_id nvarchar2(20),
	activity_type nvarchar2(100),
	wbs_id nvarchar2(20),
	sequence_number number,
	type_code nvarchar2(10) references TimeRow_Type(code),
	action_code nvarchar2(10) references Import_Action(code),
	study_id nvarchar2(20),
	study_element_id nvarchar2(20),
	name nvarchar2(100),
	code nvarchar2(20),
	new_start_date date,
	new_finish_date date,
	old_start_date date,
	old_finish_date date,
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	check(status_code<>'OLD' and reference_id is not null or status_code='OLD' and (activity_id is not null or wbs_id is not null)),
	unique(reference_id,project_id,import_id,type_code,activity_id,wbs_id));

create index Import_Timeline_idx1 on Import_Timeline(import_id);
create index Import_Timeline_idx2 on Import_Timeline(project_id);

create table Import_Study (
	import_id nvarchar2(20) not null references Import(id) on delete cascade,
	project_id nvarchar2(20) not null references Project(id) on delete cascade,
	study_id nvarchar2(20) not null,
	wbs_id nvarchar2(20),
	name nvarchar2(100) not null,
	phase nvarchar2(100),
	plan_patients number(10),
	actual_patients number(10),
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(project_id,import_id,study_id));

create index Import_Study_idx1 on Import_Study(import_id);
create index Import_Study_idx2 on Import_Study(project_id);

create table Import_MasterData (
	reference_id nvarchar2(20),
	import_id nvarchar2(20) not null references Import(id) on delete cascade,
	project_id nvarchar2(20) not null references Project(id) on delete cascade,
	development_phase_code nvarchar2(10),
	sbe_code nvarchar2(10),
	bay_code nvarchar2(10),
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(project_id,import_id));

create index Import_MasterData_idx1 on Import_MasterData(import_id);
create index Import_MasterData_idx2 on Import_MasterData(project_id);

create table Import_Substance (
	import_id nvarchar2(20) not null references Import(id) on delete cascade,
	code nvarchar2(10) not null,
	name nvarchar2(500) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)),
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(import_id,code));

create index Import_Substance_idx1 on Import_Substance(import_id);

create table Import_Bay_Combination (
	import_id nvarchar2(20) not null references Import(id) on delete cascade,
	code nvarchar2(10) not null,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)),
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(import_id,code));

create index Import_Bay_Combination_idx1 on Import_Bay_Combination(import_id);

create table Import_Substance_Combination (
	import_id nvarchar2(20) not null references Import(id) on delete cascade,
	substance_code nvarchar2(10) not null,
	combination_code nvarchar2(10) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)),
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(import_id,substance_code,combination_code));

create index Import_Substance_Combi_idx1 on Import_Substance_Combination(import_id);
create or replace synonym Import_Substance_Combi for Import_Substance_Combination;

create table Import_Molecular_Entity (
	import_id nvarchar2(20) not null references Import(id) on delete cascade,
	code nvarchar2(10) not null,
	substance_code nvarchar2(10) not null,
	name nvarchar2(500) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)),
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(import_id,code));

create index Import_Molecular_Entity_idx1 on Import_Molecular_Entity(import_id);
create or replace synonym Import_SMU for Import_Molecular_Entity;

create table Import_Employee (
	import_id nvarchar2(20) not null references Import(id) on delete cascade,
	code nvarchar2(20) not null,
	name nvarchar2(200) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)),
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(import_id,code));

create index Import_Employee_idx1 on Import_Employee(import_id);

create table Import_Bay_Number (
	import_id nvarchar2(20) not null references Import(id) on delete cascade,
	code nvarchar2(10) not null,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)),
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(import_id,code));

create index Import_Bay_Number_idx1 on Import_Bay_Number(import_id);

create table Import_SBE (
	import_id nvarchar2(20) not null references Import(id) on delete cascade,
	code nvarchar2(10) not null,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)),
	status_code nvarchar2(10) default 'NEW' not null references Import_Status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(import_id,code));

create index Import_SBE_idx1 on Import_SBE(import_id);
