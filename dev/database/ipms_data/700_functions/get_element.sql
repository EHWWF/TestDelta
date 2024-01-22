/**
 * Generates XML tag with provided content.
 * Escapes characters.
 */
create or replace
function get_element(p_tag in nvarchar2, p_data in nvarchar2, p_escape in number default 1) return nvarchar2 as
	v_element nvarchar2(4000);
begin
	select
		nvl2(p_tag, nvl2(p_data, '<'||p_tag||'>'||decode(p_escape, 1, utl_i18n.escape_reference(p_data), p_data)||'</'||p_tag||'>', ''), '')
	into v_element
	from dual;

	return v_element;
end;
/