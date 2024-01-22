prompt ---->
prompt ---->
prompt 
prompt ---->START    project_area_milestone
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
delete from project_area_milestone;
insert into project_area_milestone(area_code,milestone_code)
with table_source as
(
select 'D2-PRJ' area_code,'D2' milestone_code from dual union all
select 'D2-PRJ','PCC' from dual union all
select 'D3-TR','PCC' from dual union all
select 'D3-TR','D4' from dual union all
select 'D3-TR','M4C' from dual union all
select 'D3-TR','D5' from dual union all
select 'D3-TR','PoC' from dual union all
select 'D3-TR','D6' from dual union all
select 'D3-TR','D7' from dual union all
select 'D3-TR','D8' from dual union all
select 'D3-TR','M9' from dual union all
select 'POST-POT','PCC' from dual union all
select 'POST-POT','D4' from dual union all
select 'POST-POT','M4C' from dual union all
select 'POST-POT','D5' from dual union all
select 'POST-POT','PoC' from dual union all
select 'POST-POT','D6' from dual union all
select 'POST-POT','D7' from dual union all
select 'POST-POT','D8' from dual union all
select 'POST-POT','M9' from dual union all
select 'PRE-POT','PCC' from dual union all
select 'PRE-POT','D4' from dual union all
select 'PRE-POT','M4C' from dual union all
select 'PRE-POT','D5' from dual union all
select 'PRE-POT','PoC' from dual union all
select 'PRE-POT','D6' from dual union all
select 'PRE-POT','D7' from dual union all
select 'PRE-POT','D8' from dual union all
select 'PRE-POT','M9' from dual
) 
select area_code,milestone_code from table_source;
commit;
prompt ---->END    project_area_milestone
prompt ---->
prompt ---->

/
prompt ---->START    project_area_milestone
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

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
prompt ---->END    project_area_milestone
prompt ---->
prompt ---->