create or replace view combase_subgroup_vw as
select
	sub.xgs_no as correlation_id,
	sub.xgs_code as code,
	gm.xgm_no as maingroup_code,
	sub.xgs_name as name,
	decode(sub.status,'ACTIVE',1,0) as is_active,
	greatest(nvl(sub.modify_date,sysdate-36500),nvl(gm.modify_date,sysdate-36500)) as modify_date
from (
	select * from (
		select
			sub.*,
			row_number() over (partition by sub.xgs_no order by sub.status) as rank --Active will be on top
		from bdo_subgroup@combase_db sub
	) where rank=1
) sub
left outer join (
	select
		gm.*
	from bdr_xgm_xgs@combase_db gm
	where gm.status='ACTIVE'
) gm on sub.xgs_no=gm.xgs_no
;