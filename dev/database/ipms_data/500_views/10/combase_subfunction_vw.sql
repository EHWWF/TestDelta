create or replace view combase_subfunction_vw as
select
	trim(leading '0' from sf.kfu3_no) as code,
	sf.kfu3_name as name,
	decode(sf.status,'ACTIVE',1,0) as is_active,
	modify_date
from bdo_costcenter_function_sub1@combase_db sf;