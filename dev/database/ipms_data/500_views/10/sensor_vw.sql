create or replace view sensor_vw as
select
	id,
	process_instance_id process_id,
	varchar2_value message_id,
	sensor_name,
	creation_date create_date
from variable_sensor_values@soainfra_db;
