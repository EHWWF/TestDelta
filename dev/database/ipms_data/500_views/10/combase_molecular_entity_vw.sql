create or replace view combase_molecular_entity_vw as
select
	to_nchar(sup.su_no) as code,
	to_nchar(bdr.su_no) as substance_code,
	sup.su_name as name,
	decode(sup.status,'ACTIVE',1,0) as is_active, --not needed
	sup.modify_date
from bdr_su_sup@combase_db bdr
join bdo_substance@combase_db sup on sup.su_no=bdr.sup_no and sup.status='ACTIVE'
and bdr.status='ACTIVE';

create or replace synonym combase_smu_vw for combase_molecular_entity_vw;