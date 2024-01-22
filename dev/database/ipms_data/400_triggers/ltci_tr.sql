create or replace
trigger ltci_tr
before insert on ltc_instance
for each row
begin 
	select ltci_id_seq.nextval into :new.id from dual;
	:new.create_date := sysdate;
	:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
end;
/