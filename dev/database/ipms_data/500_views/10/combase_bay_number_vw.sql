create or replace view combase_bay_number_vw as
select
	to_nchar(bay.bay_no) as code,
	bay.bay_name as name,
	decode(bay.status,'ACTIVE',1,0) as is_active,
	bay.modify_date
from bdo_bayno@combase_db bay;
