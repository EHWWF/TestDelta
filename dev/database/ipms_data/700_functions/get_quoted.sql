/**
 * Quotes provided text.
 * May double qoute contents if p_double=1.
 */
create or replace
function get_quoted(p_text in varchar2, p_double in number default 0) return varchar2 as
begin
	if p_double=1 then
		return ''''||nvl(replace(p_text, '''', ''''''),'')||'''';
	else
		return ''''||nvl(p_text, '')||'''';
	end if;
end;
/