create or replace view ingredient_vw as
select
	sb.substance_code,
	prj.id as project_id
from project prj
join project_substance_code sb on (prj.id=sb.project_id);