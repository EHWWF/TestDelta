alter table import_study
	add (volunteer_flag number)
	add (study_country_count number)
	add (study_country_count_plan number)
	add (subject_type nvarchar2(20))
	add (plan_entered_screen number)
	add (act_entered_screen number);
	
alter table study
	add (volunteer_flag number(1,0))
	add (study_country_count number)
	add (study_country_count_plan number)
	add (subject_type nvarchar2(20))
	add (plan_entered_screen number)
	add (act_entered_screen number);