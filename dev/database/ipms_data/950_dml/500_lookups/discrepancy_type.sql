prompt ---->
prompt ---->
prompt 
prompt ---->START    discrepancy_type
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into discrepancy_type(code,name,is_active) select 'ERROR','Error','1' from dual where not exists(select 1 from discrepancy_type where code = 'ERROR');
insert into discrepancy_type(code,name,is_active) select 'WARN','Warning','1' from dual where not exists(select 1 from discrepancy_type where code = 'WARN');

commit;
prompt ---->END    discrepancy_type
prompt ---->
prompt ---->