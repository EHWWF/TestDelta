create or replace
trigger target_product_profile_tr
for insert or update on target_product_profile
compound trigger
before each row is
begin
	if inserting then
		if :new.id is null then
			select tpp_id_seq.nextval into :new.id from dual;
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