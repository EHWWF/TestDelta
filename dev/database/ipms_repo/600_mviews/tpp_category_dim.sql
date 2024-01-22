drop materialized view tpp_category_dim;

create materialized view tpp_category_dim as
select 
 sc.code id
,sc.name
,sc.description
,sc.category_code master_cat_id
,c.name master_cat_name
from ipms_data.tpp_subcategory sc
join ipms_data.tpp_category c on (sc.category_code=c.code);

grant select on tpp_category_dim to mycsd;