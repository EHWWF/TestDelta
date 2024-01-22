create table Timeline_Type (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table TimeRow_Type (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Import_Action (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Import_Status (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Costs_Scope (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Costs_Type (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Costs_SubType (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Resources_Type (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Headcount_Type (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Study_Status (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)),
	ordering number(10) unique);

create table Calculation_Method (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Notice_Severity (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Process_Status (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Configuration (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	value nvarchar2(500));

create table Prefill_Type (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	calculation_method_code nvarchar2(10) references Calculation_Method(code),
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Milestone_Type (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Integration_Type (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Probability_Rule (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));

create table Discrepancy_Type (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	is_active number(1) default 1 not null check(is_active in (0,1)));
