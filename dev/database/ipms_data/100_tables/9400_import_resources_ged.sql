create table import_resources_ged (
	reference_id nvarchar2(20) not null,
	import_id nvarchar2(20) not null references import(id) on delete cascade,
	project_id nvarchar2(20) not null references project(id) on delete cascade,
	study_id nvarchar2(20),
	subfunction_code nvarchar2(10),
	method_code nvarchar2(10) not null references calculation_method(code),
	type_code nvarchar2(10) not null references resources_type(code),
	year number(10) not null,
	month number(10) not null,
	demand number(20,10),
	status_code nvarchar2(10) default 'NEW' not null references import_status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(reference_id,project_id,import_id,type_code));

create index import_resources_ged_idx1 on import_resources_ged(import_id);
create index import_resources_ged_idx2 on import_resources_ged(project_id);