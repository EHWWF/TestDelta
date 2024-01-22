/**
 * Formats date into char based on current format settings.
 */
create or replace
function get_char_date(p_date in date) return nvarchar2 as
	v_char nvarchar2(200);
begin
	select nvl2(p_date,to_char(p_date,cfg.date_fmt),null)
	into v_char
	from settings_vw cfg;

	return v_char;
end;
/