prompt ---->
prompt ---->
prompt 
prompt ---->START    timerow_type
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into timerow_type(code,name,is_active) select 'ACT','Actuals','1' from dual where not exists(select 1 from timerow_type where code = 'ACT');
insert into timerow_type(code,name,is_active) select 'PLAN','Plan','1' from dual where not exists(select 1 from timerow_type where code = 'PLAN');

commit;
prompt ---->END    timerow_type
prompt ---->
prompt ---->