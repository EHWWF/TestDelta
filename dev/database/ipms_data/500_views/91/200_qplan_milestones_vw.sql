create or replace view qplan_milestones_vw as
with project_milestone_config as (
		select 
			p.id as project_id, p.area_code, p.gt_timeline_type as timeline_type_code,
			--decode(qe.milestone_code, 'M9', 'D9', qe.milestone_code) as timeline_milestone_code,
			qe.milestone_code as timeline_milestone_code,
			--decode(qe.milestone_code, 'FiM-RC', 'toxFimRC', qe.milestone_code) as qplan_milestone_code
			--IPMSSUP-5144; Old change PLATOPCD-156
			qe.milestone_code as qplan_milestone_code
		from project p
		inner join project_area_qplan_config paqc on (paqc.area_code=p.area_code)
		inner join qplan_element_type qe on (qe.code=paqc.element_code)
		where qe.is_active=1 
		and qe.milestone_code is not null
	),
	project_timeline as (
		select pmc.project_id, tl.milestone_code, tl.plan_date, tl.actual_date
		from project_milestone_config pmc
		inner join milestone_vw tl on tl.project_id=pmc.project_id and tl.timeline_type_code=pmc.timeline_type_code and tl.milestone_code=pmc.timeline_milestone_code		
	)
select 
	pmc.project_id,	pmc.area_code, 
	pmc.qplan_milestone_code as milestone_code,
	pt.plan_date, pt.actual_date,
	gt.generic_date
from project_milestone_config pmc
left join project_timeline pt on pt.project_id=pmc.project_id and pt.milestone_code=pmc.timeline_milestone_code
left join generic_timeline gt on gt.project_id=pmc.project_id and gt.milestone_code=pmc.timeline_milestone_code;