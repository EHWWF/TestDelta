--------------------------------------------------------
--  DDL for Materialized View PROJECT_REL_MSP_DEV_DIM
--------------------------------------------------------

  CREATE MATERIALIZED VIEW IPMS_REPO.PROJECT_REL_MSP_DEV_DIM (ID, MSP_PROJECT_ID, MSP_CODE, DEV_PROJECT_ID, DEV_PROJECT_CODE)
  ORGANIZATION HEAP PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE USERS   NO INMEMORY 
  BUILD IMMEDIATE
  USING INDEX 
  REFRESH FORCE ON DEMAND
  USING DEFAULT LOCAL ROLLBACK SEGMENT
  USING ENFORCED CONSTRAINTS DISABLE ON QUERY COMPUTATION DISABLE QUERY REWRITE
  AS select
PRD.ID, 
PRD.PROJECT_ID MSP_PROJECT_ID, 
PR.CODE MSP_CODE,
PRD.DEV_PROJECT_ID,
PR1.CODE DEV_PROJECT_CODE
from ipms_data.PROJECT_RELATED_DEV PRD
left join ipms_data.project PR on PRD.PROJECT_ID=PR.ID
left join ipms_data.project PR1 on PR1.ID=PRD.DEV_PROJECT_ID;

   COMMENT ON MATERIALIZED VIEW IPMS_REPO.PROJECT_REL_MSP_DEV_DIM  IS 'snapshot table for snapshot IPMS_REPO.PROJECT_REL_MSP_DEV_DIM';
  GRANT SELECT ON IPMS_REPO.PROJECT_REL_MSP_DEV_DIM TO MYCSD;