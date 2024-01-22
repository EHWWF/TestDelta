set serveroutput on
begin
for rr in (
      select insertchildxml(
          t_xml
          , '/PROJECT'
          , '@IS_ACTIVE'
          , is_active
          ) t_xml2, aud_id
          from (
     select aud.id aud_id,aud.t_xml,aud.project_id aud_pr_id, decode(prj.is_active,1,'ACTIVE','INACTIVE') is_active 
	  from (
		  select id,project_id, details as t_xml, create_date,
		  row_number() over(partition by project_id order by create_date desc) as rank 
		  from project_audit 
		  where record_type='IPMS'
		  and extractvalue(details, '/PROJECT/@IS_ACTIVE') is null
		  ) aud 
		  join project prj on (aud.project_id=prj.id)
		  where aud.rank=1
     )
    )
loop
  update project_audit set details=rr.t_xml2 where id=rr.aud_id;
  commit;
  dbms_output.put_line('XML.updated.id='||rr.aud_id);
end loop;
end;
/