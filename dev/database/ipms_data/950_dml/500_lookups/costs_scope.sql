prompt ---->
prompt ---->
prompt 
prompt ---->START    costs_scope
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into costs_scope(code,name,is_active) select 'EXT','External','1' from dual where not exists(select 1 from costs_scope where code = 'EXT');
insert into costs_scope(code,name,is_active) select 'INT','Internal','1' from dual where not exists(select 1 from costs_scope where code = 'INT');

commit;
prompt ---->END    costs_scope
prompt ---->
prompt ---->