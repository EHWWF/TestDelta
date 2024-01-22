prompt ---->
prompt ---->
prompt
prompt ---->START    BAL_STATUS
prompt
prompt ---->
prompt ---->
SET SCAN OFF;

merge into bal_status dst
using (
  select 'ERROR' code,'No' name,'1' is_active from dual
  union all
  select 'DONE','Yes','1' from dual
) src
on (dst.code=src.code)
when matched then
  update set dst.name=src.name,
            dst.is_active=src.is_active
when not matched then
  insert(code,name,is_active) values (src.code,src.name,src.is_active);
commit;
prompt ---->END    BAL_STATUS
prompt ---->
prompt ---->