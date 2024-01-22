/**
 * Calculates boolean OR on bit level.
 */
create or replace function bitor(x in number, y in number) return number as
begin
	return (x + y - bitand(x, y));
end;
/