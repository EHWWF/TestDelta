prompt ---->
prompt ---->
prompt 
prompt ---->START    region
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
insert into region(code,name,is_active) select '1','EU','1' from dual where not exists(select 1 from region where code = '1');
insert into region(code,name,is_active) select '2','US','1' from dual where not exists(select 1 from region where code = '2');
insert into region(code,name,is_active) select '3','J','1' from dual where not exists(select 1 from region where code = '3');
insert into region(code,name,is_active) select '4','LA','1' from dual where not exists(select 1 from region where code = '4');
insert into region(code,name,is_active) select '5','AP','1' from dual where not exists(select 1 from region where code = '5');
insert into region(code,name,is_active) select '6','CN','1' from dual where not exists(select 1 from region where code = '6');

commit;
prompt ---->END    region
prompt ---->
prompt ---->