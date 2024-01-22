DECLARE
	pk_name nvarchar2(30);
BEGIN
 select index_name 
 into pk_name
 from (
 select * from user_ind_columns where table_name='TEAM_MEMBER' and column_name='EMPLOYEE_CODE'
 union all
 select * from user_ind_columns where table_name='TEAM_MEMBER' and column_name='PROGRAM_ID'
 ) where index_name in ( select index_name from user_indexes where table_name='TEAM_MEMBER' and uniqueness='UNIQUE') 
 group by index_name having count(1)=2
 ;
 EXECUTE IMMEDIATE 'ALTER TABLE team_member DROP CONSTRAINT '||pk_name;
END;
/

create or replace function get_program_code(p_program_id in program.id%type) return program.code%type deterministic is
	l_res program.code%type;
begin
	select code into l_res from program where id=p_program_id;
	return l_res;
end;
/
create unique index team_member_idx2 on team_member (case when get_program_code(program_id)='RESERVED-PT-D2-PRJ' then id else program_id||'|'||employee_code end);