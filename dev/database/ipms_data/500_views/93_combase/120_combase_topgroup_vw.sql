create or replace view combase_topgroup_vw as
select
xgt.xgt_no code,
xgt.xgt_name name,
decode(xgt.status,'ACTIVE',1,0) as is_active,
xgt.modify_date
from bdo_topgroup@combase_db xgt;