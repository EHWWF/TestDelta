prompt ---->
prompt ---->
prompt
prompt ---->START    project_device_type
prompt
prompt ---->
prompt ---->
SET SCAN OFF;
merge into project_device_type dst
using (
	select 'combined' code,'Drug/ Device (combined)' name, '1' is_active from dual
		union all
	select 'alone','Device (stand alone)','1' from dual
		union all
	select 'other','Other','1' from dual
) src
on (dst.code=src.code)
when matched then
	update set dst.name=src.name, dst.is_active=src.is_active
when not matched then
	insert(code,name,is_active) values (src.code,src.name,src.is_active);
commit;
prompt ---->END    project_device_type
prompt ---->
prompt ---->