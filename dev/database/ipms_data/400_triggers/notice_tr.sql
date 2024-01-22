create or replace
trigger notice_tr
before insert on notice
for each row
begin
	select notice_id_seq.nextval into :new.id from dual;
	:new.create_date := sysdate;
	:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
end;
/