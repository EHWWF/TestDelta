prompt ---->
prompt ---->
prompt 
prompt ---->START    configuration
prompt 
prompt ---->Inserts ONLY If the row is missing!!!
prompt ---->
prompt ---->
SET SCAN OFF;
SET DEFINE OFF;

insert into configuration(code, name, value)
select 'POC', 'PoC Milestone ID', 'poc' from dual
where not exists(select 1 from configuration where code = 'POC');

insert into configuration(code, name, value)
select 'IMP-SLEEP', 'Delay after each project import (seconds)', '0' from dual
where not exists(select 1 from configuration where code = 'IMP-SLEEP');

insert into configuration(code, name, value)
select 'DMC', 'DMC Milestone ID', '361_S_DMC' from dual
where not exists(select 1 from configuration where code = 'DMC');

insert into configuration(code, name, value)
select 'MESSAGE', 'Systemwide Message', 'Welcome to Final Release Iteration 1.' from dual
where not exists(select 1 from configuration where code = 'MESSAGE');

insert into configuration(code, name, value)
select 'VERSION', 'Version Details', 'Dev@OpRisk' from dual
where not exists(select 1 from configuration where code = 'VERSION');

insert into configuration(code, name, value)
select 'STD-MM', 'Study Status Period (months)', '4' from dual
where not exists(select 1 from configuration where code = 'STD-MM');

insert into configuration(code, name, value)
select 'CST-EXP', 'Costs Multiplier', '1000000' from dual
where not exists(select 1 from configuration where code = 'CST-EXP');

insert into configuration(code, name, value)
select 'SHAREDOC', 'ShareDoc URL', 'http://www.google.com/' from dual
where not exists(select 1 from configuration where code = 'SHAREDOC');

insert into configuration(code, name, value)
select 'FPFV', 'FPFV Milestone ID', '3200' from dual
where not exists(select 1 from configuration where code = 'FPFV');

insert into configuration(code, name, value)
select 'LPLV', 'LPLV Milestone ID', '3700' from dual
where not exists(select 1 from configuration where code = 'LPLV');

insert into configuration(code, name, value)
select 'P6', 'Primavera URL', 'http://cucp6.oprisk.int:8203/p6' from dual
where not exists(select 1 from configuration where code = 'P6');

insert into configuration(code, name, value)
select 'PROMIS', 'ProMIS URL', 'http://cucbpm.oprisk.int:8011/ipmsapp' from dual
where not exists(select 1 from configuration where code = 'PROMIS');

insert into configuration(code, name, value)
select 'LMTSANDBOX', 'Limit of sandbox plans per program', '20' from dual
where not exists(select 1 from configuration where code = 'LMTSANDBOX');

insert into configuration(code, name, value)
select 'GOAL_TRACK', 'Setup Goal Tracking ON/OFF', '0' from dual
where not exists(select 1 from configuration where code = 'GOAL_TRACK');

insert into configuration(code, name, value)
select 'SENT-BY', 'The sentence indicates the source of e-mail,e.g.:PROD-System/TEST-System/DEV2-System.', '???-System' from dual
where not exists(select 1 from configuration where code = 'SENT-BY');

insert into configuration(code, name, value)
select 'SENT-PRFX', 'The prefix used in e-mail:Subject for pointing the System. Can be null, what could mean: PROD.', '' from dual
where not exists(select 1 from configuration where code = 'SENT-PRFX');

insert into configuration(code, name, value)
select 'LDAPBASEDN', 'Ldap BaseDN for running search for Employee, e.g.: DC=emea,DC=healthcare,DC=cnb', 'DC=cnb' from dual
where not exists(select 1 from configuration where code = 'LDAPBASEDN');

insert into configuration(code, name, value)
select 'LDAPBASEDN', 'Ldap BaseDN for running search for Employee. Second INSERT only just in case for having for local use.', 'cn=Users,dc=ipmsproject,dc=com' from dual
where not exists(select 1 from configuration where code = 'LDAPBASEDN');

insert into configuration(code, name, value)
select 'LDAPSEARCH', 'Ldap search string that should be added at the end of search string while running Employee search.', 
'(objectclass=user)(memberOf:1.2.840.113556.1.4.1941:=CN=bs.a.ipms_promis_all_pharma_users,OU=Groups,OU=IAM,OU=_DomainOperations,DC=DE,DC=bayer,DC=cnb)' from dual
where not exists(select 1 from configuration where code = 'LDAPSEARCH');

insert into configuration(code, name, value)
select 'LDAPSEARCH', 'Ldap search string that should be added at the end of search string while running Employee search. Second INSERT only just in case for having for local use.', '(objectclass=user)' from dual
where not exists(select 1 from configuration where code = 'LDAPSEARCH');

insert into configuration(code, name, value)
select 'AUTOIMPORT', 'Global system flag controlling the automatic import of planend timelines.', '0' from dual
where not exists(select 1 from configuration where code = 'AUTOIMPORT');

insert into configuration(code, name, value)
select 'PRCOMPL', 'Primary completion Milestone ID', '3604' from dual
where not exists(select 1 from configuration where code = 'PRCOMPL');

