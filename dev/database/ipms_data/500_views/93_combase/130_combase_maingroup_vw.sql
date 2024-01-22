create or replace view combase_maingroup_vw as
select
	mg.xgm_no as code,
	xgt.xgt_no as topgroup_code,
	mg.xgm_name as name,
	decode(mg.status,'ACTIVE',1,0) as is_active,
	greatest(nvl(mg.modify_date,sysdate-36500),nvl(xgt.modify_date,sysdate-36500)) as modify_date
from (
	select
		mg.*
	from bdo_maingroup@combase_db mg
) mg
left outer join (
	select
		xgt.*
	from bdr_xgt_xgm@combase_db xgt
  where xgt.status='ACTIVE'
) xgt on mg.xgm_no=xgt.xgm_no;