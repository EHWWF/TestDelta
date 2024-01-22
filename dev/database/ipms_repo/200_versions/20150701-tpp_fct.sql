drop materialized view tpp_fct;

create materialized view tpp_fct as
select
 t.period_id
,ttpv.id
,ttpv.tpp_id
,ttpv.subcategory_code tpp_category_id
,ttpv.key_edv_proposition
,ttpv.standard_of_care
,ttpv.targeted_profile
,ttpv.upside
,ttpv.targeted_in
,ttpv.key_driver
,ttpv.unique_selling_point
,tpp.project_id
,p.program_id
from ipms_data.tpp_values ttpv
join ipms_data.target_product_profile tpp on (ttpv.tpp_id=tpp.id)
join ipms_data.project p on (tpp.project_id=p.id)
join ipms_repo.period_dim t on t.year=extract(year from tpp.approval_date) and t.month_of_year=extract(month from tpp.approval_date);