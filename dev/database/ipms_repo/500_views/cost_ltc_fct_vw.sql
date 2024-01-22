create or replace view cost_ltc_fct_vw as
with
	all_costs as (
		select 
			cst.*,
			decode(
				count(lt_cost_flag) over (partition by cst.timeline_id, cst.wbs_id, cst.function_code, cst.cost_type_code), 
				0, 
				to_number(null), 
				nvl(lt_cost_rmng, 0) + nvl(act_cost, 0)
				) as lt_cost
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
					to_number(null) as lt_cost_flag
				from ipms_data.ltc_imported_costs_vw
					union all
				select
					ltcrv.timeline_id,
					ltcrv.wbs_id,
					ltcrv.is_root_wbs,
					ltcrv.function_code,
					ltcrv.cost_type_code,
					mm.start_date as mm_start_date,
					null as act_cost, 
					null as act_cost_start_date, 
					null as act_cost_finish_date, 
					null as fct_cost_fps,
					null as fct_cost_fps_start_date,
					null as fct_cost_fps_finish_date,
					--decode(null, lt_cost_rmng_start_date, lt_cost_rmng, lt_cost_rmng_finish_date, lt_cost_rmng, lt_cost_rmng_mm) as lt_cost_rmng,
					decode(ltcrv.lt_cost_rmng_fct_ratio, null, ltcrv.lt_cost_rmng_mm, imp.fct_cost_fps_sum * ltcrv.lt_cost_rmng_fct_ratio) as lt_cost_rmng,
					greatest(lt_cost_rmng_start_date, nvl(mm.start_date, ltcrv.lt_cost_rmng_start_date)),
					least(lt_cost_rmng_finish_date, nvl(mm.finish_date, ltcrv.lt_cost_rmng_finish_date)),
					ltcrv.lt_cost_comments,
					1 as lt_cost_flag
				from ipms_data.ltc_rmng_vw ltcrv
				left join ipms_data.calendar_month mm on (mm.start_date >= trunc(ltcrv.lt_cost_rmng_start_date, 'mm') and mm.start_date <= ltcrv.lt_cost_rmng_finish_date)--PROMISIII-315 must be: mm, the first day of moth
				left join (
							select
								impv.timeline_id,
								impv.wbs_id,
								impv.function_code,
								impv.cost_type_code,
								impv.start_date as mm_start_date, 
								sum(impv.fct_cost_fps) as fct_cost_fps_sum
							from ipms_data.ltc_imported_costs_vw impv
							group by 
								impv.timeline_id,
								impv.wbs_id,
								impv.function_code,
								impv.cost_type_code,
								impv.start_date
							) imp on (
											imp.mm_start_date=greatest(lt_cost_rmng_start_date, nvl(mm.start_date, ltcrv.lt_cost_rmng_start_date)) 
										and imp.timeline_id=ltcrv.timeline_id 
										and imp.wbs_id = ltcrv.wbs_id 
										and imp.function_code=ltcrv.function_code 
										and imp.cost_type_code=ltcrv.cost_type_code
										)
		) cst
	),
	all_costs_grp as (
		select 
			nvl(psbx.src_project_id, wbs.project_id) as project_id,
			wbs.sandbox_id,
			wbs.timeline_id,
			wbs.ltci_id,
			nullif(wbs.wbs_id, wbs.root_wbs_id) as wbs_id,
			wbs.study_id,
			decode(is_root_wbs, 1, null, wbs.category_name) as phase_name,
			function_code,
			cost_type_code,
			period_id,
			sum(act_cost) as act_cost,
			sum(fct_cost_fps) as fct_cost_fps,
			sum(lt_cost_rmng) as lt_cost,
			sum(lt_cost) as lt_cost_total
		from all_costs cst
		left join ipms_data.ltc_milestone_phase_vw wrp 
			on wrp.timeline_id=cst.timeline_id
				and cst.mm_start_date >= wrp.start_date 
				--and lnnvl(cst.mm_start_date >= wrp.finish_date)
				and cst.mm_start_date >= nvl(wrp.finish_date,wrp.start_date)
				and cst.is_root_wbs = 1
		inner join ipms_repo.period_dim p on p.year=extract(year from mm_start_date) and p.month_of_year=extract(month from mm_start_date)
		inner join ipms_data.ltc_wbs_vw wbs on wbs.timeline_id=cst.timeline_id and wbs.wbs_id=cst.wbs_id
		left join (
				select 
					sbx.id as sandbox_id,
					sbx.program_id,
					sbx.snd_timeline_id as timeline_id, 
					sbx.timeline_id as src_timeline_id, 
					sbx_src_tl.project_id as src_project_id 
				from ipms_data.program_sandbox sbx
				inner join ipms_data.timeline sbx_src_tl on sbx_src_tl.id=sbx.timeline_id
			) psbx on (psbx.timeline_id=cst.timeline_id and cst.timeline_id like '%-SND')
		group by nvl(psbx.src_project_id, wbs.project_id), wbs.sandbox_id, wbs.timeline_id, wbs.ltci_id, nullif(wbs.wbs_id, wbs.root_wbs_id), wbs.study_id, decode(is_root_wbs, 1, null, wbs.category_name), function_code, cost_type_code, period_id
	),
	fte_grp as (
		select project_id,
				study_id,
				function_code,
				round(avg(fte),2) fte_avg 
		from ipms_data.fte
		group by project_id, study_id, function_code
	),
	ltc_max as (
		select timeline_id, max(id) max_ltci_id
		from IPMS_DATA.ltc_instance
		where status_code='DONE'
		group by timeline_id
	),
	parent_study as (
		select
			tws.timeline_id,
			tws.parent_wbs_id,
			tws.wbs_id,
			connect_by_root tws.study_id root_study_id,
			connect_by_root tws.wbs_id root_study_wbs_id--,
			--level
		from ipms_data.timeline_wbs tws
		where level>1
		--where tws.timeline_id=v_timeline_id
		start with tws.study_id is not null
		connect by prior tws.wbs_id=tws.parent_wbs_id
	)
