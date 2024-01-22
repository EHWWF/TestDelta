prompt ---->
prompt ---->
prompt
prompt ---->START    phase_planning_type
prompt
prompt ---->
prompt ---->
SET SCAN OFF;
merge into phase_planning_type dst
using (
	select 'c23' code,'combined Phase II/III' name, '1' is_active from dual
		union all
	select 'c13','combined Phase I/III','1' from dual
		union all
	select 'c12','combined Phase I/II','1' from dual
		union all
	select 'c2a2b','combined Phase IIa/IIb','1' from dual
		union all
	select 's1','skipped Phase I','1' from dual
		union all
	select 's2','skipped Phase II','1' from dual
		union all
	select 's3','skipped Phase III','1' from dual
) src
on (dst.code=src.code)
when matched then
	update set dst.name=src.name, dst.is_active=src.is_active
when not matched then
	insert(code,name,is_active) values (src.code,src.name,src.is_active);
commit;
prompt ---->END    phase_planning_type
prompt ---->
prompt ---->