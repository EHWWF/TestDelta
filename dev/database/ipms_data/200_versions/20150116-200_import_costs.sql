ALTER TABLE IMPORT_COSTS_GED MODIFY (STUDY_ID NVARCHAR2(100) );
ALTER TABLE IMPORT_COSTS_GED MODIFY (COMMITTED_STATE NVARCHAR2(120) );
ALTER TABLE COSTS_GED MODIFY (STUDY_ID NVARCHAR2(100) );
ALTER TABLE COSTS_GED MODIFY (COMMITTED_STATE NVARCHAR2(120) );
ALTER TABLE IMPORT_COSTS_CS MODIFY (STUDY_ID NVARCHAR2(100) );
ALTER TABLE IMPORT_COSTS_CS MODIFY (COMMITTED_STATE NVARCHAR2(120) );
ALTER TABLE COSTS_CS MODIFY (STUDY_ID NVARCHAR2(100) );
ALTER TABLE COSTS_CS MODIFY (COMMITTED_STATE NVARCHAR2(120) );