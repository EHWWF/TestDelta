
  CREATE TABLE "IPMS_DATA"."TEAM_ROLE" 
   (	"CODE" NVARCHAR2(20) NOT NULL ENABLE, 
	"NAME" NVARCHAR2(100) NOT NULL ENABLE, 
	"IS_ACTIVE" NUMBER(1,0) DEFAULT 1 NOT NULL ENABLE, 
	"DESCRIPTION" NVARCHAR2(500), 
	"IS_DEV_RELEVANT" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE, 
	"IS_PRDMNT_RELEVANT" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE, 
	"IS_D2PRJ_RELEVANT" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE, 
	"IS_SAMD_RELEVANT" NUMBER(1,0) DEFAULT 0 NOT NULL ENABLE, 
	 CHECK (is_active in (0,1)) ENABLE, 
	 PRIMARY KEY ("CODE")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" FLASHBACK ARCHIVE "FDA_ADM";




  GRANT SELECT ON "IPMS_DATA"."TEAM_ROLE" TO "PROJEX_ARCHIVE";
  GRANT SELECT ON "IPMS_DATA"."TEAM_ROLE" TO "MYCSD";
  GRANT SELECT ON "IPMS_DATA"."TEAM_ROLE" TO "IPMS_REPO";
  GRANT SELECT ON "IPMS_DATA"."TEAM_ROLE" TO "MXCBI";
  GRANT SELECT ON "IPMS_DATA"."TEAM_ROLE" TO "PMO_READ";