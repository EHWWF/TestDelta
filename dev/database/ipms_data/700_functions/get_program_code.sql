create or replace function get_program_code(p_program_id in program.id%type) return program.code%type deterministic is
	l_res program.code%type;
begin
	select code into l_res from program where id=p_program_id;
	return l_res;
end;
/
