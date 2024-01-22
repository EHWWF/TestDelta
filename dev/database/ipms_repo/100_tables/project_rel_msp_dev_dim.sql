--------------------------------------------------------
--  File created - Wednesday-July-13-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table PROJECT_REL_MSP_DEV_DIM
--------------------------------------------------------

  CREATE TABLE "IPMS_REPO"."PROJECT_REL_MSP_DEV_DIM" 
   (	"ID" NUMBER, 
	"MSP_PROJECT_ID" NVARCHAR2(20), 
	"MSP_CODE" NVARCHAR2(20), 
	"DEV_PROJECT_ID" VARCHAR2(10 BYTE), 
	"DEV_PROJECT_CODE" NVARCHAR2(20)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"   NO INMEMORY ;
  GRANT SELECT ON "IPMS_REPO"."PROJECT_REL_MSP_DEV_DIM" TO "MYCSD";
--------------------------------------------------------
--  Constraints for Table PROJECT_REL_MSP_DEV_DIM
--------------------------------------------------------

  ALTER TABLE "IPMS_REPO"."PROJECT_REL_MSP_DEV_DIM" MODIFY ("MSP_PROJECT_ID" NOT NULL ENABLE);
  ALTER TABLE "IPMS_REPO"."PROJECT_REL_MSP_DEV_DIM" MODIFY ("DEV_PROJECT_ID" NOT NULL ENABLE);
