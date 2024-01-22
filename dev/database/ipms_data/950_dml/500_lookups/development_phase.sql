prompt ---->
prompt ---->
prompt 
prompt ---->START    development_phase
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
insert into development_phase(code,name,is_active) select '0001','Other','1' from dual where not exists(select 1 from development_phase where code = '0001');
insert into development_phase(code,name,is_active) select '0002','Innovation Budget','1' from dual where not exists(select 1 from development_phase where code = '0002');
insert into development_phase(code,name,is_active) select '0003','Early Other Development','1' from dual where not exists(select 1 from development_phase where code = '0003');
insert into development_phase(code,name,is_active) select '0004','Jenapharm','1' from dual where not exists(select 1 from development_phase where code = '0004');
insert into development_phase(code,name,is_active) select '0005','Late Development','1' from dual where not exists(select 1 from development_phase where code = '0005');
insert into development_phase(code,name,is_active) select '0006','Other Late Development','1' from dual where not exists(select 1 from development_phase where code = '0006');
insert into development_phase(code,name,is_active) select '0007','Product Maintenance','1' from dual where not exists(select 1 from development_phase where code = '0007');
insert into development_phase(code,name,is_active) select '0008','Research','1' from dual where not exists(select 1 from development_phase where code = '0008');
commit;
prompt ---->END    development_phase
prompt ---->
prompt ---->