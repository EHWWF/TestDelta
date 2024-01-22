create or replace
trigger ltcp_tr 
before insert or update on ltc_plan 
for each row 
begin
	if inserting then
		select ltcp_id_seq.nextval into :new.id from dual;
		:new.create_date := sysdate;
	else
		:new.update_date := sysdate;	
	end if;
end;
/