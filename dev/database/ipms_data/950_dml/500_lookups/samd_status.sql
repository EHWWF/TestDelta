prompt ---->START BUDGET_STATUS
prompt ---->
prompt ---->
SET SCAN OFF;

INSERT INTO IPMS_DATA.SAMD_STATUS (CODE, NAME, IS_ACTIVE) VALUES ('1', 'On track', '1');
INSERT INTO IPMS_DATA.SAMD_STATUS (CODE, NAME, IS_ACTIVE) VALUES ('2', 'At risk', '1');
INSERT INTO IPMS_DATA.SAMD_STATUS (CODE, NAME) VALUES ('3', 'Off truck');

commit;
prompt ---->END 
prompt ---->
prompt ---->