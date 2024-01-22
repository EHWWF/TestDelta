create or replace view combase_bu_vw as
select
	to_nchar(bu.xbu_code) as code,
	bu.xbu_name as name,
	decode(bu.status,'ACTIVE',1,0) as is_active,
	bu.modify_date
from bdo_bu@combase_db bu;
