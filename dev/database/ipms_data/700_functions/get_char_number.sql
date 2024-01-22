/**
 * Formats number into char based on current format settings.
 */
create or replace
function get_char_number(p_number in number) return nvarchar2 as
	v_char nvarchar2(200);
begin
	select nvl2(p_number,to_char(p_number,cfg.number_fmt,cfg.nlsparam),null)
	into v_char
	from settings_vw cfg;

	return v_char;
end;
/