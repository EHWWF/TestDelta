create or replace view ltc_rmng_vw as
with
	cst as (
		select
			tml.id as timeline_id,
			nvl(exp.wbs_id, tml.reference_id) as wbs_id,
			decode(exp.wbs_id, null, 1, 0) as is_root_wbs,
			exp.function_code,
			exp.cost_type_code,
			exp.plan_cost as lt_cost,
			exp.comments as lt_cost_comments,
			--decode(exp.wbs_id, null, tml.start_date, wbs.start_date) as wbs_start_date,
			--decode(exp.wbs_id, null, tml.finish_date, wbs.finish_date) as wbs_finish_date,
			imp.act_cost,
			imp.fct_cost_fps_sum,
			exp.plan_cost - nvl(imp.act_cost, 0) as lt_cost_rmng,
			greatest(decode(exp.wbs_id, null, tml.start_date, wbs.start_date), now) as lt_cost_rmng_start_date,
			decode(exp.wbs_id, null, tml.finish_date, wbs.finish_date) as lt_cost_rmng_finish_date,
			imp.fct_cost_fps_start_date_min,
			imp.fct_cost_fps_finish_date_max
		from timeline_expense exp
		inner join timeline tml on tml.id=exp.timeline_id
		left join timeline_wbs wbs on wbs.timeline_id=tml.id and wbs.wbs_id=exp.wbs_id
		left join (
			select
				timeline_id, wbs_id, function_code, cost_type_code,
				sum(act_cost) as act_cost,
				sum(fct_cost_fps) as fct_cost_fps_sum,
				min(fct_cost_fps_start_date) as fct_cost_fps_start_date_min,
				max(fct_cost_fps_finish_date) as fct_cost_fps_finish_date_max
			from ltc_imported_costs_vw
			group by timeline_id, wbs_id, function_code, cost_type_code
		) imp on imp.timeline_id=tml.id and imp.wbs_id=nvl(exp.wbs_id, tml.reference_id) and imp.function_code=exp.function_code and imp.cost_type_code=exp.cost_type_code
		cross join (select add_months(max(start_date), 1) as now from costs where type_code='ACT') params
	)
select 
	ltc.timeline_id,
	ltc.wbs_id,
	ltc.is_root_wbs,
	ltc.function_code,
	ltc.cost_type_code,
	ltc.lt_cost,
	ltc.lt_cost_comments,
	ltc.lt_cost_rmng,
	--case when lt_cost_rmng < 0 then 0 else lt_cost_rmng end as lt_cost_rmng,
	case 
		when round(lt_cost_rmng, 2) = round(fct_cost_fps_sum, 2) then fct_cost_fps_start_date_min
		when lt_cost_rmng_finish_date < lt_cost_rmng_start_date then null 
		else lt_cost_rmng_start_date
	end as lt_cost_rmng_start_date,
	case 
		when round(lt_cost_rmng, 2) = round(fct_cost_fps_sum, 2) then fct_cost_fps_finish_date_max
		when lt_cost_rmng_finish_date < lt_cost_rmng_start_date then null 
		else lt_cost_rmng_finish_date
	end as lt_cost_rmng_finish_date,
	case --Ratio used later for cost distribution, as it is required: PROMISIII-75
		--Case 1:
		when round(lt_cost_rmng, 2) = round(fct_cost_fps_sum, 2) then 1
		when lt_cost_rmng < 0 then null
		when lt_cost_rmng_finish_date < lt_cost_rmng_start_date then null
		--Case 2: 
			--IF--<Remaining Estimate FPS Start Date>=<Remaining Estimate LTC Start Date>
			--AND--<Remaining Estimate FPS Finish Date>=<Remaining Estimate LTC Finish Date>
			--THEN--<Remaining Estimate LTC Monthx> = <Remaining Estimate FPS Monthx > / <Remaining Estimate FPS Total > x <Remaining Estimate LTC Total>
		when trunc(lt_cost_rmng_start_date, 'mm')=trunc(fct_cost_fps_start_date_min, 'mm') 
			and trunc(lt_cost_rmng_finish_date, 'mm')=trunc(fct_cost_fps_finish_date_max, 'mm') then lt_cost_rmng / fct_cost_fps_sum
		else null
	end as lt_cost_rmng_fct_ratio,
	case
		--when lt_cost_rmng < 0 then 0
		when lt_cost_rmng_finish_date < lt_cost_rmng_start_date then null
		else lt_cost_rmng / (months_between(trunc(lt_cost_rmng_finish_date, 'MM'), trunc(lt_cost_rmng_start_date, 'MM'))+1)
	end as lt_cost_rmng_mm
from cst ltc;