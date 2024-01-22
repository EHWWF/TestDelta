create or replace view timeline_vw as
select 
	tl.*,
	sbx.sandbox_id, 
	nvl(sbx.src_project_id, project_id) as src_project_id,
	nvl(sbx.src_timeline_id, tl.id) as src_timeline_id,
	reference_id as root_wbs_id
from timeline tl
left join (
	select sbx.id as sandbox_id, sbx.snd_timeline_id as timeline_id, sbx.timeline_id as src_timeline_id, sbx_src_tl.project_id as src_project_id 
	from program_sandbox sbx
	inner join timeline sbx_src_tl on sbx_src_tl.id=sbx.timeline_id
) sbx on sbx.timeline_id=tl.id and tl.type_code='SND';