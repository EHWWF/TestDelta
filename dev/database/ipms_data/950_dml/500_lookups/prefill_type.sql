prompt ---->
prompt ---->
prompt 
prompt ---->START    prefill_type
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into prefill_type(code,name,is_active,calculation_method_code) select 'FCT','Forecast','1','DET' from dual where not exists(select 1 from prefill_type where code = 'FCT');
insert into prefill_type(code,name,is_active,calculation_method_code) select 'LE','Selected LE','1','DET' from dual where not exists(select 1 from prefill_type where code = 'LE');
insert into prefill_type(code,name,is_active,calculation_method_code) select 'FCTp','Forecast(p)','1','PROB' from dual where not exists(select 1 from prefill_type where code = 'FCTp');
insert into prefill_type(code,name,is_active,calculation_method_code) select 'cLEd','Current LE(d)','1','PROB' from dual where not exists(select 1 from prefill_type where code = 'cLEd');
insert into prefill_type(code,name,is_active,calculation_method_code) select 'xLEp','Selected LE(p)','1','PROB' from dual where not exists(select 1 from prefill_type where code = 'xLEp');
insert into prefill_type(code,name,is_active,calculation_method_code) select 'FCTclc','Calculate from Forecast(d)','1','PROB' from dual where not exists(select 1 from prefill_type where code = 'FCTclc');
insert into prefill_type(code,name,is_active,calculation_method_code) select 'cLEclc','Calculate from Current LE(d)','1','PROB' from dual where not exists(select 1 from prefill_type where code = 'cLEclc');

commit;
prompt ---->END    prefill_type
prompt ---->
prompt ---->