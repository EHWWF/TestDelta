prompt ---->
prompt ---->
prompt 
prompt ---->START    integration_type
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into integration_type(code,name,is_active) select 'Auto','Automated','1' from dual where not exists(select 1 from integration_type where code = 'Auto');
insert into integration_type(code,name,is_active) select 'Manual','Manual','1' from dual where not exists(select 1 from integration_type where code = 'Manual');

commit;
prompt ---->END    integration_type
prompt ---->
prompt ---->