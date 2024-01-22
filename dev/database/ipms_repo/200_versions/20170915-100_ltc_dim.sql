create or replace view cost_ltc_process_dim_vw as
select 
	ltcp.id as process_id,
	ltct.id as tag_id,
	ltcp.name as process_name,
	ltcp.termination_date as process_termination_date,--deadline
	ltcp.status_code as process_status_code,
	ltcp.status_date as process_status_date,	
	ltcp.comments as process_comments,
	ltcp.create_date as process_create_date,
	ltcp.update_date as process_update_date,
	ltcp.terminate_date as process_terminate_date,
	ltct.name as tag_name,
	ltct.start_year as tag_start_year,
	--to_date(ltct.start_year||'0101','YYYYMMDD') as tag_period_start,
	--to_date((ltct.start_year+15)||'1231','YYYYMMDD') as tag_period_finish,
	ltct.submit_report_date as tag_submit_report_date,
	ltct.prefil_from_profit_date as tag_prefil_from_profit_date,
	ltct.calculate_prob_date as tag_calculate_prob_date,
	ltct.forecast_year,
	ltct.forecast_month,
	ltct.forecast_number,
	ltct.forecast_version,
	ltct.create_date as tag_create_date,
	ltct.update_date as tag_update_date
from ipms_data.ltc_process ltcp
join ipms_data.ltc_tag ltct on (ltcp.ltc_tag_id=ltct.id)
;
create table cost_ltc_process_dim as select * from cost_ltc_process_dim_vw;
create unique index cost_ltc_process_dim_ui on cost_ltc_process_dim (tag_id,process_id);