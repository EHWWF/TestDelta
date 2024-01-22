create sequence plan_assumption_request_id_seq maxvalue 9999999999999999999 minvalue 1 cycle;

create table PLAN_ASSUMPTION_REQUEST (
	id nvarchar2(20) not null primary key,
	name nvarchar2(100) not null,
	forecast_no nvarchar2(100),
	termination_date date not null,
	status_code nvarchar2(10) default 'NEW' not null references Process_Status(code),
	status_date date default sysdate not null,
	sync_date date,
	is_syncing number(1) default 0 not null check(is_syncing in (0,1)),
    is_last number(1) default 0 not null check(is_last in (0,1)),
	sync_id nvarchar2(20),
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date
);

create index PLAN_ASSUMPTION_REQUEST_IDX1 on PLAN_ASSUMPTION_REQUEST(create_date);
create index PLAN_ASSUMPTION_REQUEST_IDX2 on PLAN_ASSUMPTION_REQUEST(is_last);