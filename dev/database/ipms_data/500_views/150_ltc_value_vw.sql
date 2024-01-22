create or replace view ltc_value_vw as
select 
	ltcv.*, 
	int_act_cost as sph_int_cost,
	ecg_act_cost as sph_ecg_cost,
	cro_act_cost as sph_cro_cost,
	oec_act_cost as sph_oeci_cost,
	int_fct_cost_fps as fps_int_cost,
	ecg_fct_cost_fps as fps_ecg_cost,
	cro_fct_cost_fps as fps_cro_cost,
	oec_fct_cost_fps as fps_oeci_cost
from ltc_value ltcv
left join (
	select *
		from (
			select 
				ltcp.id as ltcp_id, 
				cst.function_code, 
				cst.cost_type_code,
				sum(cst.act_cost) as act_cost, 
				sum(cst.fct_cost_fps) as fct_cost_fps
			from ltc_instance ltci
			inner join ltc_plan ltcp on ltci.id=ltcp.ltci_id
			inner join ltc_imported_costs_vw cst on (cst.timeline_id=ltci.timeline_id and ltcp.wbs_id=cst.wbs_id)
			group by ltcp.id, cst.function_code, cst.cost_type_code
		)
		pivot (
			sum(act_cost) as act_cost, sum(fct_cost_fps) as fct_cost_fps
			for cost_type_code in ('INT' as int, 'ECG' as ecg, 'CRO' as cro,'OEC' as oec)
	)
) cstt on cstt.ltcp_id=ltcv.ltcp_id and cstt.function_code=ltcv.function_code;