/**
 * Parses date from char based on current format settings.
 */
create or replace
function get_date(p_str in nvarchar2) return date as
	v_date date;
begin
	select nvl2(p_str,to_date(substr(p_str,1,cfg.date_len),cfg.date_fmt),null)
	into v_date
	from settings_vw cfg;

	return v_date;
end;
/