--------------------------------------------------------
--  File created - Tuesday-February-01-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View PRJ_INDICATION_VW
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "IPMS_DATA"."PRJ_INDICATION_VW" ("PROJECT_ID", "PROJECT_NAME", "BAY_NO", "PROJECT_INDICATION", "MESH_TERM") AS 
  select expt.PROJECT_ID, 
prj.name PROJECT_NAME, 
bn.NAME BAY_NO,
expt.TPP_INDICATION PROJECT_INDICATION, 
prj.details_mesh MESH_TERM
from EXPORT_TPP_HEADER expt, PROJECT prj, BAY_NUMBER bn
where 
prj.BAY_CODE = bn.CODE and
prj.CODE = expt.PROJECT_ID and
expt.APPROVAL_DATE is not null 
and expt.TPP_VERSION_ID = 
nvl((select TPP_VERSION_ID from EXPORT_TPP_HEADER where PROJECT_ID = expt.PROJECT_ID and upper(TPP_VERSION_ID)='CURRENT' and APPROVAL_DATE is not null and ROWNUM=1),
(select max(sub.TPP_VERSION_ID) from EXPORT_TPP_HEADER sub where sub.PROJECT_ID = expt.PROJECT_ID and upper(sub.TPP_VERSION_ID) !='CURRENT' and sub.APPROVAL_DATE = (select max(APPROVAL_DATE) 
from EXPORT_TPP_HEADER where PROJECT_ID= sub.PROJECT_ID)))
;
  GRANT SELECT ON "IPMS_DATA"."PRJ_INDICATION_VW" TO "MXCBI";
