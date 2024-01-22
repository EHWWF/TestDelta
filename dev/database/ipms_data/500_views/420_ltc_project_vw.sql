  CREATE OR REPLACE VIEW LTC_PROJECT_VW AS 
  select
	lp.ltc_tag_id tag_id,
	lp.id process_id,
	prj.id project_id,
	prj.program_id program_id,
    lp.status_code
from ltc_project lpr
join ltc_process lp on lp.id=lpr.ltc_process_id
join project prj on prj.id=lpr.project_id
;