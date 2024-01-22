create or replace trigger program_top_category_tr
before insert or update on program_top_category
for each row
begin
	if inserting then
		:new.create_date := sysdate;
	end if;
	:new.update_date := sysdate;
	:new.modify_date := sysdate;
	:new.code := replace(upper(:new.code),' ');
end;
/