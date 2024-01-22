create sequence Phase_Duration_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;

create table Therapeutic_Area (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Strategic_Business_Entity (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create or replace synonym SBE for Strategic_Business_Entity;

create table Function (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table SubFunction (
	code nvarchar2(10) not null primary key,
	function_code nvarchar2(10) references Function(code),
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Substance_Type (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Termination_Reason (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Project_Source (
	code nvarchar2(20) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Global_Business_Unit (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create or replace synonym GBU for Global_Business_Unit;

create table Priority (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Project_State (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Display_State (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Milestone (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	type_code nvarchar2(10) not null references Milestone_Type(code),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Region (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Project_Category (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Project_Area (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Project_Area_Milestone (
	area_code nvarchar2(10) not null references Project_Area(code),
	milestone_code nvarchar2(10) not null references Milestone(code),
	primary key(area_code, milestone_code));

create table Phase (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)),
	ordering number(10) unique);

create table Phase_Milestone (
	phase_code nvarchar2(10) not null references Phase(code),
	milestone_code nvarchar2(10) not null references Milestone(code),
	category nvarchar2(2) default 'CF' not null check(category in ('CF','GT')),
	primary key(phase_code, milestone_code, category));

create table Phase_Duration (
	id nvarchar2(20) not null primary key,
	sbe_code nvarchar2(10) references Strategic_Business_Entity(code),
	substance_type_code nvarchar2(10) references Substance_Type(code),
	phase_code nvarchar2(10) not null references Phase(code),
	duration number(10) default 0 not null,
	unique(sbe_code,substance_type_code,phase_code));

create table Development_Phase (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table News_Category (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table License_Type (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Substance (
	code nvarchar2(10) not null primary key,
	name nvarchar2(500) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Molecular_Entity (
	code nvarchar2(10) not null primary key,
	substance_code nvarchar2(10) not null references Substance(code),
	name nvarchar2(500) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create or replace synonym SMU for Molecular_Entity;

create table Team_Role (
	code nvarchar2(20) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Goal_Status (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Employee (
	code nvarchar2(20) not null primary key,
	name nvarchar2(200) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Bay_Number (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Substance_Combination (
	substance_code nvarchar2(10) not null references Substance(code) on delete cascade,
	combination_code nvarchar2(10) not null references Bay_Number(code) on delete cascade,
	is_active number(1) default 1 not null check(is_active in (0,1)),
	primary key(substance_code, combination_code));

create or replace synonym Substance_Combi for Substance_Combination;

create table phase_transition_d3 (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Target_Class (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Target_Origin (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));