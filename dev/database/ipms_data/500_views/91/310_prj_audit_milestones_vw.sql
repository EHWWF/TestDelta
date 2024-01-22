create or replace view prj_audit_milestones_vw
as
select
	audit_id,
	prj_id,
	ms_type_code,
	ms_code,
	ms_name,
	decode(sele_ms_plan,prev_ms_plan,replace(sele_ms_plan,'null'), prev_ms_plan||' >>> '||sele_ms_plan) ms_plan,
	decode(sele_ms_achieved,prev_ms_achieved,replace(sele_ms_achieved,'null'), prev_ms_achieved||' >>> '||sele_ms_achieved) ms_achieved
from (
	select
		mbase.id audit_id,
		mbase.parent_id,
		mbase.type_code ms_type_code,
		mbase.code ms_code,
		mbase.name ms_name,
		nvl(sele.prj_id,prev.prj_id) prj_id,
		nvl(sele.ms_plan,'null') sele_ms_plan,
		nvl(sele.ms_achieved,'null') sele_ms_achieved,
		nvl(prev.ms_plan,'null') prev_ms_plan,
		nvl(prev.ms_achieved,'null') prev_ms_achieved
	from ( 
		select m.*, pa.* from milestone m
		cross join (select id, parent_id from project_audit) pa
	) mbase
	left join prj_audit_milestones_src_vw sele on (sele.ms_code=mbase.code and sele.ms_type_code=mbase.type_code and sele.audit_id=mbase.id)
	left join prj_audit_milestones_src_vw prev on (prev.ms_code=mbase.code and prev.ms_type_code=mbase.type_code and prev.audit_id=mbase.parent_id)
	where sele.ms_plan||sele.ms_achieved||prev.ms_plan||prev.ms_achieved is not null
);