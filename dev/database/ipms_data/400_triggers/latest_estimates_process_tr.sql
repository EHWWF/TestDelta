create or replace
trigger latest_estimates_process_tr
for insert or update on latest_estimates_process
compound trigger
before each row is
begin
	if inserting then
		select le_process_id_seq.nextval into :new.id from dual;
		:new.create_date := sysdate;
		:new.year := extract(year from sysdate);
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
	if updating and :old.status_code<>:new.status_code then
		:new.status_date := sysdate;
	end if;
	if inserting or updating then
		if :new.cy_det_prefill_code<>'LE' then
			:new.cy_det_prefill_lep_id := null;
		end if;
		if :new.ny_det_prefill_code<>'LE' then
			:new.ny_det_prefill_lep_id := null;
		end if;
	end if;
end before each row;
end;
/