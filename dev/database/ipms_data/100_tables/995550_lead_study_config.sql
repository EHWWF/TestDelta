create table lead_study_config(
	dev_mlstn_code nvarchar2(15) not null references milestone(code),
	study_phase_name nvarchar2(50) not null,
	drv_mlstn_code nvarchar2(15));