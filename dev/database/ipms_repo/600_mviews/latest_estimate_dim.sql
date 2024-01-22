drop materialized view latest_estimate_dim
;
create materialized view latest_estimate_dim as
select 
	le_p.id,
	le_p.name,
	le_t.name as tag_name,
	le_t.is_frozen,
	le_p.comments,
	le_p.create_date,
	le_p.termination_date,
	to_date(le_p.year||'0101','YYYYMMDD') as period_start,
	to_date((le_p.year+le_p.is_next_year)||'1231','YYYYMMDD') as period_finish
from ipms_data.latest_estimates_process le_p
join ipms_data.latest_estimates_tag le_t on (le_p.let_id=le_t.id)
;
grant select on latest_estimate_dim to mycsd;