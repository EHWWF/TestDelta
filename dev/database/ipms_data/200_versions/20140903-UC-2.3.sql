ALTER TABLE "IPMS_DATA"."COSTS_PROBABILITY" ADD ("SBE_CODE" nvarchar2(10) references Strategic_Business_Entity(code));
ALTER TABLE "IPMS_DATA"."COSTS_PROBABILITY" ADD ("SUBSTANCE_TYPE_CODE" nvarchar2(10) references Substance_Type(code));


DECLARE
	unique_name nvarchar2(30);
BEGIN
	SELECT constraint_name INTO unique_name FROM user_constraints WHERE table_name='COSTS_PROBABILITY' and constraint_type='U';
	EXECUTE IMMEDIATE 'ALTER TABLE COSTS_PROBABILITY DROP CONSTRAINT '||unique_name;
  EXECUTE IMMEDIATE 'ALTER TABLE COSTS_PROBABILITY ADD CONSTRAINT  '||unique_name||' UNIQUE (scope_code,project_id,phase_code,sbe_code,substance_type_code,function_code,rule_code,lag)';
END;
/


