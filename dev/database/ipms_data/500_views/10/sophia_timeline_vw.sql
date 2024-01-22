create or replace view sophia_timeline_vw as
select
	to_nchar(tl.project_id) as project_id,
	to_nchar(decode(tl.study_id,'0',null,tl.study_id)) as study_id,
	to_nchar(decode(tl.study_element_id,'0',null,tl.study_element_id)) as study_element_id,
	typ.code as type_code,
	decode(typ.code,'PLAN',tl.plan_start_date,'ACT',tl.act_start_date,null) as start_date,
	decode(typ.code,'PLAN',tl.plan_finish_date,'ACT',tl.act_finish_date,null) as finish_date,
	typ.code||rownum as scd2_key,
	1 as current_flag,
	sysdate-365 as valid_from,
	sysdate+365 as valid_to
from timeline@sophia_db tl
cross join timerow_type typ;

drop table sophia_timeline_tmp;

create global temporary table sophia_timeline_tmp
on commit delete rows
as (select * from sophia_timeline_vw where 1=0);

create index sophia_timeline_tmp_idx1 on sophia_timeline_tmp(project_id);