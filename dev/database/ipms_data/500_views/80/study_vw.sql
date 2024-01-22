create or replace view study_vw as
with wbs(project_id,timeline_id,timeline_type_code,wbs_id,parent_wbs_id,study_id,placeholder,path,hlevel) as (
	select
		project_id,
		timeline_id,
		timeline_type_code,
		wbs_id,
		parent_wbs_id,
		study_id,
		placeholder,
		'/'||wbs_id,
		1
	from timeline_wbs
	where study_id is not null
	union all
	select
		e.project_id,
		e.timeline_id,
		e.timeline_type_code,
		e.wbs_id,
		e.parent_wbs_id,
		m.study_id,
		m.placeholder,
		m.path||'/'||e.wbs_id,
		m.hlevel + 1
	from timeline_wbs e join wbs m on m.wbs_id=e.parent_wbs_id and m.timeline_id=e.timeline_id and e.study_id is null
)
select
	project_id,
	timeline_id,
	timeline_type_code,
	wbs_id,
	study_id,
	placeholder,
	hlevel
from wbs;
