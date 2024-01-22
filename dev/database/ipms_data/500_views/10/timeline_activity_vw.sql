create or replace view timeline_activity_vw as
select
	tl.project_id,
	tl.id as timeline_id,
	tl.type_code timeline_type_code,
	xt.activity_id,
	xt.parent_wbs_id,
	xt.study_element_id,
	xt.type,
	xt.integration_type,
	xt.code,
	xt.name,
	xt.milestone_code,
	xt.phase_code,
	get_date(xt.plan_start_str) as plan_start,
	get_date(xt.plan_finish_str) as plan_finish,
	get_date(xt.actual_start_str) as actual_start,
	get_date(xt.actual_finish_str) as actual_finish
from
	timeline tl,
	xmltable(
		xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
		'/timeline/activities/activity' passing tl.details
		columns
			activity_id path '/activity/@id',
			parent_wbs_id path '/activity/@wbsId',
			study_element_id path '/activity/@studyElementId',
			type path '/activity/type',
			functions xmltype path '/activity/functions',
			integration_type path '/activity/integrationType',
			plan_start_str path '/activity/planStart',
			plan_finish_str path '/activity/planFinish',
			actual_start_str path '/activity/actualStart',
			actual_finish_str path '/activity/actualFinish',
			code path '/activity/code',
			name path '/activity/name',
			milestone_code path '/activity/milestoneCode',
			phase_code path '/activity/phaseCode'
	) xt
where tl.details is not null;
