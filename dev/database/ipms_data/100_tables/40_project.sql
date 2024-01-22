create sequence Project_Id_SEQ maxvalue 99999 minvalue 1 cycle;
create sequence News_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;
create sequence Funding_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;
create sequence License_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;
create sequence Project_Audit_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;

create table Project (
	id nvarchar2(20) not null primary key,
	program_id nvarchar2(10) not null references Program(id) on delete cascade,
	code nvarchar2(20),
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_lead number(1) default 0 not null check(is_lead in (0,1)),
	is_active number(1) default 1 not null check(is_active in (0,1)),
	abbreviation nvarchar2(50),
	details_progress nvarchar2(2000),
	progress_date date,
	details_criteria nvarchar2(2000),
	details_mesh nvarchar2(2000),
	details_indication nvarchar2(2000),
	details_product nvarchar2(2000),
	details_goal nvarchar2(2000),
	details_action nvarchar2(2000),
	details_asia nvarchar2(2000),
	details_competition nvarchar2(2000),
	details_patent nvarchar2(2000),
	details_sales nvarchar2(2000),
	details_pmo nvarchar2(2000),
	details_partner nvarchar2(2000),
	priority_code nvarchar2(10) references Priority(code),
	state_code nvarchar2(10) references Project_State(code),
	category_code nvarchar2(10) references Project_Category(code),
	ta_code nvarchar2(10) references Therapeutic_Area(code),
	substance_type_code nvarchar2(10) references Substance_Type(code),
	termination_code nvarchar2(10) references Termination_Reason(code),
	source_code nvarchar2(20) references Project_Source(code),
	phase_code nvarchar2(10) references Phase(code),
	development_phase_code nvarchar2(10) references Development_Phase(code),
	area_code nvarchar2(10) references Project_Area(code),
	bay_code nvarchar2(10) references Bay_Number(code),
	sbe_code nvarchar2(10) references Strategic_Business_Entity(code),
	gbu_code nvarchar2(10) references Global_Business_Unit(code),
	substance_codes nvarchar2_table_typ default nvarchar2_table_typ(),
	enpv number(20,10),
	npv number(20,10),
	peak_sales number(20,10),
	preferred_bay_no nvarchar2(100),
	pip_date date,
	pdco_date date,
	is_pdco_positive number(1) default 0 not null check(is_pdco_positive in (0,1)),
	is_waiver number(1) default 0 not null check(is_waiver in (0,1)),
	pip_activities nvarchar2(2000),
	termination_date date,
	termination_reason nvarchar2(500),
	is_collaboration number(1) default 0 not null check(is_collaboration in (0,1)),
	is_pip number(1) default 0 not null check(is_pip in (0,1)),
	is_portfolio number(1) default 0 not null check(is_portfolio in (0,1)),
	is_hpr number(1) default 0 not null check(is_hpr in (0,1)),
	is_regional number(1) default 0 not null check(is_regional in (0,1)),
	is_orphan_drug number(1) default 0 not null check(is_orphan_drug in (0,1)),
	is_direct_phase3 number(1) default 0 not null check(is_direct_phase3 in (0,1)),
	is_combined_phase2 number(1) default 0 not null check(is_combined_phase2 in (0,1)),
	is_gddop_informed number(1) default 0 not null check(is_gddop_informed in (0,1)),
	review_date date,
	url_development_plan nvarchar2(500),
	url_product_profile nvarchar2(500),
	sharedoc_id nvarchar2(20),
	sync_date date,
	is_syncing number(1) default 0 not null check(is_syncing in (0,1)),
	sync_id nvarchar2(20),
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date
) nested table substance_codes store as project_substance_codes_tab;

create index project_idx1 on Project(program_id);
create index project_idx2 on Project(code);

create table News (
	id nvarchar2(20) not null primary key,
	project_id nvarchar2(20) not null references Project(id) on delete cascade,
	category_code nvarchar2(10) not null references News_Category(code),
	text nvarchar2(2000) not null,
	event_date date not null,
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date
);

create index news_idx1 on News(project_id);

create table Funding (
	id nvarchar2(20) not null primary key,
	project_id nvarchar2(20) not null references Project(id) on delete cascade,
	year number(10) not null check(year > 0),
	amount number(20,10) not null,
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date,
	unique(project_id,year)
);

create index funding_idx1 on Funding(project_id);

create table License (
	id nvarchar2(20) not null primary key,
	project_id nvarchar2(20) not null references Project(id) on delete cascade,
	region_code nvarchar2(10) not null references Region(code),
	type_code nvarchar2(10) not null references License_Type(code),
	expiry_date date not null,
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date
);

create index License_idx1 on License(project_id);

create table Study (
	id nvarchar2(20) not null,
	project_id nvarchar2(20) not null references Project(id) on delete cascade,
	wbs_id nvarchar2(20),
	is_obligation number(1) default 0 not null check(is_obligation in (0,1)),
	is_probing number(1) default 0 not null check(is_probing in (0,1)),
	is_gpdc_approved number(1) default 0 not null check(is_gpdc_approved in (0,1)),
	plan_patients number(10),
	actual_patients number(10),
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date,
	primary key(id,project_id),
	unique(project_id,wbs_id)
);

create index Study_idx1 on Study(project_id);

create table project_audit (
    id nvarchar2(20) not null primary key,
    project_id nvarchar2(20) not null references project(id) on delete cascade,
    prj_update_user_id nvarchar2(20) not null,
    details xmltype not null,
    change_comment nvarchar2(200),
    sys_job_id nvarchar2(20) not null,
    create_user_id nvarchar2(20) default 'IPMS' not null,
    create_date date default sysdate not null
);

create index project_audit_idx1 on project_audit(project_id);
create index project_audit_idx2 on project_audit(sys_job_id);