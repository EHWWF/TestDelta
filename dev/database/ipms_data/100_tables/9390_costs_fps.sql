CREATE SEQUENCE  "IPMS_DATA"."COSTS_ID_FPS_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999 INCREMENT BY 1 START WITH 1;

CREATE TABLE "IPMS_DATA"."COSTS_FPS" 
   ("ID" NVARCHAR2(20) NOT NULL ENABLE, 
	"PROJECT_ID" NVARCHAR2(20) NOT NULL ENABLE, 
	"STUDY_ID" NVARCHAR2(100), 
	"SUBFUNCTION_CODE" NVARCHAR2(10), 
	"FUNCTION_CODE" NVARCHAR2(10), 
	"SCOPE_CODE" NVARCHAR2(10) NOT NULL ENABLE, 
	"METHOD_CODE" NVARCHAR2(10) NOT NULL ENABLE, 
	"TYPE_CODE" NVARCHAR2(10) NOT NULL ENABLE, 
	"SUBTYPE_CODE" NVARCHAR2(10), 
	"COST" NUMBER(20,10) NOT NULL ENABLE, 
	"COMMITTED_STATE" NVARCHAR2(120), 
	"START_DATE" DATE NOT NULL ENABLE, 
	"FINISH_DATE" DATE NOT NULL ENABLE, 
	"CREATE_USER_ID" NVARCHAR2(20) DEFAULT 'IPMS' NOT NULL ENABLE, 
	"UPDATE_USER_ID" NVARCHAR2(20), 
	"CREATE_DATE" DATE DEFAULT sysdate NOT NULL ENABLE, 
	"UPDATE_DATE" DATE, 
	 PRIMARY KEY ("ID"),
	 FOREIGN KEY ("PROJECT_ID")
	  REFERENCES "IPMS_DATA"."PROJECT" ("ID") ON DELETE CASCADE ENABLE, 
	 FOREIGN KEY ("SUBFUNCTION_CODE")
	  REFERENCES "IPMS_DATA"."SUBFUNCTION" ("CODE") ENABLE, 
	 FOREIGN KEY ("SCOPE_CODE")
	  REFERENCES "IPMS_DATA"."COSTS_SCOPE" ("CODE") ENABLE, 
	 FOREIGN KEY ("METHOD_CODE")
	  REFERENCES "IPMS_DATA"."CALCULATION_METHOD" ("CODE") ENABLE, 
	 FOREIGN KEY ("TYPE_CODE")
	  REFERENCES "IPMS_DATA"."COSTS_TYPE" ("CODE") ENABLE, 
	 FOREIGN KEY ("SUBTYPE_CODE")
	  REFERENCES "IPMS_DATA"."COSTS_SUBTYPE" ("CODE") ENABLE
   );
   
create index costs_fpx_idx1 on costs_fps(project_id);