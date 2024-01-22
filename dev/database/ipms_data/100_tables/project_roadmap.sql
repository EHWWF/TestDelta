
  CREATE TABLE "IPMS_DATA"."PROJECT_ROADMAP" 
   (	"ID" NUMBER(10,0) NOT NULL ENABLE, 
	"PROJECT_ID" NVARCHAR2(20), 
	"DATE" DATE, 
	"TOPIC" NVARCHAR2(100), 
	"DESCRIPTION" NVARCHAR2(500), 
	"CREATE_USER_ID" NVARCHAR2(20), 
	"UPDATE_USER_ID" NVARCHAR2(20), 
	"CREATE_DATE" DATE DEFAULT SYSDATE, 
	"UPDATE_DATE" DATE DEFAULT SYSDATE, 
	 CONSTRAINT "PROJECT_ROADMAP_PK" PRIMARY KEY ("ID")
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
  TABLESPACE "USERS" ;

  CREATE INDEX "IPMS_DATA"."PROJECT_ID_FKI" ON "IPMS_DATA"."PROJECT_ROADMAP" ("PROJECT_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;


  GRANT SELECT ON "IPMS_DATA"."PROJECT_ROADMAP" TO "IPMS_REPO";
