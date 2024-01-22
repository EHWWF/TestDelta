create or replace view lead_studies_vw as
------------------------------------
----------The View is used at ADF UI
------------------------------------
select
  ls.*
from lead_studies ls
join timeline_wbs sd on (sd.wbs_id=ls.wbs_id and sd.placeholder=0 and sd.project_id is not null)
--Note: joining with timeline_wbs is much faster
--join lead_studies_vw sd on (sd.wbs_id=ls.wbs_id and sd.placeholder=0)
;