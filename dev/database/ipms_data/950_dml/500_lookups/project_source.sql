prompt ---->
prompt ---->
prompt 
prompt ---->START    project_source
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into project_source(code,name,is_active) select 'lic/acq','lic in/acquired','1' from dual where not exists(select 1 from project_source where code = 'lic/acq');
insert into project_source(code,name,is_active) select 'self','self-originated','1' from dual where not exists(select 1 from project_source where code = 'self');

commit;
prompt ---->END    project_source
prompt ---->
prompt ---->