insert into configuration(code, name, value)
select 'CDBLOCK', 'CDB lock Milestone ID', '4000' from dual
where not exists(select 1 from configuration where code = 'CDBLOCK');

insert into configuration(code, name, value)
select 'CSRAPP', 'CSR approved Milestone ID', '4650' from dual
where not exists(select 1 from configuration where code = 'CSRAPP');

insert into configuration(code, name, value)
select 'LPFV', 'LPFV Milestone ID', '3500' from dual
where not exists(select 1 from configuration where code = 'LPFV');

insert into configuration(code, name, value,is_resource)
select 'PRJ-IMP-OUTDATE-DAYS', 'Project imported data outdate threshold (days)', '2','1' from dual
where not exists(select 1 from configuration where code = 'PRJ-IMP-OUTDATE-DAYS');

insert into configuration(code, name, value,is_resource,details2)
select 'WLCM-TXT', 'Welcome text', null,0,'<p align="left"><span style="background-color: rgb(255, 255, 255);">Welcome to PROMIS !</span></p>' from dual
where not exists(select 1 from configuration where code = 'WLCM-TXT');

insert into configuration(code, name, value)
select 'CPOT', 'cPoT Milestone ID', 'cPoT' from dual
where not exists(select 1 from configuration where code = 'CPOT');

insert into configuration(code, name, value)
select 'LAST-FCT-MONTH', 'Last forecast month', '' from dual
where not exists(select 1 from configuration where code = 'LAST-FCT-MONTH');

insert into configuration(code, name, value)
select 'LAST-FCT-YEAR', 'Last forecast year', '' from dual
where not exists(select 1 from configuration where code = 'LAST-FCT-YEAR');

insert into configuration(code, name, value)
select 'MAX-FCT-MONTH', 'Max forecast month to import', '' from dual
where not exists(select 1 from configuration where code = 'MAX-FCT-MONTH');

insert into configuration(code, name, value)
select 'MAX-FCT-YEAR', 'Max forecast year to import', '' from dual
where not exists(select 1 from configuration where code = 'MAX-FCT-YEAR');

insert into configuration(code, name, value)
select 'LAST-FCT-NUM', 'Last forecast number.', '' from dual
where not exists(select 1 from configuration where code = 'LAST-FCT-NUM');

insert into configuration(code, name, value)
select 'LAST-FCT-VER', 'Last forecast version.', '' from dual
where not exists(select 1 from configuration where code = 'LAST-FCT-VER');

insert into configuration(code, name, value)
select 'STUDY-AUTO-IMPORT', 'Global system flag controlling the automatic import of study to P6 timelines.', '0' from dual
where not exists(select 1 from configuration where code = 'STUDY-AUTO-IMPORT');

insert into configuration(code, name, value)
select 'SEND-ALWAYS-1CWID', 'In order to monitor proper email notofication services send emails to concrete ProMIS admin as well', 'EQQVV' from dual
where not exists(select 1 from configuration where code = 'SEND-ALWAYS-1CWID');

insert into configuration(code, name, value)
select 'DEFAULT-STUDY-TEMPLATE', 'Default study template name that should be used during automatic study import.', 'one study short' from dual
where not exists(select 1 from configuration where code = 'DEFAULT-STUDY-TEMPLATE');

insert into configuration(code, name, value)
select 'EXCEPTION-EMAILS', 'Comma separated list of emails in case notification servers fails to get CWID emails.', 'algimantas.vaznelis.ext@bayer.com,mathias.braun.ext@bayer.com' from dual
where not exists(select 1 from configuration where code = 'EXCEPTION-EMAILS');

insert into configuration(code, name, value)
select 'LPLVA', 'LPLV - part A For adaptive studies use', '3424' from dual
where not exists(select 1 from configuration where code = 'LPLVA');

insert into configuration(code, name, value)
select 'FPFVB', 'FPFV - part B For adaptive studies use', '3434' from dual
where not exists(select 1 from configuration where code = 'FPFVB');

insert into configuration(code, name, value)
select 'P6USER', 'LDAPusername used for integration with P6.SOA can identify records from BPEL eg:UpdateTimeline.bpel', 'mylna' from dual
where not exists(select 1 from configuration where code = 'P6USER');

insert into configuration(code, name, value)
select 'D6', 'D6 Milestone ID', 'D6' from dual
where not exists(select 1 from configuration where code = 'D6');

insert into configuration(code, name, value)
select 'LTC-TAG-ID', 'Specific TAG ID for which data will be collected at specific time. Related to BAY_PROMIS-541', '62' from dual
where not exists(select 1 from configuration where code = 'LTC-TAG-ID');

insert into configuration(code, name, value)
select 'LTC-TAG-SCN', 'Specific timestamp value represented as a system change number. Related to BAY_PROMIS-541', '11564074960579' from dual
where not exists(select 1 from configuration where code = 'LTC-TAG-SCN');

insert into configuration(code, name, value)
select 'GOAL_TRACK_YEAR', 'Setup Goal Tracking Year', '2019' from dual
where not exists(select 1 from configuration where code = 'GOAL_TRACK_YEAR');

commit;
prompt ---->END    configuration
prompt ---->
prompt ---->
