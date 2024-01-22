alter table lead_studies add (
	pc_activity_id   varchar2(50),
	pc_activity_type varchar2(50)
);
alter table lead_studies drop constraint lead_studies_chk1;
alter table lead_studies add constraint lead_studies_chk1 check 
(
	nvl2(fpfv_activity_id, fpfv_activity_type, 'Start Milestone') in ('Start Milestone', 'Finish Milestone') and
	nvl2(lplv_activity_id, lplv_activity_type, 'Start Milestone') in ('Start Milestone', 'Finish Milestone') and
	nvl2(lpfv_activity_id, lpfv_activity_type, 'Start Milestone') in ('Start Milestone', 'Finish Milestone') and
	nvl2(pc_activity_id, pc_activity_type, 'Start Milestone') in ('Start Milestone', 'Finish Milestone')
);