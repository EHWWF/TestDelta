create table import_costs_fps (
	reference_id nvarchar2(20) not null,
	import_id nvarchar2(20) not null references import(id) on delete cascade,
	project_id nvarchar2(20) not null references project(id) on delete cascade,
	study_id nvarchar2(20),
	function_code nvarchar2(10),
	subfunction_code nvarchar2(10),
	type_code nvarchar2(10) not null references costs_type(code),
	subtype_code nvarchar2(10) references costs_subtype(code),
	scope_code nvarchar2(10) not null references costs_scope(code),
	method_code nvarchar2(10) not null references calculation_method(code),
	year number(10) not null,
	month number(10) not null,
	cost number(20,10) not null,
	committed_state	nvarchar2(120),
	status_code nvarchar2(10) default 'NEW' not null references import_status(code),
	status_description nvarchar2(500),
	create_date date default sysdate not null,
	primary key(reference_id,project_id,import_id,type_code));

create index import_costs_fps_idx1 on import_costs_fps(import_id);
create index import_costs_fps_idx2 on import_costs_fps(project_id);