create or replace view combase_bay_combination_vw as
select
	to_nchar(bys.bys_no) as code,
	bys.bys_name as name,
	decode(bys.status,'ACTIVE',1,0) as is_active,
	bys.modify_date
from bdo_bayno_combi@combase_db bys;
