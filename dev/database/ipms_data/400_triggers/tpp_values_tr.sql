create or replace
trigger tpp_values_tr
for insert or update on tpp_values
compound trigger
before each row is
begin
	if inserting then
		if :new.id is null then
			select tpp_values_id_seq.nextval into :new.id from dual;
		end if;
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
end before each row;
end;
/