create or replace function stringlist_to_table(p_list in varchar2)
  return nvarchar2_table_typ
as
  l_string       varchar2(32767) := p_list || '|';
  l_comma_index  pls_integer;
  l_index        pls_integer := 1;
  l_tab          nvarchar2_table_typ := nvarchar2_table_typ();
begin
	loop
			l_comma_index := instr(l_string, '|', l_index);
		exit when l_comma_index = 0;
			l_tab.extend;
			l_tab(l_tab.count) := substr(l_string, l_index, l_comma_index - l_index);
			l_index := l_comma_index + 1;
	end loop;
 return l_tab;
end;
/