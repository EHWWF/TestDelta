DECLARE
	pk_name nvarchar2(30);
BEGIN
	SELECT constraint_name INTO pk_name FROM user_constraints WHERE table_name='PHASE_MILESTONE' and constraint_type='P';
	EXECUTE IMMEDIATE 'ALTER TABLE PHASE_MILESTONE DROP CONSTRAINT '||pk_name;
END;
/

ALTER TABLE "IPMS_DATA"."PHASE_MILESTONE" ADD PRIMARY KEY (phase_code, category);
