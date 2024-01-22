create table bal_status (
	code nvarchar2(20) constraint bal_status_code_cnn not null primary key,
	name nvarchar2(100) constraint bal_status_name_cnn not null,
	is_active number(1) default 1 constraint bal_status_is_active_cnn not null constraint bal_status_active_chk check(is_active in (0,1)));