prompt ---->
prompt ---->
prompt 
prompt ---->START    calculation_method
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into calculation_method(code,name,is_active) select 'DET','Deterministic','1' from dual where not exists(select 1 from calculation_method where code = 'DET');
insert into calculation_method(code,name,is_active) select 'PROB','Probabilistic','1' from dual where not exists(select 1 from calculation_method where code = 'PROB');

commit;
prompt ---->END    calculation_method
prompt ---->
prompt ---->