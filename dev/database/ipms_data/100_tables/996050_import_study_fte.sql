create table import_study_fte (
	import_id nvarchar2(30) not null,
	project_id nvarchar2(30) not null,
	study_id nvarchar2(30) not null,
	function_id nvarchar2(30) not null,
	year number not null,
	month number not null,
	fte number);