create or replace
trigger ltcv_tr 
before insert on ltc_value 
for each row begin
	select ltcv_id_seq.nextval into :new.id from dual;
end;
/