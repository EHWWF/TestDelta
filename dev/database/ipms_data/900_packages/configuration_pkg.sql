create or replace package configuration_pkg as

	/**
	 * Get configuration parameter value in native datatype
	 * Throws no_data_found exception if value is not found
	 */
	function get_config_value(p_code in configuration.code%type) return configuration.value%type;

	/**
	 * Get configuration parameter value converted to "number" datatype
	 * Throws no_data_found exception if value is not found
	 * Throws invalid_number exception when parameter value can not be converted to number
	 */
	function get_config_number(p_code in configuration.code%type) return number;

	/**
	changing  code list to name list
	*/
	function get_names_for_codes(p_code_list in varchar2, p_table_name in varchar2 default null) return varchar2;
	function stringlist_to_table(p_list in varchar2, p_separator in varchar2) return nvarchar2_table_typ;

end;
/
create or replace package body configuration_pkg as

	/*************************************************************************/
	function get_config_value(p_code in configuration.code%type) return configuration.value%type as
		v_res configuration.value%type;
	begin

		select c.value into v_res from configuration c where c.code=p_code;

		return v_res;
	end get_config_value;


	/*************************************************************************/
	function get_config_number(p_code in configuration.code%type) return number as
		v_res number;
	begin

		select to_number(c.value) into v_res from configuration c where c.code=p_code;

		return v_res;
	end get_config_number;

	/*************************************************************************/
	function get_names_for_codes(p_code_list in varchar2, p_table_name in varchar2 default null) return varchar2
	as
		v_string varchar2(32767) := replace(p_code_list,' ') || ';';
		v_comma_index pls_integer;
		v_index pls_integer := 1;
		v_result varchar2(32767);
		v_code varchar2(99);
		v_name varchar2(999);
	begin
		loop
			v_comma_index := instr(v_string, ';', v_index);
		exit when v_comma_index = 0;
			v_code := substr(v_string, v_index, v_comma_index - v_index);
			v_index := v_comma_index + 1;
				if v_code is not null then
					begin
						select name||'; ' into v_name from project_modality where code = v_code;
					exception when others then 
						v_name := null;
					end;
				end if;
				v_result := v_result||v_name;
				v_name := null;
		end loop;

		return substr(v_result,1,4000);

	exception when others then 
		return null;
	end;

	/*************************************************************************/
	function stringlist_to_table(p_list in varchar2, p_separator in varchar2) return nvarchar2_table_typ
	as
		l_string varchar2(32767) := p_list || p_separator;
		l_comma_index pls_integer;
		l_index pls_integer := 1;
		l_tab nvarchar2_table_typ := nvarchar2_table_typ();
	begin
		loop
			l_comma_index := instr(l_string, p_separator, l_index);
		exit when l_comma_index = 0;
			l_tab.extend;
			l_tab(l_tab.count) := substr(l_string, l_index, l_comma_index - l_index);
			l_index := l_comma_index + 1;
		end loop;

		return l_tab;

	exception when others then 
		return null;
	end;
	
end;
/