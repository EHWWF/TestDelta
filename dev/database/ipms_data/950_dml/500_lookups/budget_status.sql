prompt ---->START BUDGET_STATUS
prompt ---->
prompt ---->
SET SCAN OFF;

INSERT INTO IPMS_DATA.BUDGET_STATUS (CODE, NAME, IS_ACTIVE) VALUES ('1', 'On track', '1');
INSERT INTO IPMS_DATA.BUDGET_STATUS (CODE, NAME, IS_ACTIVE) VALUES ('2', 'At risk', '1');
INSERT INTO IPMS_DATA.BUDGET_STATUS (CODE, NAME, IS_ACTIVE) VALUES ('3', 'Off truck', '1');

commit;
prompt ---->END 
prompt ---->
prompt ---->