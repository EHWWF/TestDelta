prompt ---->
prompt ---->
prompt 
prompt ---->START    resources_type
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into resources_type(code,name,is_active) select 'ACT','Actual','1' from dual where not exists(select 1 from resources_type where code = 'ACT');
insert into resources_type(code,name,is_active) select 'PLAN','Plan','1' from dual where not exists(select 1 from resources_type where code = 'PLAN');

commit;
prompt ---->END    resources_type
prompt ---->
prompt ---->