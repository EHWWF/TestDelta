create or replace view combase_substance_combi_vw as
select
	to_nchar(bys_no) as combination_code,
	regexp_substr(susum_no, '[^-]+', 1, level) as substance_code,
	decode(status,'ACTIVE',1,0) as is_active,
	modify_date
from bdr_bys_susum@combase_db bdr
connect by
	instr(susum_no, '-', 1, level - 1) > 0
	and prior bys_no=bys_no and prior susum_no=susum_no
	and prior dbms_random.value@combase_db is not null;