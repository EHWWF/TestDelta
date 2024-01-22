create or replace view timeline_wbs_vw as
select
	tl.project_id,
	tl.id as timeline_id,
	tl.type_code as timeline_type_code,
	xt.wbs_id,
	xt.parent_wbs_id,
	xt.study_id,
	xt.code,
	xt.name,
	get_date(xt.start_date_str) as start_date,
	get_date(xt.finish_date_str) as finish_date,
	xt.study_phase,
	xt.sequence_number,
	decode(xt.placeholder, 'true', 1, 0) as placeholder
from
	timeline tl,
	xmltable(
		xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
		'/timeline/wbsNodes/wbs' passing tl.details
		columns
			wbs_id path '/wbs/@id',
			parent_wbs_id path '/wbs/@parentId',
			study_id path '/wbs/@studyId',
			code path '/wbs/code',
			name path '/wbs/name',
			start_date_str path '/wbs/startDate',
			finish_date_str path '/wbs/finishDate',
			study_phase path '/wbs/studyPhase',
			sequence_number path '/wbs/sequenceNumber',
			placeholder path '/wbs/@placeholder'
	) xt
where tl.details is not null;