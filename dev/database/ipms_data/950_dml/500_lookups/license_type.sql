prompt ---->
prompt ---->
prompt 
prompt ---->START    license_type
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
insert into license_type(code,name,is_active) select 'PDS','Patent DS','1' from dual where not exists(select 1 from license_type where code = 'PDS');
insert into license_type(code,name,is_active) select 'EXT','Exclusivity','1' from dual where not exists(select 1 from license_type where code = 'EXT');

commit;
prompt ---->END    license_type
prompt ---->
prompt ---->