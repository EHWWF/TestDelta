create or replace view combase_ipowner_vw as
select
ip.xip_no code, 
ip.xip_name name, 
decode(ip.status,'ACTIVE',1,0) as is_active,
ip.modify_date
from bdo_ipowner@combase_db ip;