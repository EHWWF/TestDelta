create or replace function merge_nvarchar2_tables(table_arr in nvarchar2_table_arr_typ) return nvarchar2_table_typ is
	all_tab nvarchar2_table_typ:=nvarchar2_table_typ();
begin
	if table_arr.count >0 then
		for j in table_arr.first .. table_arr.last loop
			all_tab :=all_tab multiset union table_arr(j);
		end loop;
	end if;
	return all_tab;
end;
/