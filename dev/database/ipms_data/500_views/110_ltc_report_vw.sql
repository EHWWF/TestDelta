create or replace view ltc_report_vw as
with
	all_costs as (
		select 
			cst.*,
			decode(count(lt_cost_flag) over (partition by cst.timeline_id, cst.wbs_id, cst.function_code, cst.cost_type_code), 0, to_number(null), nvl(lt_cost_rmng, 0) + nvl(act_cost, 0)) as lt_cost
		from (
			select
				timeline_id,
				wbs_id,
				is_root_wbs,
				function_code,
				cost_type_code,
				start_date as mm_start_date,
				act_cost, 
				act_cost_start_date,
				act_cost_finish_date,
				fct_cost_fps, 
				fct_cost_fps_start_date, 
				fct_cost_fps_finish_date, 
				to_number(null) as lt_cost_rmng,
				to_date(null) as lt_cost_rmng_start_date,
				to_date(null) as lt_cost_rmng_finish_date,
				to_nchar(null) as lt_cost_comments,
				to_number(null) as lt_cost_flag,
				0 as lt_cost_rmng_fct_ratio
			from ltc_imported_costs_vw
				union all
			select
				timeline_id,
				wbs_id,
				is_root_wbs,
				function_code,
				cost_type_code,
				mm.start_date as mm_start_date,
				null as act_cost, 
				null as act_cost_start_date, 
				null as act_cost_finish_date, 
				null as fct_cost_fps,
				null as fct_cost_fps_start_date,
				null as fct_cost_fps_finish_date,
				decode(null, lt_cost_rmng_start_date, lt_cost_rmng, lt_cost_rmng_finish_date, lt_cost_rmng, lt_cost_rmng_mm) as lt_cost_rmng,
				greatest(lt_cost_rmng_start_date, nvl(mm.start_date, lt_cost_rmng_start_date)),
				least(lt_cost_rmng_finish_date, nvl(mm.finish_date, lt_cost_rmng_finish_date)),
				lt_cost_comments,
				1 as lt_cost_flag,
				decode(lt_cost_rmng_fct_ratio,1,1,0) lt_cost_rmng_fct_ratio
			from ltc_rmng_vw
			left join calendar_month mm on (mm.start_date >= trunc(lt_cost_rmng_start_date, 'mm') and mm.start_date <= lt_cost_rmng_finish_date)
		) cst
	),
	all_costs_grp as (
		select 
			cst.timeline_id,
			cst.wbs_id,
			cst.is_root_wbs,
			cst.function_code,
			cst.cost_type_code,
			null phase_name,
			max(cst.lt_cost_rmng_fct_ratio) as lt_cost_rmng_fct_ratio,
			min(wrp.start_date) as phase_start_date,
			max(wrp.finish_date-1) as phase_finish_date,
			sum(act_cost) as act_cost,
			min(act_cost_start_date) as act_cost_start_date,
			max(act_cost_finish_date) as act_cost_finish_date,
			sum(fct_cost_fps) as fct_cost_fps,
			min(fct_cost_fps_start_date) as fct_cost_fps_start_date,
			max(fct_cost_fps_finish_date) as fct_cost_fps_finish_date,
			sum(lt_cost) as lt_cost,
			sum(lt_cost_rmng) as lt_cost_rmng,
			min(lt_cost_rmng_start_date) as lt_cost_rmng_start_date,
			max(lt_cost_rmng_finish_date) as lt_cost_rmng_finish_date,
			max(lt_cost_comments) as lt_cost_comments
		from all_costs cst
		left join ltc_milestone_phase_vw wrp 
			on wrp.timeline_id=cst.timeline_id
				and cst.mm_start_date >= wrp.start_date 
				--and lnnvl(cst.mm_start_date >= wrp.finish_date) --this line does not compile with Oracle12c
				and cst.mm_start_date >= nvl(wrp.finish_date,wrp.start_date)
				and cst.is_root_wbs = 1		
		group by cst.timeline_id, cst.wbs_id, cst.is_root_wbs, cst.function_code, cst.cost_type_code--, wrp.phase_name
	),
	fte_grp as (
		select project_id,
				study_id,
				function_code,
				round(avg(fte),2) fte_avg 
		from fte
		group by project_id, study_id, function_code
	),
	parent_study as (
		select
			tws.timeline_id,
			tws.parent_wbs_id,
			tws.wbs_id,
			CONNECT_BY_ROOT tws.study_id root_study_id--,level
		from ipms_data.timeline_wbs tws
		where level>1
		--where tws.timeline_id=v_timeline_id
		start with tws.study_id is not null
		connect by prior tws.wbs_id=tws.parent_wbs_id
	)
select
	wbs.timeline_id,
	wbs.wbs_id,
	wbs.parent_wbs_id,
	wbs.root_wbs_id,
	tml.project_id, 
	tml.sandbox_id,
	nvl(tml.project_name, tml.sandbox_name) as project_name,
	coalesce(wbs.name, tml.project_name, tml.sandbox_name) as wbs_name,
	nvl(phase_start_date, wbs.start_date) as wbs_start_date,
	nvl(phase_finish_date, wbs.finish_date) as wbs_finish_date,
	decode(wbs.wbs_id, root_wbs_id, cst.phase_name, wbs.category_name) as phase_name,
	wbs.study_id,
	ps.root_study_id,
	decode(std.is_gpdc_approved, 1, 'Yes') as is_gpdc_approved_desc,
	std.phase as study_phase,
	cst.function_code,
	fnc.name as function_name,
	cst.cost_type_code,
	decode(cst.cost_type_code, 'INT', 'Internal Cost', 'CRO', 'External Cost - CRO', 'ECG', 'External Cost - ECG', 'OEC', 'External Cost - OEC') as cost_type_name,
	cst.act_cost,
	cst.act_cost_start_date,
	cst.act_cost_finish_date,
	cst.fct_cost_fps,
	cst.fct_cost_fps_start_date,
	cst.fct_cost_fps_finish_date,
	cst.lt_cost,
	cst.lt_cost_rmng,
	cst.lt_cost_rmng_start_date,
	cst.lt_cost_rmng_finish_date,
	cst.lt_cost_comments,
	cst.lt_cost_rmng_fct_ratio as is_rmng_case1,--needed for making decision how many columns should be prepared at Excel, also for colouring rows
	fte.fte_avg
from ltc_wbs_vw wbs
inner join all_costs_grp cst on (wbs.timeline_id=cst.timeline_id and wbs.wbs_id=cst.wbs_id)
inner join (
	select tml.id as timeline_id, prj.id as project_id, prj.name as project_name, sbx.id as sandbox_id, sbx.name as sandbox_name
	from timeline tml
	left join project prj on prj.id=tml.project_id
	left join program_sandbox sbx on (sbx.snd_timeline_id=tml.id)
) tml on (tml.timeline_id=wbs.timeline_id)
inner join function fnc on (fnc.code=cst.function_code)
left join study_data_vw std on (std.timeline_id=wbs.timeline_id and std.wbs_id=wbs.wbs_id)
left join fte_grp fte on (tml.project_id=fte.project_id and wbs.study_id=fte.study_id and cst.function_code=fte.function_code)
left join parent_study ps on (ps.timeline_id=wbs.timeline_id and ps.wbs_id=wbs.wbs_id and wbs.parent_wbs_id=ps.parent_wbs_id)
;