prompt ---->START 
prompt ---->
prompt ---->
SET SCAN OFF;
INSERT INTO IPMS_DATA.PHASE (CODE, NAME, IS_ACTIVE, ORDERING) VALUES ('SAMD.1', 'Ideation', '1', 150);
INSERT INTO IPMS_DATA.PHASE (CODE, NAME, IS_ACTIVE, ORDERING) VALUES ('SAMD.2', 'Feasibility/Concept Finalization', '1', 160);
INSERT INTO IPMS_DATA.PHASE (CODE, NAME, IS_ACTIVE, ORDERING) VALUES ('SAMD.3', 'Product Development', '1', 170);
INSERT INTO IPMS_DATA.PHASE (CODE, NAME, IS_ACTIVE, ORDERING) VALUES ('SAMD.4', 'Product Deployment & Localization', '1', 180);
INSERT INTO IPMS_DATA.PHASE (CODE, NAME, IS_ACTIVE, ORDERING) VALUES ('SAMD.5', 'Life Cycle Management', '1', 190);



INSERT INTO IPMS_DATA.BUDGET_STATUS (CODE, NAME, IS_ACTIVE) VALUES ('1', 'On track', '1');
INSERT INTO IPMS_DATA.BUDGET_STATUS (CODE, NAME, IS_ACTIVE) VALUES ('2', 'At risk', '1');
INSERT INTO IPMS_DATA.BUDGET_STATUS (CODE, NAME, IS_ACTIVE) VALUES ('3', 'Off truck', '1');


INSERT INTO IPMS_DATA.SAMD_STATUS (CODE, NAME, IS_ACTIVE) VALUES ('1', 'On track', '1');
INSERT INTO IPMS_DATA.SAMD_STATUS (CODE, NAME, IS_ACTIVE) VALUES ('2', 'At risk', '1');
INSERT INTO IPMS_DATA.SAMD_STATUS (CODE, NAME) VALUES ('3', 'Off truck');

Insert into IPMS_DATA.MILESTONE_TYPE (CODE,NAME,IS_ACTIVE) values ('DEC-SAMD','SaMD Decision',1);

INSERT INTO IPMS_DATA.PROJECT_AREA (CODE, NAME, IS_RUNNING_IMPORT) VALUES ('SAMD', 'SaMD', 'SAMD');

INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS0', 'MS0', 'DEC-SAMD', '1', '680');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS1', 'MS1', 'DEC-SAMD', '1', '690');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS2', 'MS2', 'DEC-SAMD', '1', '700');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3a', 'MS3a', 'DEC-SAMD', '1', '710');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3b', 'MS3b', 'DEC-SAMD', '1', '720');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3c', 'MS3c', 'DEC-SAMD', '1', '730');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3d', 'MS3d', 'DEC-SAMD', '1', '740');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3e', 'MS3e', 'DEC-SAMD', '1', '750');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3f', 'MS3f', 'DEC-SAMD', '1', '760');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3g', 'MS3g', 'DEC-SAMD', '1', '770');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3h', 'MS3h', 'DEC-SAMD', '1', '780');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3i', 'MS3i', 'DEC-SAMD', '1', '790');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3j', 'MS3j', 'DEC-SAMD', '1', '800');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3k', 'MS3k', 'DEC-SAMD', '1', '810');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3m', 'MS3m', 'DEC-SAMD', '1', '820');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3n', 'MS3n', 'DEC-SAMD', '1', '830');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3o', 'MS3o', 'DEC-SAMD', '1', '840');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3p', 'MS3p', 'DEC-SAMD', '1', '850');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3q', 'MS3q', 'DEC-SAMD', '1', '860');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3r', 'MS3r', 'DEC-SAMD', '1', '870');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3s', 'MS3s', 'DEC-SAMD', '1', '880');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3t', 'MS3t', 'DEC-SAMD', '1', '890');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3u', 'MS3u', 'DEC-SAMD', '1', '900');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3v', 'MS3v', 'DEC-SAMD', '1', '910');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3w', 'MS3w', 'DEC-SAMD', '1', '920');
INSERT INTO IPMS_DATA.MILESTONE (CODE, NAME, TYPE_CODE, IS_ACTIVE, ORDERING) VALUES ('MS3x', 'MS3x', 'DEC-SAMD', '1', '930');



Insert into HELP_BUNDLE (CODE,NAME,DEFINITION,URL) values ('PROJECT_SAMD_OVERVIEW_CHARACTERISTICS','SaMD Project -> Overview -> Characteristics','Help','http://sp-coll-bhc.bayer-ag.com/sites/221953/ProMIS_UserGuide/Under%20Construction.aspx');
Insert into HELP_BUNDLE (CODE,NAME,DEFINITION,URL) values ('PROJECT_SAMD_OVERVIEW_PLANS','SaMD Project -> Overview -> Plan Versions','Help','http://sp-coll-bhc.bayer-ag.com/sites/221953/ProMIS_UserGuide/Under%20Construction.aspx');


Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS0');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS1');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS2');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3a');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3b');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3c');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3d');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3e');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3f');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3g');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3h');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3i');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3j');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3k');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3l');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3m');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3n');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3o');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3p');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3q');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3r');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3s');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3t');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3u');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3v');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3w');
Insert into IPMS_DATA.PROJECT_AREA_MILESTONE (AREA_CODE,MILESTONE_CODE) values ('SAMD','MS3x');

commit;
prompt ---->END 
prompt ---->
prompt ---->