create sequence LE_process_id_seq maxvalue 9999999999999999999 minvalue 1 cycle;
create sequence LE_project_id_seq maxvalue 9999999999999999999 minvalue 1 cycle;
create sequence LE_Id_SEQ maxvalue 9999999999999999999 minvalue 1 cycle;

create table Latest_Estimates_Process (
	id nvarchar2(20) not null primary key,
	name nvarchar2(100) not null,
	comments nvarchar2(500),
	year number(10) not null,
	is_next_year number(1) default 0 not null check(is_next_year in (0,1)),
	prefill_code nvarchar2(10) references Prefill_Type(code),
	cy_det_prefill_code nvarchar2(10) references Prefill_Type(code),
	ny_det_prefill_code nvarchar2(10) references Prefill_Type(code),
	cy_det_prefill_lep_id nvarchar2(20) references Latest_Estimates_Process(id) on delete set null,
	ny_det_prefill_lep_id nvarchar2(20) references Latest_Estimates_Process(id) on delete set null,
	cy_prob_prefill_code nvarchar2(10) references Prefill_Type(code),
	ny_prob_prefill_code nvarchar2(10) references Prefill_Type(code),
	cy_prob_prefill_lep_id nvarchar2(20) references Latest_Estimates_Process(id) on delete set null,
	ny_prob_prefill_lep_id nvarchar2(20) references Latest_Estimates_Process(id) on delete set null,
	is_forecast_prob number(1) default 0 not null check(is_forecast_prob in (0,1)),
	is_prefill_prob number(1) default 0 not null check(is_prefill_prob in (0,1)),
	termination_date date not null,
	status_code nvarchar2(10) default 'NEW' not null references Process_Status(code),
	status_date date default sysdate not null,
	sync_date date,
	is_last number(1) default 0 not null check(is_last in (0,1)),
	is_syncing number(1) default 0 not null check(is_syncing in (0,1)),
	sync_id nvarchar2(20),
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date,
	project_ids nvarchar2_table_typ default nvarchar2_table_typ()
) nested table project_ids store as lep_project_ids_tab;

create table Latest_Estimate (
	id nvarchar2(20) not null primary key,
	process_id nvarchar2(20) not null references latest_estimates_process(id) on delete cascade,
	project_id nvarchar2(20) not null references project(id) on delete cascade,
	program_id nvarchar2(10) not null references program(id) on delete cascade,
	study_id nvarchar2(20),
	study_status_code nvarchar2(10) references Study_Status(code),
	function_code nvarchar2(10) references Function(code),
	development_phase_code nvarchar2(10) references Development_Phase(code),
	subtype_code nvarchar2(10) references Costs_SubType(code),
	estimate_det_curr_year number(20,10),
	estimate_det_next_year number(20,10),
	estimate_prob_curr_year number(20,10),
	estimate_prob_next_year number(20,10),
	comments_curr_year nvarchar2(500),
	comments_next_year nvarchar2(500),
	details xmltype,
	start_date date not null,
	finish_date date not null,
	pot_date date,
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date,
	is_upserted number(1) check(is_upserted in (0,1)),
	is_prefilled number(1) default 0 not null check(is_prefilled in (0,1)),
	is_prefilled_cyd number(1) default 0 not null check(is_prefilled_cyd in (0,1)),
	is_prefilled_nyd number(1) default 0 not null check(is_prefilled_nyd in (0,1)),
	is_prefilled_cyp number(1) default 0 not null check(is_prefilled_cyp in (0,1)),
	is_prefilled_nyp number(1) default 0 not null check(is_prefilled_nyp in (0,1)),
	is_placeholder number(1) check(is_placeholder in (0,1))
);

create index LE_idx1 on Latest_Estimate(project_id);
create index LE_Process_idx1 on Latest_Estimates_Process(is_last);
create index LE_Process_idx2 on Latest_Estimates_Process(create_date);

create table latest_estimates_project
(id nvarchar2(20) not null enable, 
process_id nvarchar2(20) not null enable, 
project_id nvarchar2(30) not null enable, 
primary key (id),
unique (process_id, project_id),
foreign key (process_id)
references latest_estimates_process (id) on delete cascade enable, 
foreign key (project_id)
references project (id) on delete cascade enable
) ;
create index le_project_idx1 on latest_estimates_project (process_id) ;
create index le_project_idx2 on latest_estimates_project (project_id) ; 
create or replace trigger latest_estimates_project_tr
before insert on latest_estimates_project
for each row
begin
	if :new.id is null then
		select le_project_id_seq.nextval into :new.id from dual;
	end if;
end;
/