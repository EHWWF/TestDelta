drop materialized view study_dim;
CREATE MATERIALIZED VIEW "IPMS_REPO"."STUDY_DIM" ("STUDY_ID", "LATEST_STUDY", "WBS_ID", "PROJECT_ID", "TIMELINE_ID", "TIMELINE_TYPE_CODE", "NAME", "STUDY_NAME", "PHASE", "START_DATE", "FINISH_DATE", "FPFV", "LPLV", "DMC_PLAN", "DMC_ACTUAL", "STATUS_CODE", "STATUS", "IS_OBLIGATION", "IS_PROBING", "IS_GPDC_APPROVED", "MMU_CODE", "MMU_NAME", "STUDY_MODUS_NAME", "CLIN_PLAN_TYPE", "PLAN_PATIENTS", "ACTUAL_PATIENTS", "STUDY_UNIT_COUNT", "STUDY_UNIT_COUNT_PLAN", "INT_EXT_FLAG", "CSRAPP", "PRCOMPL", "CDBLOCK", "IS_LEAD", "FTE_AVG", "IS_TIMELINE_AUTO_IMPORT")
  ORGANIZATION HEAP PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" 
  BUILD IMMEDIATE
  USING INDEX 
  REFRESH FORCE ON DEMAND
  USING DEFAULT LOCAL ROLLBACK SEGMENT
  USING ENFORCED CONSTRAINTS DISABLE ON QUERY COMPUTATION DISABLE QUERY REWRITE
  AS select
	cast(STUDY_ID as varchar2(100)) study_id,
	LATEST_STUDY,
	WBS_ID,
	PROJECT_ID,
	TIMELINE_ID,
	TIMELINE_TYPE_CODE,
	cast(NAME as varchar2(100)) NAME,
	cast(STUDY_NAME as varchar2(120)) STUDY_NAME,
	PHASE,
	START_DATE,
	FINISH_DATE,
	FPFV,
	LPLV,
	DMC_PLAN,
	DMC_ACTUAL,
	STATUS_CODE,
	STATUS,
	IS_OBLIGATION,
	IS_PROBING,
	IS_GPDC_APPROVED,
	MMU_CODE,
	MMU_NAME,
	STUDY_MODUS_NAME,
	CLIN_PLAN_TYPE,
	PLAN_PATIENTS,
	ACTUAL_PATIENTS,
	STUDY_UNIT_COUNT,
	STUDY_UNIT_COUNT_PLAN,
	INT_EXT_FLAG,
	CSRAPP,
	PRCOMPL,
	CDBLOCK,
	IS_LEAD,
	FTE_AVG,
    IS_TIMELINE_AUTO_IMPORT
from (
select
	STUDY_ID,
	LATEST_STUDY,
	WBS_ID,
	PROJECT_ID,
	TIMELINE_ID,
	TIMELINE_TYPE_CODE,
	NAME,
	STUDY_NAME,
	PHASE,
	START_DATE,
	FINISH_DATE,
	FPFV,
	LPLV,
	DMC_PLAN,
	DMC_ACTUAL,
	STATUS_CODE,
	STATUS,
	IS_OBLIGATION,
	IS_PROBING,
	IS_GPDC_APPROVED,
	MMU_CODE,
	MMU_NAME,
	STUDY_MODUS_NAME,
	CLIN_PLAN_TYPE,
	PLAN_PATIENTS,
	ACTUAL_PATIENTS,
	STUDY_UNIT_COUNT,
	STUDY_UNIT_COUNT_PLAN,
	INT_EXT_FLAG,
	CSRAPP,
	PRCOMPL,
	CDBLOCK,
	IS_LEAD,
	FTE_AVG,
    IS_TIMELINE_AUTO_IMPORT
from study_dim_vw
	union all
select
	to_char(stminus.study_id) STUDY_ID,
	to_number(null) LATEST_STUDY,
	to_char(null) WBS_ID,
	to_nchar(st.project_id) PROJECT_ID,
	to_char(null) TIMELINE_ID,
	to_char(null) TIMELINE_TYPE_CODE,
	to_char(nvl(st.study_name, 'Study name is missing')) NAME,
	to_char(nvl(st.study_name, 'Study name is missing')) STUDY_NAME,
	to_char(null) PHASE,
	to_date(null) START_DATE,
	to_date(null) FINISH_DATE,
	to_date(null) FPFV,
	to_date(null) LPLV,
	to_date(null) DMC_PLAN,
	to_date(null) DMC_ACTUAL,
	to_char(null) STATUS_CODE,
	to_nchar(null) STATUS,
	to_number(null) IS_OBLIGATION,
	to_number(null) IS_PROBING,
	to_number(null) IS_GPDC_APPROVED,
	to_nchar(null) MMU_CODE,
	to_nchar(null) MMU_NAME,
	to_nchar(null) STUDY_MODUS_NAME,
	to_nchar(null) CLIN_PLAN_TYPE,
	to_number(null) PLAN_PATIENTS,
	to_number(null) ACTUAL_PATIENTS,
	to_number(null) STUDY_UNIT_COUNT,
	to_number(null) STUDY_UNIT_COUNT_PLAN,
	to_nchar(null) INT_EXT_FLAG,
	null CSRAPP,
	null PRCOMPL,
	null CDBLOCK,
	null IS_LEAD,
	to_number(null) FTE_AVG,
    to_number(null) IS_TIMELINE_AUTO_IMPORT
from (
select study_id
from (
(select distinct to_char(study_id) study_id from COST_FCT)
union all
(select distinct to_char(study_id) study_id from COST_FPS_FCT)
union all
(select distinct to_char(study_id) study_id from COST_LTC_FCT)
union all
(select distinct to_char(study_id) study_id from COST_LTC_FTE_FCT)
union all
(select distinct to_char(study_id) study_id from LATEST_ESTIMATE_FCT)
union all
(select distinct to_char(study_id) study_id from MILESTONE_FCT)
--union all
--(select distinct to_char(study_id) study_id from MILESTONE_IMPACT_FCT)
union all
(select distinct to_char(study_id) study_id from PROJECT_ACTIVITY_DIM)
union all
(select distinct to_char(study_id) study_id from RESOURCE_CS_FCT)
union all
(select distinct to_char(study_id) study_id from RESOURCE_FCT)
union all
(select distinct to_char(study_id) study_id from RESOURCE_GED_FCT)
union all
(select distinct to_char(study_id) study_id from STUDY_MILESTONE_FCT)
) where study_id is not null
minus
select distinct to_char(study_id) study_id from study_dim_vw
) stminus
left join ipms_data.study st on (st.id=stminus.study_id)
);

   COMMENT ON MATERIALIZED VIEW "IPMS_REPO"."STUDY_DIM"  IS 'Note:Use_in_planning is not imported. Skipped by BHC. Rank ordering by:1-APR,2-CUR,3-RAW.';


  GRANT SELECT ON "IPMS_REPO"."STUDY_DIM" TO "PMO_READ";
  GRANT SELECT ON "IPMS_REPO"."STUDY_DIM" TO "MYCSD";
  GRANT SELECT ON "IPMS_REPO"."STUDY_DIM" TO "MXCBI";