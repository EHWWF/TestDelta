create or replace force view discrepancy_timeline2_vw as
select 
	replace(dis_type_code||is_import_study||dis_code||project_id||study_id||study_element_id||
				timeline_id||reference_id||integration_type||timeline_code||study_modus_name||
				clin_plan_type||to_char(plan_start,'J')||to_char(plan_finish,'J')||
				to_char(actual_start,'J')||to_char(actual_finish,'J'),' ') as id,
	dis_type_code, 
	is_import_study, 
	dis_code, 
	description, 
	verbose, 
	solution, 
	project_id, 
	study_id, 
	study_element_id, 
	timeline_id, 
	reference_id, 
	integration_type, 
	plan_start, 
	plan_finish, 
	actual_start, 
	actual_finish, 
	timeline_code, 
	timeline_name, 
	study_modus_name, 
	clin_plan_type, 
	use_in_planning, 
	fpfv_date, 
	sophia_cnt, 
	p6_cnt
from (
	select
		distinct dis_type_code, --should not be the case for DISTINCT but better to have it
		is_import_study, 
		dis_code, 
		description, 
		verbose, 
		solution, 
		project_id, 
		study_id, 
		study_element_id, 
		timeline_id, 
		reference_id, 
		integration_type, 
		plan_start, 
		plan_finish, 
		actual_start, 
		actual_finish, 
		timeline_code, 
		timeline_name, 
		study_modus_name, 
		clin_plan_type, 
		use_in_planning, 
		fpfv_date, 
		sophia_cnt, 
		p6_cnt
	from discrepancy_timeline1_vw
	);