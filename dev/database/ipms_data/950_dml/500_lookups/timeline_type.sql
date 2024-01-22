prompt ---->
prompt ---->
prompt 
prompt ---->START    timeline_type
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into timeline_type(code,name,is_active) select 'APR','Approved','1' from dual where not exists(select 1 from timeline_type where code = 'APR');
insert into timeline_type(code,name,is_active) select 'CUR','Current','1' from dual where not exists(select 1 from timeline_type where code = 'CUR');
insert into timeline_type(code,name,is_active) select 'RAW','Raw','1' from dual where not exists(select 1 from timeline_type where code = 'RAW');
insert into timeline_type(code,name,is_active) select 'SND','Sandbox','0' from dual where not exists(select 1 from timeline_type where code = 'SND');

commit;
prompt ---->END    timeline_type
prompt ---->
prompt ---->