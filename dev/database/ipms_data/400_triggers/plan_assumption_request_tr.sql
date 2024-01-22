create or replace
trigger plan_assumption_request_tr
for insert or update or delete on plan_assumption_request
compound trigger

before each row is
begin
	if inserting then
		select plan_assumption_request_id_seq.nextval into :new.id from dual;
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
	if nvl(:old.status_code, '-1') != nvl(:new.status_code, '-1') then
	  :new.status_date := sysdate;
	  if :new.status_code = 'RUN' then
			update project
			set comment_previous_fc = current_comment
			where planning_enabled = 'green'
			and current_comment is not null;  
	  end if;
	end if;
end before each row;

after statement is
begin
	if inserting then
		update plan_assumption_request set is_last = 0 where is_last = 1;
	end if;
	if inserting or deleting then
		update plan_assumption_request set is_last = 1 where id = (
			select id from (select id from plan_assumption_request order by create_date desc) where rownum = 1
		);
	end if;
end after statement;
end;
/