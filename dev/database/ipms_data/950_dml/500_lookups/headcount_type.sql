prompt ---->
prompt ---->
prompt 
prompt ---->START    headcount_type
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into headcount_type(code,name,is_active) select 'BGT','Budget','1' from dual where not exists(select 1 from headcount_type where code = 'BGT');
insert into headcount_type(code,name,is_active) select 'FCT','Forecast','1' from dual where not exists(select 1 from headcount_type where code = 'FCT');

commit;
prompt ---->END    headcount_type
prompt ---->
prompt ---->