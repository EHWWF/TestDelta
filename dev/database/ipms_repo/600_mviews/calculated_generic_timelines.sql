drop materialized view calculated_generic_timelines
;
create materialized view calculated_generic_timelines as
select
	cast(p_id as varchar2(20)) as id,
	cast(p_name as varchar2(100)) as name,
	cast(sbe_name as varchar2(100)) as sbe_name,
	cast(ds_type as varchar2(100)) as ds_type,
	cast(phase_name as varchar2(100)) as phase_name,
	cast("'D2'" as varchar2(20)) as d2,
	cast("'D3'" as varchar2(20)) as pcc,
	cast("'D4'" as varchar2(20)) as d4,
	--cast("'M4C'" as varchar2(20)) as m4c,
	cast("'PoC'" as varchar2(20)) as poc,
	cast("'D6'" as varchar2(20)) as d6,
	cast("'D7'" as varchar2(20)) as d7,
	cast("'D8'" as varchar2(20)) as d8,
	cast("'M9'" as varchar2(20)) as m9,
	cast("'D5'" as varchar2(20)) as d5
from ipms_data.project_gt_vw
;
grant select on calculated_generic_timelines to mycsd
;