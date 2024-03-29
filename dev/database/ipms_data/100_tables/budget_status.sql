--------------------------------------------------------
--  File created - Monday-February-07-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table BUDGET_STATUS
--------------------------------------------------------

  CREATE TABLE IPMS_DATA.BUDGET_STATUS 
   (	CODE NVARCHAR2(10), 
	NAME NVARCHAR2(100), 
	IS_ACTIVE NUMBER(1,0) DEFAULT 1, 
	DESCRIPTION NVARCHAR2(500)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE USERS ;
  GRANT SELECT ON IPMS_DATA.BUDGET_STATUS TO MXCBI;
--------------------------------------------------------
--  DDL for Index SYS_C00260915
--------------------------------------------------------

  CREATE UNIQUE INDEX IPMS_DATA.SYS_C00260915 ON IPMS_DATA.BUDGET_STATUS (CODE) 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE USERS ;
--------------------------------------------------------
--  Constraints for Table BUDGET_STATUS
--------------------------------------------------------

  ALTER TABLE IPMS_DATA.BUDGET_STATUS MODIFY (CODE NOT NULL ENABLE);
  ALTER TABLE IPMS_DATA.BUDGET_STATUS MODIFY (NAME NOT NULL ENABLE);
  ALTER TABLE IPMS_DATA.BUDGET_STATUS MODIFY (IS_ACTIVE NOT NULL ENABLE);
  ALTER TABLE IPMS_DATA.BUDGET_STATUS ADD CHECK (is_active in (0,1)) ENABLE;
  ALTER TABLE IPMS_DATA.BUDGET_STATUS ADD PRIMARY KEY (CODE)
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE USERS  ENABLE;
