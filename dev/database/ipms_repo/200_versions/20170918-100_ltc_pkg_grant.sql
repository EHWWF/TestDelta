create or replace package ltc_pkg as
	procedure update_all_ltc
	;
end;
/
grant execute on ipms_repo.ltc_pkg to ipms_data;