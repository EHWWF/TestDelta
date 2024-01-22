prompt ---->
prompt ---->
prompt 
prompt ---->START    import_action
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into import_action(code,name,is_active) select 'APPLY','Apply','1' from dual where not exists(select 1 from import_action where code = 'APPLY');
insert into import_action(code,name,is_active) select 'RESTR','Apply (restr.)','1' from dual where not exists(select 1 from import_action where code = 'RESTR');
insert into import_action(code,name,is_active) select 'SKIP','Skip','1' from dual where not exists(select 1 from import_action where code = 'SKIP');
insert into import_action(code,name,is_active) select 'ACCEPT','Accept','1' from dual where not exists(select 1 from import_action where code = 'ACCEPT');

commit;
prompt ---->END    import_action
prompt ---->
prompt ---->