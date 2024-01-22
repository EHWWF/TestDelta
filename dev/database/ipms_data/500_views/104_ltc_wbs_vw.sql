create or replace view ltc_wbs_vw as
with
	wbs as (
		select
			w.timeline_id,
			t.reference_id as root_wbs_id,
			to_nchar(w.wbs_id) as wbs_id,
			to_nchar(nvl(w.parent_wbs_id, t.reference_id)) as parent_wbs_id,
			to_nchar(w.code) as code,
			to_nchar(w.name) as name,
			w.start_date,
			w.finish_date,
			to_nchar(w.study_id) as study_id,
			w.project_id,
			w.sandbox_id,
			t.ltci_id
		from timeline_wbs w
		inner join timeline t on t.id=w.timeline_id
			union all
		select
			tml.id as timeline_id,
			tml.reference_id as root_wbs_id,
			tml.reference_id as wbs_id,
			null as parent_wbs_id,
			tml.code,
			tml.name,
			tml.start_date,
			tml.finish_date,
			null as study_id,
			tml.project_id as project_id,
			sbx.id as sandbox_id,
			tml.ltci_id
		from timeline tml
		left join program_sandbox sbx on sbx.snd_timeline_id=tml.id
	),
	wbs_cat as (
		select
			w.*,
			wcat.category_name
		from wbs w
		left join timeline_wbs_category wcat
			on wcat.timeline_id=w.timeline_id and nvl(wcat.wbs_id, w.root_wbs_id) = w.wbs_id
	),
	wbs_cat_r (timeline_id, wbs_id, parent_wbs_id, root_wbs_id, code, name, start_date, finish_date, study_id, category_name, project_id, sandbox_id, ltci_id) 
	as (
		select
			wcat.timeline_id,
			wcat.wbs_id,
			wcat.parent_wbs_id,
			wcat.root_wbs_id,
			wcat.code,
			wcat.name,
			wcat.start_date,
			wcat.finish_date,
			wcat.study_id,
			wcat.category_name,
			wcat.project_id,
			wcat.sandbox_id,
			wcat.ltci_id
		from wbs_cat wcat
		where wcat.parent_wbs_id is null
			union all
		select
			wcat.timeline_id,
			wcat.wbs_id,
			wcat.parent_wbs_id,
			wcat.root_wbs_id,
			wcat.code,
			wcat.name,
			wcat.start_date,
			wcat.finish_date,
			wcat.study_id,
			nvl(wcat.category_name, wcatr.category_name),
			wcat.project_id,
			wcat.sandbox_id,
			wcat.ltci_id
		from wbs_cat wcat
		inner join wbs_cat_r wcatr on wcatr.timeline_id=wcat.timeline_id and wcatr.wbs_id = wcat.parent_wbs_id
		where wcat.parent_wbs_id is NOT null
	)
select *
from  wbs_cat_r;