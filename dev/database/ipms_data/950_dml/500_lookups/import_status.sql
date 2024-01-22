prompt ---->
prompt ---->
prompt 
prompt ---->START    import_status
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into import_status(code,name,is_active) select 'DONE','Complete','1' from dual where not exists(select 1 from import_status where code = 'DONE');
insert into import_status(code,name,is_active) select 'DROP','Canceled','1' from dual where not exists(select 1 from import_status where code = 'DROP');
insert into import_status(code,name,is_active) select 'FAIL','Failed','1' from dual where not exists(select 1 from import_status where code = 'FAIL');
insert into import_status(code,name,is_active) select 'NEW','New','1' from dual where not exists(select 1 from import_status where code = 'NEW');
insert into import_status(code,name,is_active) select 'OLD','Old','1' from dual where not exists(select 1 from import_status where code = 'OLD');
insert into import_status(code,name,is_active) select 'READY','Prepared','1' from dual where not exists(select 1 from import_status where code = 'READY');
insert into import_status(code,name,is_active) select 'SEND','Submitted','1' from dual where not exists(select 1 from import_status where code = 'SEND');
insert into import_status(code,name,is_active) select 'VOID','Void','1' from dual where not exists(select 1 from import_status where code = 'VOID');

commit;
prompt ---->END    import_status
prompt ---->
prompt ---->