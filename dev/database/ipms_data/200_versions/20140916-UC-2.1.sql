CREATE TABLE "IPMS_DATA"."PROJECT_AREA_MILESTONE"(
  "AREA_CODE" NVARCHAR2(10) NOT NULL REFERENCES "IPMS_DATA"."PROJECT_AREA" ("CODE"), 
  "MILESTONE_CODE" NVARCHAR2(10) NOT NULL REFERENCES "IPMS_DATA"."MILESTONE" ("CODE"), 
  PRIMARY KEY ("AREA_CODE", "MILESTONE_CODE")
);
