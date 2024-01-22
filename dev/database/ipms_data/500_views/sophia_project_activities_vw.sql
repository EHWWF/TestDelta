  CREATE OR REPLACE FORCE EDITIONABLE VIEW "IPMS_DATA"."SOPHIA_PROJECT_ACTIVITIES_VW" ("ARTIFICIAL_ID", "PROJECT_ID", "PROJECT_ACTIVITY_ID", "PROJECT_ACTIVITY_NAME", "STUDY_ID", "PLAN_START_DATE", "PLAN_FINISH_DATE", "ACT_START_DATE", "ACT_FINISH_DATE", "WBS_CATEGORY") AS 
  select
	 prj.id||':'||pa.project_activity_id||':'||pa.study_id||':'||mls.wbs_category artificial_id,
	 prj.id as project_id,
	 pa.project_activity_id,
	 nvl2(pa.study_id,pa.study_id||': ','')||pa.project_activity_name as project_activity_name,
	 pa.study_id,
	 pa.plan_start_date,
	 pa.plan_finish_date,
	 pa.act_start_date,
	 pa.act_finish_date,
	 mls.wbs_category
 from project_activities@sophia_db pa
	 join project prj on to_char(pa.project_id) = to_char(prj.code)
	 left join milestone mls on mls.code = pa.decision_start and mls.is_active = 1
	where pa.decision_start not in ('D1','D2');