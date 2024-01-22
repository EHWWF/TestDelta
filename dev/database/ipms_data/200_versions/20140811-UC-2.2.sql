ALTER TABLE "IPMS_DATA"."PHASE_MILESTONE" ADD ("CATEGORY" nvarchar2(2) DEFAULT 'CF' NOT NULL CHECK("CATEGORY" in ('CF','GT')));

DECLARE
	pk_name nvarchar2(30);
BEGIN
	SELECT constraint_name INTO pk_name FROM user_constraints WHERE table_name='PHASE_MILESTONE' and constraint_type='P';
	EXECUTE IMMEDIATE 'ALTER TABLE PHASE_MILESTONE DROP CONSTRAINT '||pk_name;
END;
/

ALTER TABLE "IPMS_DATA"."PHASE_MILESTONE" ADD PRIMARY KEY (phase_code, milestone_code, category);

CREATE TABLE "IPMS_DATA"."PHASE_DURATION" (
	id nvarchar2(20) NOT NULL PRIMARY KEY,
	sbe_code nvarchar2(10) REFERENCES "IPMS_DATA"."STRATEGIC_BUSINESS_ENTITY"(code),
	substance_type_code nvarchar2(10) REFERENCES "IPMS_DATA"."SUBSTANCE_TYPE"(code),
	phase_code nvarchar2(10) NOT NULL REFERENCES "IPMS_DATA"."PHASE"(code),
	duration NUMBER(10) DEFAULT 0 NOT NULL,
	UNIQUE(sbe_code,substance_type_code,phase_code));

CREATE SEQUENCE Phase_Duration_Id_SEQ MAXVALUE 9999999999999999999 MINVALUE 1 CYCLE;