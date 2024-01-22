prompt ---->
prompt ---->
prompt 
prompt ---->START    costs_type
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into costs_type(code,name,is_active) select 'ACT','Actuals','1' from dual where not exists(select 1 from costs_type where code = 'ACT');
insert into costs_type(code,name,is_active) select 'BGT','Budget','1' from dual where not exists(select 1 from costs_type where code = 'BGT');
prompt ----MISSING: insert into costs_type(code,name,is_active) select 'CALB','Calculated Budget','1' from dual where not exists(select 1 from costs_type where code = 'CALB');
insert into costs_type(code,name,is_active) select 'CALF','Calculated Forecast','1' from dual where not exists(select 1 from costs_type where code = 'CALF');
insert into costs_type(code,name,is_active) select 'FCT','Forecast','1' from dual where not exists(select 1 from costs_type where code = 'FCT');
insert into costs_type(code,name,is_active) select 'LE','Latest Estimate','1' from dual where not exists(select 1 from costs_type where code = 'LE');
insert into costs_type(code,name,is_active) select 'RR','Run Rate','1' from dual where not exists(select 1 from costs_type where code = 'RR');

commit;
prompt ---->END    costs_type
prompt ---->
prompt ---->