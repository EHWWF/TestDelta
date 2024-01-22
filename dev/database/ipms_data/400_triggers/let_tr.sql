create or replace
trigger let_tr
before insert on latest_estimates_tag
for each row
begin
	select let_id_seq.nextval into :new.id from dual;
	:new.create_date := sysdate;
	:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
	:new.year := extract(year from sysdate);
end;
/