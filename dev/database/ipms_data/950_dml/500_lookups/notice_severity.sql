prompt ---->
prompt ---->
prompt 
prompt ---->START    notice_severity
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into notice_severity(code,name,is_active) select 'DEBUG','Debug','1' from dual where not exists(select 1 from notice_severity where code = 'DEBUG');
insert into notice_severity(code,name,is_active) select 'ERROR','Error','1' from dual where not exists(select 1 from notice_severity where code = 'ERROR');
insert into notice_severity(code,name,is_active) select 'INFO','Information','1' from dual where not exists(select 1 from notice_severity where code = 'INFO');
insert into notice_severity(code,name,is_active) select 'WARN','Warning','1' from dual where not exists(select 1 from notice_severity where code = 'WARN');

commit;
prompt ---->END    notice_severity
prompt ---->
prompt ---->