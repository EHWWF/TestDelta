CREATE OR REPLACE view goal_vw as
  SELECT "ID",
          "GOAL",
          "PROJECT_ID",
		  "TYPE",
		  "PHASE",
          "STUDY_ID",
          "PLAN_REFERENCE",
          to_char(PLAN_REFERENCE_DATE,'dd-Mon-yyyy') || ' ' || decode(ref_date_type,'A','A',null) as "PLAN_REFERENCE_DATE", 
          GS.CODE AS "STATUS",
          "TARGET_DATE",
          "ACHIEVED_DATE",
          "REVISED_DATE",
          "COMMENTS",
		  extract(YEAR from TARGET_DATE) as TARGET_YEAR,
    is_manual_status
   FROM GOAL G
   JOIN GOAL_STATUS GS ON G.STATUS = GS.CODE;