drop materialized view export_pts_phase_vw
;
create materialized view export_pts_phase_vw as
select code,name,ordering,is_active
from phase
where code in('1','2','34','5','6')
union all
select to_nchar('100') code, to_nchar('Overall') name, 50 ordering, 1 is_active
from dual
;
grant select on export_pts_phase_vw to mxcbi;
grant select on export_pts_phase_vw to mycsd;