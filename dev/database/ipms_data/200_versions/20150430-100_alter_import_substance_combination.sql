ALTER TABLE SUBSTANCE MODIFY CODE NVARCHAR2(120);
ALTER TABLE SUBSTANCE_COMBINATION MODIFY SUBSTANCE_CODE NVARCHAR2(120);
ALTER TABLE IMPORT_SUBSTANCE_COMBINATION MODIFY SUBSTANCE_CODE NVARCHAR2(120);