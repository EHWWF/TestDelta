create or replace
trigger tpp_subcategory_tr
before insert or update on tpp_subcategory
for each row
begin
	--This is PK, so, code must be Upper case and without "spacebar"
	:new.code := replace(upper(:new.code),' ');
end;
/