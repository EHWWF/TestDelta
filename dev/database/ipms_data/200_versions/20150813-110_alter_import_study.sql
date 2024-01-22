alter table import_study 
	add(action_code nvarchar2(10) check(action_code in ('SKIP','APPLY')))
	-- TODO: Add reference to import_action ?
	add(study_template_id nvarchar2(20) references study_template(id))
	add(parent_wbs_id nvarchar2(20));
