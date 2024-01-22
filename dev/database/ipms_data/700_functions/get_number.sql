/**
 * Parses number from char based on current format settings.
 */
create or replace
function get_number(p_str in nvarchar2) return number as
	v_number number;
begin
	select nvl2(p_str,to_number(p_str,cfg.number_fmt,cfg.nlsparam),null)
	into v_number
	from settings_vw cfg;

	return v_number;
end;
/