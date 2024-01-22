create or replace view combase_sbe_vw as
select
	to_nchar(sbe.xbe_no) as xbe_no,
	to_nchar(sbe.xbe_code) as code,
	xbe.xbu_code as gbu_code,
	sbe.xbe_name as name,
	decode(sbe.status,'ACTIVE',1,0) as is_active,
	sbe.modify_date
from 
 (
	select
		sbe.*
	from bdo_sbe@combase_db sbe
) sbe
left outer join (
	select
		xbe.*,
		bu.xbu_code
	from bdr_xbu_xbe@combase_db xbe
	join bdo_bu@combase_db bu on xbe.xbu_no=bu.xbu_no and bu.status='ACTIVE'
  where xbe.status='ACTIVE'
) xbe on sbe.xbe_no=xbe.xbe_no;