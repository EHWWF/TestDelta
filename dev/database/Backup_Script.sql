prompt ---->START 
prompt ---->
prompt ---->
SET SCAN OFF;
ALTER TABLE project
DROP (
    DETAILS_OBJECTIVE,
    DETAILS_RATIONALE,	
    DETAILS_SCOPE,
    DETAILS_INTENDED_USE,
	DETAILS_BENEFITS,
    DETAILS_EXECUTIVE_SUMMARY,	
	DETAILS_RISKS,
    DETAILS_HIGHLIGHTS,
	DETAILS_ACTIVITIES_EVENTS,
    DETAILS_BUDGET,	
	DETAILS_SAMD_STATUS,
    DETAILS_BUDGET_STATUS
);


DELETE FROM IPMS_DATA.PHASE WHERE CODE LIKE 'SAMD.%';		-- 5 records to be removed
DELETE FROM IPMS_DATA.BUDGET_STATUS WHERE CODE IN('1','2','3');		-- 3 records to be removed
DELETE FROM IPMS_DATA.SAMD_STATUS WHERE CODE IN('1','2','3');		-- 3 records to be removed
DELETE FROM IPMS_DATA.MILESTONE WHERE TYPE_CODE = 'DEC-SAMD';		-- 26 record to be removed
DELETE FROM IPMS_DATA.PROJECT_AREA WHERE CODE ='SAMD';		-- 1 records to be removed
DELETE FROM IPMS_DATA.HELP_BUNDLE WHERE CODE IN('PROJECT_SAMD_OVERVIEW_CHARACTERISTICS','PROJECT_SAMD_OVERVIEW_PLANS');		-- 2 records to be removed
DELETE FROM IPMS_DATA.MILESTONE_TYPE WHERE CODE ='DEC-SAMD';		-- 1 records to be removed
DELETE FROM IPMS_DATA.PROJECT_AREA_MILESTONE WHERE AREA_CODE ='SAMD';		-- 1 records to be removed

DROP SEQUENCE  IPMS_DATA. COLLABORATION_ID_SEQ;
DROP SEQUENCE  IPMS_DATA. LICENSE_ID_SEQ;
DROP SEQUENCE  IPMS_DATA. PRJ_REL_DEV_ID_SEQ;
DROP SEQUENCE  IPMS_DATA. PRJ_REL_MSP_ID_SEQ;
DROP SEQUENCE  IPMS_DATA. PRJ_REL_PRED_ID_SEQ;
DROP SEQUENCE  IPMS_DATA. PRJ_REL_SUCC_ID_SEQ;
DROP SEQUENCE  IPMS_DATA. ROADMAP_ID_SEQ;

DROP TRIGGER IPMS_DATA.PROJECT_COLLABORATION_TR;
DROP TRIGGER IPMS_DATA.PROJECT_LICENSE_TR;
DROP TRIGGER IPMS_DATA.PROJECT_RELATED_DEV_TR;
DROP TRIGGER IPMS_DATA.PROJECT_RELATED_DEV_DEL_TR;
DROP TRIGGER IPMS_DATA.PROJECT_RELATED_MSP_TR;
DROP TRIGGER IPMS_DATA.PROJECT_RELATED_PRED_TR;
DROP TRIGGER IPMS_DATA.PROJECT_RELATED_SUCC_TR;
DROP TRIGGER IPMS_DATA.PROJECT_ROADMAP_TR;

DROP MATERIALIZED VIEW IPMS_REPO.LICENSE_DETAILS_DIM;
DROP MATERIALIZED VIEW IPMS_REPO.PROJECT_REL_PREDECESSOR_DIM;
DROP MATERIALIZED VIEW IPMS_REPO.PROJECT_REL_MSP_DEV_DIM;
DROP MATERIALIZED VIEW IPMS_REPO.PROJECT_REL_SUCCESSOR_DIM;
DROP MATERIALIZED VIEW IPMS_REPO.PROJECT_ROADMAP_DIM;
DROP MATERIALIZED VIEW IPMS_REPO.COLLABORATION_DETAILS_DIM;

DROP TABLE IPMS_REPO.COLLABORATION_DETAILS_DIM;
DROP TABLE IPMS_REPO.PROJECT_REL_MSP_DEV_DIM;
DROP TABLE IPMS_REPO.PROJECT_REL_PREDECESSOR_DIM;
DROP TABLE IPMS_REPO.PROJECT_REL_SUCCESSOR_DIM;
DROP TABLE IPMS_REPO.PROJECT_ROADMAP_DIM;

DROP TABLE IPMS_DATA.COLLABORATION_DETAILS;
DROP TABLE IPMS_DATA.LICENSE_DETAIL_TYPE;
DROP TABLE IPMS_DATA.LICENSE_DETAILS;
DROP TABLE IPMS_DATA.PARTNER;
DROP TABLE IPMS_DATA.PROJECT_RELATED_DEV;
DROP TABLE IPMS_DATA.PROJECT_RELATED_MSP;
DROP TABLE IPMS_DATA.PROJECT_RELATED_PREDECESSOR;
DROP TABLE IPMS_DATA.PROJECT_RELATED_SUCCESSOR;
DROP TABLE IPMS_DATA.BUDGET_STATUS;
DROP TABLE IPMS_DATA.PROJECT_ROADMAP;
DROP TABLE IPMS_DATA.SAMD_STATUS;



REVOKE select on COLLABORATION_DETAILS FROM ipms_repo;
REVOKE select on LICENSE_DETAILS FROM ipms_repo;
REVOKE select on PROJECT_RELATED_PREDECESSOR FROM ipms_repo;
REVOKE select on PROJECT_RELATED_DEV FROM ipms_repo;
REVOKE select on PROJECT_RELATED_MSP FROM ipms_repo;
REVOKE select on PROJECT_RELATED_SUCCESSOR FROM ipms_repo;
REVOKE select on PROJECT_ROADMAP FROM ipms_repo;



commit;
prompt ---->END 
prompt ---->
prompt ---->