select 
	acg.*, 
	fte.fte_avg,
	ltc_max.max_ltci_id,
	ps.root_study_id,
	ps.root_study_wbs_id
from (
select
	period_id,
	project_id, 
	substr(sandbox_id,1,20) sandbox_id,
	timeline_id,
	ltci_id,
	substr(wbs_id,1,100) wbs_id,
	substr(study_id,1,100) study_id,
	substr(phase_name, 1, 100) phase,
	substr(function_code,1,20) function_code,
	oec_act as act_ext_oec_det,
	cro_act as act_ext_cro_det,
	ecg_act as act_ext_ecg_det,
	int_act as act_int_det,
	oec_fct as fct_ext_oec_det,
	cro_fct as fct_ext_cro_det,
	ecg_fct as fct_ext_ecg_det,
	int_fct as fct_int_det,
	oec_ltc as ltc_ext_oec_det,
	cro_ltc as ltc_ext_cro_det,
	ecg_ltc as ltc_ext_ecg_det,
	int_ltc as ltc_int,
	oec_total as total_ext_oec_det,
	cro_total as total_ext_cro_det,
	ecg_total as total_ext_ecg_det,
	int_total as total_int
from all_costs_grp
pivot(
	sum(act_cost) as act, 
	sum(fct_cost_fps) as fct, 
	sum(lt_cost) as ltc, 
	sum(lt_cost_total) as total
		for cost_type_code in ('INT' as int, 'ECG' as ecg, 'CRO' as cro, 'OEC' as oec)
) x
cross join (select 1 from dual)
where (ltci_id is not null or timeline_id in (select timeline_id from IPMS_DATA.ltc_instance where status_code='DONE'))
) acg
left join fte_grp fte on (acg.project_id=fte.project_id and acg.study_id=fte.study_id and acg.function_code=fte.function_code)
left join ltc_max ltc_max on (acg.timeline_id=ltc_max.timeline_id)
left join parent_study ps on (ps.timeline_id=acg.timeline_id and ps.wbs_id=acg.wbs_id)
;