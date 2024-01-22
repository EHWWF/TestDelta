prompt ---->
prompt ---->
prompt 
prompt ---->START    substance_type
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into substance_type(code,name,is_active) select '0','n.a.','1' from dual where not exists(select 1 from substance_type where code = '0');
insert into substance_type(code,name,is_active) select '1','chem','1' from dual where not exists(select 1 from substance_type where code = '1');
insert into substance_type(code,name,is_active) select '2','biol','1' from dual where not exists(select 1 from substance_type where code = '2');
insert into substance_type(code,name,is_active) select '4','chem/biol','1' from dual where not exists(select 1 from substance_type where code = '4');

commit;
prompt ---->END    substance_type
prompt ---->
prompt ---->