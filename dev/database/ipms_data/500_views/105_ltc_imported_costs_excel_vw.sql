create or replace view ltc_imported_costs_excel_vw as
with
	vwpar as (
		select
			ltc_report_pkg.get_timeline_id as par_timeline_id
		from dual
	)
select
	tl.id as timeline_id,
	--cst.decision_start,
	nvl(to_nchar(w.wbs_id), tl.reference_id) as wbs_id,
	decode(w.wbs_id, null, 1, 0) as is_root_wbs,
	to_nchar(w.study_id) as study_id,
	cst.function_code,
	cst.cost_type_code,
	cst.start_date,
	cst.finish_date,
	cst.act_cost,
	act_cost_start_date,
	act_cost_finish_date,
	cst.fct_cost_fps,
	fct_cost_fps_start_date,
	fct_cost_fps_finish_date
from timeline tl
left join (
	select
		sbx.id as sandbox_id, 
		sbx.snd_timeline_id as timeline_id, 
		sbx.timeline_id as src_timeline_id, 
		sbx_src_tl.project_id as src_project_id 
	from program_sandbox sbx
	inner join timeline sbx_src_tl on (sbx_src_tl.id=sbx.timeline_id)
) sb on tl.project_id is null and sb.timeline_id=tl.id
inner join ltc_costs_excel_vw cst on (cst.project_id=nvl(tl.project_id, sb.src_project_id))
left join timeline_wbs w on (w.timeline_id=tl.id and to_nchar(w.study_id)=cst.study_id)
cross join vwpar
where tl.id=decode(vwpar.par_timeline_id,null,tl.id,vwpar.par_timeline_id)--decode should be faster
and tl.type_code in ('RAW','SND')
--where (cst.study_id is null or cst.study_id=w.study_id)
;