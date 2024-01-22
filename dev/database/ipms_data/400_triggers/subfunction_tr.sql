create or replace
trigger subfunction_tr
before insert on subfunction
for each row
begin
	if inserting then
		:new.code := to_number(:new.code);
	end if;
end;
/