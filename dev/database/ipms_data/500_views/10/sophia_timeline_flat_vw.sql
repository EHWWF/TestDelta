create or replace view sophia_timeline_flat_vw as
select
	to_nchar(tl.project_id) as project_id,
	--cast(nvl(prj.id,'0') as nvarchar2(20)) as promis_project_id,
	to_nchar(decode(tl.study_id,'0',null,tl.study_id)) as study_id,
	to_nchar(decode(tl.study_element_id,'0',null,tl.study_element_id)) as study_element_id,
	tl.plan_start_date,
	tl.act_start_date,
	tl.plan_finish_date,
	tl.act_finish_date,
	to_char(rownum) as scd2_key,
	1 as current_flag,
	sysdate-365 as valid_from,
	sysdate+365 as valid_to
from timeline@sophia_db tl
--left join project prj on (prj.code=to_char(tl.project_id) and nvl(prj.area_code,'#')<>'D1')
;