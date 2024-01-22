drop materialized view program_top_category_dim;

create materialized view program_top_category_dim as
select 
	sc.code id,
	sc.name,
	sc.description,
	sc.category_code master_cat_id,
	c.name master_cat_name
from ipms_data.program_top_subcategory sc
join ipms_data.program_top_category c on (sc.category_code=c.code);

grant select on program_top_category_dim to mycsd;