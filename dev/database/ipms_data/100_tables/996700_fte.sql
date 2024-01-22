create table fte (
	project_id nvarchar2(30) not null references project(id),
	study_id nvarchar2(30) not null,
	function_code nvarchar2(30) not null references function(code),
	year number not null,
	month number not null,
	fte number);
	
create index fte_idx1 on fte(project_id,study_id,function_code);