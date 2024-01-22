create or replace
trigger program_tr
before insert or update on program
for each row
begin
	if inserting then
		if :new.id is null then
			select program_id_seq.nextval into :new.id from dual;
		end if;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		:new.create_date := sysdate;
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
end;
/
insert into program (name,code) values('RESERVED-PT-D2-PRJ','RESERVED-PT-D2-PRJ');
insert into program (name,code) values('RESERVED-PT-D3-TR','RESERVED-PT-D3-TR');
insert into program (name,code) values('RESERVED-PT-RS','RESERVED-PT-RS');
insert into program (name,code) values('RESERVED-PT-LG','RESERVED-PT-LG');
insert into program (name,code) values('RESERVED-PT-LO','RESERVED-PT-LO');
insert into program (name,code) values('RESERVED-PT-CO','RESERVED-PT-CO');
insert into program (name,code) values('RESERVED-PT-UNT','RESERVED-PT-UNT');
commit;