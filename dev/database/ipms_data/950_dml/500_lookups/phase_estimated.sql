prompt ---->
prompt ---->
prompt 
prompt ---->START    phase_estimated: No DELETE, only INSERT and UPDATE
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
merge into phase_estimated dest
using (
	select
		code,
		max(decode (seq, 1, name)) name,
		max(decode (seq, 1, is_active)) is_active,
		max(decode (seq, 1, ordering)) ordering,
		sum(decode (seq, 1, srccnt, dstcnt)) iud
	from (
		select
			code, name, is_active, ordering,
			srccnt, dstcnt,row_number() over (partition by code order by dstcnt nulls last) seq
		from (
			select
				code, name, is_active, ordering
				,count (src) srccnt, count (dst) dstcnt
			from (
				select code, name, is_active, ordering,to_number(null) src, 2 dst from phase_estimated
				union all
				select to_nchar(code) code, to_nchar(name) name, is_active, ordering,1 src, to_number (null) dst from 
				(--If changes are needed then change only this part below:
				select '2A' code,'prePhase IIa' name, 1 is_active, 20 ordering from dual union all
				select '1','prePhase I', 1, 10 from dual union all
				select '2B','prePhase IIb', 1, 30 from dual union all
				select '3' ,'prePhase III', 1, 50 from dual union all
				select 'PR','preRegistration', 1, 60 from dual union all
				select 'NA','n/a', 1, 80 from dual
				)--but not below :)
			)
			group by code, name, is_active, ordering
			having count (src) <> count (dst)
		)
	)
	group by code
) diff
on (dest.code = diff.code)
when matched
then
	update set
		dest.name = diff.name
		,dest.is_active = diff.is_active
		,dest.ordering = diff.ordering -- delete where (diff.iud = 0) --No DELETE, only INSERT and UPDATE
when not matched
then
	insert (code, name, is_active, ordering)
	values (diff.code, diff.name, diff.is_active, diff.ordering);
commit;
prompt ---->END    phase_estimated
prompt ---->
prompt ---->