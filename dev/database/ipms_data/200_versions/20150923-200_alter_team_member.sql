create or replace
trigger team_member_project_tr
before insert on team_member_project
for each row
begin
	if :new.id is null then
		select team_member_project_id_seq.nextval into :new.id from dual;
	end if;
end;
/
set serveroutput on
begin
for rr in (
select
	null,
	prj.column_value as project_id,
	tm.id as team_member_id
from team_member tm
cross join table(tm.project_ids) prj)
loop
  begin
    
    insert into team_member_project (id,project_id,team_member_id) values(null,rr.project_id,rr.team_member_id);
    commit;
	 dbms_output.put_line(rr.team_member_id||'->'||rr.project_id);
  exception when dup_val_on_index then null; 
  when others then
	 dbms_output.put_line(rr.team_member_id||'->'||rr.project_id||';ERROR='||sqlerrm);  
  end;
end loop;
exception when others then 
dbms_output.put_line(sqlerrm);
end;