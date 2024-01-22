create or replace view cost_ltc_fte_fct_vw as
with 
	--Prepare hard-coded Period table, that has period_id pointing for January for 15 years
	--Later this table will be JOINed with the rest of LTC data
	with_ltc_period_join_table as (
		select
			ltce.id as ltce_id,
			pe.period_id,
			ltct.start_year+year_nr_table.year_nr ltc_year,
			--year_nr_table.year_nr,
			decode
				(
					year_nr_table.year_nr,
					0,ltce.fct_y1_cost,
					1,ltce.fct_y2_cost,
					2,ltce.fct_y3_cost,
					3,ltce.fct_y4_cost,
					4,ltce.fct_y5_cost,
					5,ltce.fct_y6_cost,
					6,ltce.fct_y7_cost,
					7,ltce.fct_y8_cost,
					8,ltce.fct_y9_cost,
					9,ltce.fct_y10_cost,
					10,ltce.fct_y11_cost,
					11,ltce.fct_y12_cost,
					12,ltce.fct_y13_cost,
					13,ltce.fct_y14_cost,
					14,ltce.fct_y15_cost
				) as fct_det, --Forecast Deterministing for all 15 years
			decode
				(
					year_nr_table.year_nr,
					0,ltce.lt_y1_cost,
					1,ltce.lt_y2_cost,
					2,ltce.lt_y3_cost,
					3,ltce.lt_y4_cost,
					4,ltce.lt_y5_cost,
					5,ltce.lt_y6_cost,
					6,ltce.lt_y7_cost,
					7,ltce.lt_y8_cost,
					8,ltce.lt_y9_cost,
					9,ltce.lt_y10_cost,
					10,ltce.lt_y11_cost,
					11,ltce.lt_y12_cost,
					12,ltce.lt_y13_cost,
					13,ltce.lt_y14_cost,
					14,ltce.lt_y15_cost
				) as ltc_det, --LTC deterministic provided by User for all 15 years
			decode
				(
					year_nr_table.year_nr,
					0,ltce.fct_prob_y1_cost,
					1,ltce.fct_prob_y2_cost,
					2,ltce.fct_prob_y3_cost,
					3,ltce.fct_prob_y4_cost,
					4,ltce.fct_prob_y5_cost,
					5,ltce.fct_prob_y6_cost,
					6,ltce.fct_prob_y7_cost,
					7,ltce.fct_prob_y8_cost,
					8,ltce.fct_prob_y9_cost,
					9,ltce.fct_prob_y10_cost,
					10,ltce.fct_prob_y11_cost,
					11,ltce.fct_prob_y12_cost,
					12,ltce.fct_prob_y13_cost,
					13,ltce.fct_prob_y14_cost,
					14,ltce.fct_prob_y15_cost
				) as fct_prob --Forecast Probabilistic for all 15 years
		from ipms_data.ltc_estimate ltce
		join ipms_data.ltc_project ltcprj on (ltce.ltc_project_id=ltcprj.id)
		join ipms_data.ltc_process ltcp on (ltcprj.ltc_process_id=ltcp.id)
		join ipms_data.ltc_tag ltct on (ltcp.ltc_tag_id=ltct.id)
		cross join (select level-1 as year_nr from dual connect by level <= 15) year_nr_table
		join month_dim pe on (pe.year=ltct.start_year+year_nr_table.year_nr and pe.month_of_year=1)
		where ltce.is_discrepancy=0
	)
select
	--0 ltci_id, --TODO: will be acting as a Version Id for concrete project data pkg
	ltce.id as estimate_id,
	ltcc.period_id,
	ltct.id tag_id,
	ltcprj.ltc_process_id, --in order to have ref to TAG --> cost_ltc_process_dim_vw.process_id
	ltcc.ltc_year,
	ltcprj.project_id,
	wbs.timeline_id,
	wbs.wbs_id,
	ltce.study_id,
	ltce.study_name,
	ltce.study_fpfv,
	ltce.study_lplv,
	ltce.project_phase_code,
	ltce.function_code,
	ltce.function_name,
	ltce.top_function_name,
	ltce.function_cost_rate,
	replace(ltce.scope_code,'-') as scope_code,
	ltce.is_external_fte,
	ltce.cost_start_date,
	ltce.cost_finish_date,
	ltce.project_phase_name,
	ltce.study_phase_code,
	--ltcimp.subtype_code,
	ltce.comments,
	ltcc.fct_det, --Forecast from Profit
	ltcc.fct_prob,
	ltcc.ltc_det, --LTC entered by User
	case 
		when 
			ltcc.ltc_det is null 
		then 
			null--probabilistic LTC values are calculated for all deterministic LTC values
		when 
			ltcc.ltc_det is not null and
			ltce.study_id is null --and 
			--ltce.is_external_fte=1 --We dont have to check is_external_fte becaue all costs that dont have study_id are project level costs
		then 
			ltcc.ltc_det--project-level costs (OEC, EXTFTE) on function level
		when 
			ltce.function_cost_rate is not null and 
			ltce.study_id is not null 
		then 
			(ltcc.ltc_det/ltce.function_cost_rate)--study-level costs on function level (forecasting rule available for function)
		when 
			ltce.study_id is not null and 
			ltce.function_cost_rate is null and 
			nvl(ltcc.fct_det,0)>0 and 
			ltcc.fct_prob is not null 
		then 
			(ltcc.ltc_det*(ltcc.fct_prob/ltcc.fct_det))--study-level costs on function level (forecasting rule NOT available for function)
		when 
			ltce.study_id is not null and 
			ltce.function_cost_rate is null and 
			nvl(ltcc.fct_det,0)=0
		then 
			ltcc.ltc_det--study-level costs on function level (forecasting rule NOT available for function AND FCTd is missing or 0)
		else null
	end ltc_prob, --calculated for Reporting only
	decode(replace(ltce.scope_code,'-'),'INT',decode(nvl(ltce.function_cost_rate,0),0,null,(ltcc.ltc_det/ltce.function_cost_rate)),null) as fte_calc, --Calculated based on Function Cost_Rate
	--ltce.create_date as estimate_create_date,
	--ltce.update_date as estimate_update_date,
	ltce.type_code as estimate_type_code
from ipms_data.ltc_estimate ltce
join ipms_data.ltc_project ltcprj on (ltce.ltc_project_id=ltcprj.id)
join ipms_data.ltc_process ltcp on (ltcprj.ltc_process_id=ltcp.id)
join ipms_data.ltc_tag ltct on (ltcp.ltc_tag_id=ltct.id)
join with_ltc_period_join_table ltcc on (ltce.id=ltcc.ltce_id)
left join ipms_data.timeline_wbs wbs on 
	(
		wbs.project_id = ltcprj.project_id and 
		to_nchar(wbs.study_id) = ltce.study_id and 
		wbs.timeline_type_code = 'RAW'
	)
where ltce.is_discrepancy=0
;