create or replace view import_study_target_wbs_vw as
with 
	wbs (project_id, timeline_id, timeline_type_code, wbs_id, parent_wbs_id,start_date,finish_date,name) as 
	(
		select 
			w.project_id, w.timeline_id, w.timeline_type_code,
			w.wbs_id, to_char(t.reference_id) as parent_wbs_id,
			w.start_date,w.finish_date,w.name
		from timeline_wbs w
		join timeline t on (t.id=w.timeline_id)
		join (select project_id from import where create_date>sysdate-1/24 and type_mask=64 group by project_id) imps on (w.project_id=imps.project_id)
		where w.study_id is null 
		and w.parent_wbs_id is null
		and w.timeline_type_code='RAW'
			union all
		select 
			w.project_id, w.timeline_id, w.timeline_type_code,
			w.wbs_id, w.parent_wbs_id,
			w.start_date, w.finish_date, w.name
		from timeline_wbs w
		join (select project_id from import where create_date>sysdate-1/24 and type_mask=64 group by project_id) imps on (w.project_id=imps.project_id)
		join wbs on (wbs.timeline_id=w.timeline_id and wbs.wbs_id=w.parent_wbs_id)
		where w.study_id is null
		and w.timeline_type_code='RAW'
	)
select 
	project_id, id as timeline_id, type_code as timeline_type_code, 
	to_char(reference_id) as wbs_id, to_char(null) as parent_wbs_id,
	start_date, finish_date, name
from timeline	
where type_code='RAW'
	union all
select
	project_id, timeline_id, timeline_type_code,
	wbs_id, parent_wbs_id,
	start_date, finish_date, to_nchar(name)
from wbs;