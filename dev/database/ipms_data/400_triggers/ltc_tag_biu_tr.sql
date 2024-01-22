create or replace trigger ltc_tag_biu_tr
before insert or update on ltc_tag for each row
begin
	if inserting then
		if :new.id is null then
			select ltc_tag_id_seq.nextval into :new.id from dual;
		end if;
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		:new.update_date := :new.create_date;
		:new.update_user_id := :new.create_user_id;
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
end;
/