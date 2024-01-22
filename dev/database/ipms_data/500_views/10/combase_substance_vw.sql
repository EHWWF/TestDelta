create or replace view combase_substance_vw as
select
	to_nchar(su.su_no) as code,
	su.su_name||' ('||(listagg(bay.bay_name,', ') within group(order by bay.bay_no))||')' as name,
	decode(su.status,'ACTIVE',1,0) as is_active,
	greatest(su.modify_date, max(bdr.modify_date)) as modify_date
from bdo_substance@combase_db su
left join bdr_su_bay@combase_db bdr on su.su_no=bdr.su_no and bdr.status='ACTIVE'
left join bdo_bayno@combase_db bay on bay.bay_no=bdr.bay_no and bay.status='ACTIVE'
group by su.su_no,su.su_name,su.status,su.modify_date;