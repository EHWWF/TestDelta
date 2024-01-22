create or replace
trigger latest_estimate_tr
before insert or update on latest_estimate
for each row
begin
	if inserting then
		select le_id_seq.nextval into :new.id from dual;
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
	end if;
	if updating then
		if :new.is_upserted is null and :old.is_upserted is null then
			:new.update_date := sysdate;
			:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
		end if;
	end if;
end;
/