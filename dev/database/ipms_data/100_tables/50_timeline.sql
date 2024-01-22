create table Timeline (
	id nvarchar2(20) not null primary key,
	code nvarchar2(20),
	name nvarchar2(100),
	start_date date,
	finish_date date,
	comments nvarchar2(500),
	project_id nvarchar2(20) not null references Project(id) on delete cascade,
	type_code nvarchar2(10) not null references Timeline_Type(code),
	reference_id nvarchar2(20),
	create_user_id nvarchar2(20) default 'IPMS' not null,
	update_user_id nvarchar2(20),
	create_date date default sysdate not null,
	update_date date,
	sync_date date,
	is_syncing number(1) default 0 not null check(is_syncing in (0,1)),
	sync_id nvarchar2(20),
	details xmltype);

create index timeline_idx1 on Timeline(project_id);
create index timeline_indx2 on Timeline(type_code);

create table Generic_Timeline (
	project_id nvarchar2(20) not null references Project(id),
	milestone_code nvarchar2(10) not null references Milestone(code),
	generic_date date,
	calculation_date date default sysdate not null,
	primary key(project_id,milestone_code)
);
