/**
 * Generates text by replacing %n with provided parameters.
 * Indexing starts from 1.
 * May quote parameters according to these rules: p_quote=1 for simpe, p_qoute=2 for double.
 */
create or replace
function get_text(p_text in varchar2, p_params in varchar2_table_typ, p_quote in number default 0) return varchar2 as
	v_text varchar2(4000);
	v_param varchar2(4000);
begin
	v_text := p_text;

	for ndx in 1..p_params.count
	loop
		if p_quote=1 then
			v_param := get_quoted(p_params(ndx));
		elsif p_quote=2 then
			v_param := get_quoted(p_params(ndx), 1);
		else
			v_param := nvl(p_params(ndx), '');
		end if;

		v_text := replace(v_text, '%'||ndx, v_param);
	end loop;

	return v_text;
end;
/