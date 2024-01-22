create or replace
trigger let_tr
before insert on latest_estimates_tag
for each row
begin
		select let_id_seq.nextval into :new.id from dual;
		:new.create_date := sysdate;
		:new.create_user_id := user_pkg.get_current_user;
end;
/
alter table latest_estimates_process add (let_id nvarchar2(30), constraint lep_let_fk foreign key (let_id) references latest_estimates_tag(id) on delete cascade enable);
declare 
	l_tag_id nvarchar2(30);
begin
	insert into latest_estimates_tag (name) values ('ProMIS 1') returning id into l_tag_id;
	update latest_estimates_process set let_id=l_tag_id;
	commit;
end;
/
alter table latest_estimates_process drop column tag;