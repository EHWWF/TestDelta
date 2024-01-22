create table lead_studies(
	lsi_id nvarchar2(50) not null references lead_study_instance(id) on delete cascade,
	wbs_id nvarchar2(50) not null,
	fpfv_activity_id nvarchar2(50),
	lplv_activity_id nvarchar2(50),
	name nvarchar2(4000),
	unique (lsi_id,wbs_id)
);