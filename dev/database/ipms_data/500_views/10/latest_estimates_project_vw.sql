create or replace view latest_estimates_project_vw as
select lep.let_id tag_id,
		lep.id process_id,
		prj.id project_id,
		prj.program_id program_id
from latest_estimates_project lepr
join latest_estimates_process lep on lep.id=lepr.process_id
join project prj on prj.id=lepr.project_id;