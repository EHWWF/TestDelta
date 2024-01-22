drop materialized view export_pts_vw
;
create materialized view export_pts_vw as
select 
	nvl(phase_code,'100') phase_code,
	case phase_code
		when '1' then prob1
		when '2' then prob2
		when '34' then prob34
		when '5' then prob5
		when '6' then prob6
		else round(100 * (prob1/100) * (prob2/100) * (prob34/100) * (prob5/100) * (prob6/100))
	end probability,
	project_id,
	project_code
from (
	select 
		sum(case when phase_code = '1' then probability else 0 end) prob1,
		sum(case when phase_code = '2' then probability else 0 end) prob2,
		sum(case when phase_code = '34' then probability else 0 end) prob34,
		sum(case when phase_code = '5' then probability else 0 end) prob5,
		sum(case when phase_code = '6' then probability else 0 end) prob6,
		project_id,
		project_code
	from
	(
		select
			cp.phase_code,
			cp.probability,
			prj.id as project_id,
			prj.code as project_code
		from costs_probability cp
		join project prj on prj.id=cp.project_id
		where cp.scope_code='INT'
		  and prj.pidt_release_date is not null
		  and prj.program_id<>'RBIN'
		  and cp.phase_code in ('1', '2', '34', '5', '6')
		  and prj.area_code in ('PRE-POT','POST-POT')--PROMIS-730,costs_probability applies only for DEV projects!
	)
	group by project_id, project_code
)
cross join 
	(
		select '1' phase_code from dual union all
		select '2' from dual union all
		select '34' from dual union all
		select '5' from dual union all
		select '6' from dual union all
		select null from dual
	) phases
;
grant select on export_pts_vw to mxcbi;
grant select on export_pts_vw to mycsd;