prompt 
prompt ----> ERROR, FEHLER:  
prompt ----> following update script must be rather run manually
prompt
--declare
--v_parent_id number;
--v_prj_id nvarchar2(22):='null';
--begin
--for rr in (
--	select * from project_audit
--	where record_type='IPMS' 
--	--and project_id in (select id from project where program_id='29') 
--	order by project_id,to_number(id)
--) loop	
--	if nvl(v_parent_id, rr.id) != rr.id and v_prj_id = rr.project_id then
--		begin
--			update project_audit set parent_id=v_parent_id where id=rr.id and parent_id is null;
--			commit;
--		exception when others then null; end;
--	end if;
--	v_prj_id := rr.project_id;
--	v_parent_id := rr.id;
--end loop;
--end;
----update project_audit set parent_id = null where parent_id is not null;