alter table phase_duration add create_date date default sysdate constraint phase_dura_create_date_cnn not null;
alter table phase_duration add update_date date default sysdate constraint phase_dura_update_date_cnn not null;
create or replace trigger phase_duration_tr
before insert or update on phase_duration
for each row
begin
	if inserting then
		select phase_duration_id_seq.nextval into :new.id from dual;
		:new.create_date := sysdate;
		:new.update_date := :new.create_date;
	end if;
	if updating then
		:new.update_date := sysdate;
	end if;
end;
/
update phase_duration set duration=23 where phase_code=(select code from phase where name='Phase I' and is_Active=1) and duration<>23;
update phase_duration set duration=24 where phase_code=(select code from phase where name='Phase IIa' and is_Active=1) and duration<>24;
update phase_duration set duration=0 where phase_code=(select code from phase where name='PoC-D6' and is_Active=1) and duration<>0;
commit;