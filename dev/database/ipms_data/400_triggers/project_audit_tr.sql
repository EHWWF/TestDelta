create or replace
trigger project_audit_tr
before insert on project_audit
for each row
begin
	select project_audit_id_seq.nextval into :new.id from dual;
	:new.create_date := nvl(:new.create_date,sysdate);
	:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
end;
/