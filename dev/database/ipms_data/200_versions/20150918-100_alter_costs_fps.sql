alter table import_costs_fps add(ged_study_id nvarchar2(100)); 
alter table costs_fps add(ged_study_id nvarchar2(100));
comment on column costs_fps.ged_study_id is 'IPMS_REPO needs splitting in separate collumn study_id and in separate ged_study_id, see:PROMIS-421';