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