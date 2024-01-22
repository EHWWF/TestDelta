alter table lead_study_map add (dev_mlstn_type nvarchar2(50));
update lead_study_map set dev_mlstn_type='Start Milestone';
alter table lead_study_map add constraint lead_study_map_chk1 check(dev_mlstn_type in ('Start Milestone','Finish Milestone'));

alter table lead_studies add (fpfv_activity_type nvarchar2(50),lplv_activity_type nvarchar2(50),lpfv_activity_type nvarchar2(50));
update lead_studies set fpfv_activity_type='Start Milestone', lplv_activity_type='Start Milestone', lpfv_activity_type='Start Milestone';
alter table lead_studies add constraint lead_studies_chk1 check(nvl2(fpfv_activity_id,fpfv_activity_type,'Start Milestone') in ('Start Milestone','Finish Milestone') and nvl2(lplv_activity_id,lplv_activity_type,'Start Milestone') in ('Start Milestone','Finish Milestone') and nvl2(lpfv_activity_id,lpfv_activity_type,'Start Milestone') in ('Start Milestone','Finish Milestone'));

alter table lead_study_config drop column relationship_type;
