--------------------------------------------------------
--  File created - Wednesday-July-13-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table PROJECT_ROADMAP_DIM
--------------------------------------------------------

  CREATE TABLE "IPMS_REPO"."PROJECT_ROADMAP_DIM" 
   (	"ID" NUMBER(10,0), 
	"PROJECT_ID" NVARCHAR2(20), 
	"CODE" NVARCHAR2(20), 
	"DATE" DATE, 
	"TOPIC" NVARCHAR2(100), 
	"DESCRIPTION" NVARCHAR2(500)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"   NO INMEMORY ;
  GRANT SELECT ON "IPMS_REPO"."PROJECT_ROADMAP_DIM" TO "MYCSD";
--------------------------------------------------------
--  Constraints for Table PROJECT_ROADMAP_DIM
--------------------------------------------------------

  ALTER TABLE "IPMS_REPO"."PROJECT_ROADMAP_DIM" MODIFY ("ID" NOT NULL ENABLE);
