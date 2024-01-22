drop materialized view tpp_dim;

create materialized view tpp_dim as
select
 tpp.id
,tpp.name
,tpp.version
,tpp.description
,tpp.indication
,tpp.references
,tpp.approval_date
from ipms_data.target_product_profile tpp;