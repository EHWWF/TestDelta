drop materialized view function_dim;
create materialized view function_dim as
select 
	ID,
	FUNCTION_NAME,
	SUBFUNCTION_NAME,
	PARENT_CODE,
	TOP_FUNCTION_CODE,
	TOP_FUNCTION_NAME,
	IS_ACTIVE 
from function_dim_vw
	union all	
select 
	to_nchar(fn.code),
	to_nchar(fn.NAME),
	to_nchar(fn.NAME),
	to_nchar(fn.code),
	to_nchar(tf.code),
	to_nchar(tf.name),
	fn.IS_ACTIVE
from (
	select fct_id   
	from (		(select distinct to_char(fct_id) fct_id from COST_FCT) 
		union all (select distinct to_char(fct_id) fct_id from COST_FPS_FCT)
		union all (select distinct to_char(FUNCTION_CODE) fct_id from COST_LTC_FCT)
		union all (select distinct to_char(FUNCTION_CODE) fct_id from COST_LTC_FTE_FCT)
		union all (select distinct to_char(fct_id) fct_id from LATEST_ESTIMATE_FCT)
		union all (select distinct to_char(fct_id) fct_id from RESOURCE_CS_FCT)
		union all (select distinct to_char(fct_id) fct_id from RESOURCE_FCT)
		union all (select distinct to_char(fct_id) fct_id from RESOURCE_GED_FCT)
	) where fct_id is not null
		minus
	select to_char(id) id from (select * from function_dim_vw)
	) fnminus
left join ipms_data.function fn on (fn.code=fnminus.fct_id)
left join ipms_data.top_function tf on (fn.top_function_code = tf.code);
grant select on function_dim to mycsd;