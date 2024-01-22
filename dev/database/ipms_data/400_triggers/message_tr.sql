create or replace
trigger message_tr
before insert or update on message
for each row
begin
	if inserting then
		:new.request_date := sysdate;
		:new.request_user_id := nvl(:new.request_user_id,'TRIGGER');
		if :new.id is null then
			select message_id_seq.nextval into :new.id from dual;
		end if;
		begin
			:new.transaction_id:=ba_log_pkg.get_transaction_id;
		exception when others then
			:new.transaction_id:=null;
		end;
	end if;	
	if updating then
		begin
			ba_log_pkg.put_transaction_id(nvl(:old.transaction_id,:new.transaction_id));
		exception when others then
			null;
		end;
	end if;
end;
/