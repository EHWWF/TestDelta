create or replace view function_dim_vw as
select
	sf.code as id,
	f.name as function_name,
	sf.name as subfunction_name,
	sf.function_code as parent_code,
	tf.code as top_function_code,
	tf.name as top_function_name,
	sf.is_active
from ipms_data.subfunction sf
left join ipms_data.function f on (sf.function_code=f.code)
left join ipms_data.top_function tf on (f.top_function_code = tf.code)
order by function_name, id
;