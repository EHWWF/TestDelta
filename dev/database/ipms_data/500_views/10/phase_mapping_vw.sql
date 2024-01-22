create or replace view phase_mapping_vw as
select
	ph.code phase_code,
	case
		when ph.code in ('3','4') then N'34'
 		when ph.code in ('7','11','12') then N'6'
		else ph.code
	end as pts_phase_code
from phase ph
where ph.is_active=1;