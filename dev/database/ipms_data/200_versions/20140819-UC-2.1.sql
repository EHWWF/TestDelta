CREATE TABLE "IPMS_DATA"."GENERIC_TIMELINE" (
  project_id nvarchar2(20) NOT NULL REFERENCES "IPMS_DATA"."PROJECT"(id),
  milestone_code nvarchar2(10) NOT NULL REFERENCES "IPMS_DATA"."MILESTONE"(code),
  generic_date DATE,
  PRIMARY KEY(project_id,milestone_code)
);

