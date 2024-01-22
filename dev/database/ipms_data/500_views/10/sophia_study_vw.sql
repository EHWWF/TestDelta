create or replace view sophia_study_vw as
select
	to_char(pf.project_id) as project_id,
	to_char(pf.study_id) as study_id,
	pf.plan_entered_trial,
	pf.act_entered_trial,
	to_char(rownum) as scd2_key,
	1 as current_flag,
	sysdate-365 as valid_from,
	sysdate+365 as valid_to,
	s.int_ext_flag,
	s.study_modus_no,
	s.study_modus_name,
	s.clin_plan_type,
	s.study_unit_count,
	s.study_unit_count_plan,
	s.therapeutic_group_code,
	s.therapeutic_group_desc,
	s.volunteer_flag,
	s.study_country_count,
	s.study_country_count_plan,
	s.subject_type,
	pf.plan_entered_screen,
	pf.act_entered_screen,
	s.branch_flag
from study@sophia_db s
join patient_figures@sophia_db pf on (s.study_id=pf.study_id);

drop table sophia_study_tmp;

create global temporary table sophia_study_tmp
on commit delete rows
as (select * from sophia_study_vw where 1=0);

create index sophia_study_tmp_idx1 on sophia_study_tmp(project_id);