create or replace view project_gt_vw as
with with_milestone_date as (
select *
from (--3
select * 
from (--cross
select id, milestone_code, nvl(max(decode(fcnt,1,milestone_date)), max(decode(gcnt,1,milestone_date))) milestone_date
from (--2
select id, milestone_code, milestone_date,count(g) gcnt,count(f) fcnt
from (--1
select id, milestone_code, milestone_date, 1 g, to_number(null) f
from (
select
	p.id
	,to_char(gt.milestone_code) milestone_code
	,nvl2(gt.generic_date,to_char(gt.generic_date,'DD-Mon-YYYY')||' G',gt.generic_date) milestone_date
from project p
join generic_timeline gt on (gt.project_id = p.id)
where p.gt_timeline_type in ('CUR','RAW')
and gt.milestone_code in ('D2','D3','D4','M4C','PoC','D6','D7','D8','M9','D5')
)
union all
select id, milestone_code,milestone_date, to_number(null) g, 2 f
from (
select
	p.id
	,tm.milestone_code
	,nvl(to_char(tm.actual_date,'DD-Mon-YYYY'),to_char(tm.plan_date,'DD-Mon-YYYY')) milestone_date
from project p
join milestone_vw tm on (tm.timeline_type_code=p.gt_timeline_type and tm.project_id = p.id)
where p.gt_timeline_type in ('CUR','RAW')
and tm.milestone_code in ('D2','D3','D4','M4C','PoC','D6','D7','D8','M9','D5')
)
)--1
group by id,milestone_code,milestone_date
)--2
group by id,milestone_code
)--cross
cross join (select 1 from dual)
)--3
PIVOT (listagg(milestone_date, ', ') WITHIN GROUP (ORDER BY milestone_date) FOR milestone_code IN ('D2','D3','D4','M4C','PoC','D6','D7','D8','M9','D5'))
)--with
select
p.code p_id
,p.name p_name
,sbe.name sbe_name
,st.name ds_type
,ph.name phase_name
,wmd."'D2'"
,wmd."'D3'"
,wmd."'D4'"
,wmd."'M4C'"
,wmd."'PoC'"
,wmd."'D6'"
,wmd."'D7'"
,wmd."'D8'"
,wmd."'M9'"
,wmd."'D5'"
from with_milestone_date wmd
join project p on (wmd.id=p.id)
left outer join phase ph on ph.code = p.phase_code
left outer join strategic_business_entity sbe on sbe.code = p.sbe_code
left outer join substance_type st on st.code = p.substance_type_code
order by p.name;