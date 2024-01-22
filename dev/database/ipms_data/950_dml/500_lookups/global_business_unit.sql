prompt ---->
prompt ---->
prompt 
prompt ---->START    global_business_unit
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into global_business_unit(code,name,is_active) select 'GM','General Medicine','1' from dual where not exists(select 1 from global_business_unit where code = 'GM');
insert into global_business_unit(code,name,is_active) select 'R&I','Radiology & Interventional','1' from dual where not exists(select 1 from global_business_unit where code = 'R&I');
insert into global_business_unit(code,name,is_active) select 'SM','Specialized Medicine','1' from dual where not exists(select 1 from global_business_unit where code = 'SM');

commit;
prompt ---->END    global_business_unit
prompt ---->
prompt ---->