drop materialized view program_top_fct;

create materialized view program_top_fct as
select
		t.period_id,
		ptv.id value_id,
		ver.program_id,
		ptv.program_version_id version_id,
		ver.parent_id parent_version_id,
		ver.name version_name,
		ver.description version_description,
		ver.version,
		ver.version_nr,
		ver.approval_date version_approval_date,
		ptv.subcategory_code program_top_subcategory_id,
		scat.name program_top_subcategory_name,
		scat.category_code program_top_category_id,
		cat.name category_name,
		ptv.indication1,
		ptv.indication2,
		ptv.indication3,
		ptv.indication4,
		ptv.indication5,
		ptv.indication6,
		ptv.indication7,
		ptv.indication8
from ipms_data.program_top_value ptv
join IPMS_DATA.PROGRAM_TOP_SUBCATEGORY scat on (scat.code=ptv.subcategory_code)
join IPMS_DATA.PROGRAM_TOP_CATEGORY cat on (cat.code=scat.category_code)
join ipms_data.program_top_version ver on (ptv.program_version_id=ver.id)
join ipms_repo.period_dim t on t.year=extract(year from ver.approval_date) and t.month_of_year=extract(month from ver.approval_date);

grant select on program_top_fct to mycsd;