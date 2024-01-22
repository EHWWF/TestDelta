begin
	for rr in (
		select archive_table_name,table_name from dba_flashback_archive_tables order by length(table_name)
		)
	loop
		begin
			execute immediate 'create or replace synonym '||rr.table_name||'_HIS for '||rr.archive_table_name;
		exception when others then
			dbms_output.put_line(rr.table_name||'-->ERR-->'||sqlerrm);
		end;
	end loop;
end;
/