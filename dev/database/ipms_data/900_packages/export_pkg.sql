create or replace package export_pkg as

	/**
	 * Starts global export of all data.
	 */
	procedure launch_all;

end;
/
create or replace package body export_pkg as

	/*************************************************************************/
	procedure launch_all as
		v_where nvarchar2(222):='export_pkg.launch_all';
	begin
		for mv in (select mview_name from user_mviews where mview_name like 'EXPORT%' order by mview_name) 
		loop
			begin
				dbms_mview.refresh(mv.mview_name,'c');
				--log_pkg.log(v_where, mv.mview_name, 'Done.');
			exception when others then
				notice_pkg.catch(v_where, mv.mview_name);
			end;
		end loop;
	end;

end;
/