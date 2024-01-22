create or replace
trigger log_tr
before insert on log
for each row
begin
	:new.user_id := nvl(:new.user_id,'TRIGGER');
	select log_id_seq.nextval into :new.id from dual;
end;
/