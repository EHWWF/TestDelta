create or replace
trigger function_tr
before insert on function
for each row
begin
	:new.code := to_number(:new.code);
end;
/