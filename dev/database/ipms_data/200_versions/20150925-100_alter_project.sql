create or replace
trigger project_substance_code_tr
before insert on project_substance_code
for each row
begin
	if :new.id is null then
		select project_substance_code_id_seq.nextval into :new.id from dual;
	end if;
end;
/
set serveroutput on
begin
for rr in (
select 
	null,
	prj.id as project_id,
	sb.column_value substance_code
from project prj
cross join table(prj.substance_codes) sb)
loop
  begin
    insert into project_substance_code (id,project_id,substance_code) values(null,rr.project_id,rr.substance_code);
    commit;
    dbms_output.put_line(rr.substance_code||'-OK->'||rr.project_id);
  exception when dup_val_on_index then 
    dbms_output.put_line(rr.substance_code||'-EXISTS->'||rr.project_id);
	when others then
	    dbms_output.put_line(rr.substance_code||'-->'||rr.project_id||';ERROR='||SQLERRM);
  end;
end loop;
exception when others then 
dbms_output.put_line(sqlerrm);
end;