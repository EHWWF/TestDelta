create or replace trigger program_top_subcategory_tr
for insert or update on program_top_subcategory
compound trigger

before each row is
begin
	if inserting then
		:new.create_date := sysdate;
	end if;
	:new.update_date := sysdate;
	:new.modify_date := sysdate;
	:new.code := replace(upper(:new.code),' ');
end before each row;

--after each row is
after statement is
begin
	if inserting then
		program_top_pkg.add_missing_sub_all(null);--:new.code);
	end if;
--end after each row;
end after statement;
end;
/