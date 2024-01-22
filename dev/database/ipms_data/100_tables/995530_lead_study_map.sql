create table lead_study_map (
	lsi_id nvarchar2(50) not null references lead_study_instance(id) on delete cascade,
	dev_mlstn_code nvarchar2(150) not null,
	dev_mlstn_activity_id nvarchar2(50) not null,
	curr_study_wbs_id nvarchar2(50),
	new_study_wbs_id nvarchar2(50)
);