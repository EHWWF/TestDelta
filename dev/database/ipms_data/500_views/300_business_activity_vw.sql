create or replace view business_activity_vw as
select
	code,
	name,
	category_id 
from (
	with activities as (
		select
			id,
			name 
		from business_activity_category_vw
		)
		select
			activities.name ||' - '|| ac.name as name,
			lower(ac.code) as code,
			to_number(ac.category_id) as category_id
		from business_activity ac  
		join activities on (id = ac.category_id)
			union all
		select 
			cast(name as nvarchar2(100))||' - All' as name, 
			cast(id as nvarchar2(30)) as code,
			id as category_id
		from activities 
)
order by 
	category_id,
	case when cast(category_id as nvarchar2(2)) = code then 0 else 1 end, name;