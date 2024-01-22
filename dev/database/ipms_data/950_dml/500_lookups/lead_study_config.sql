prompt ---->
prompt ---->
prompt 
prompt ---->START    lead_study_config
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
merge into lead_study_config dst using
(
select 'M4B' dev_mlstn_code,'Phase I' study_phase_name,'3200' drv_mlstn_code from dual
union all
select 'M4C','Phase IIa','3200' from dual
union all
select 'M5B','Phase IIa','3700' from dual
union all
select 'M6A','Phase IIb','3200' from dual
union all
select 'M6B','Phase IIb','3700' from dual
union all
select 'M6P','Phase IIb','3604' from dual
union all
select 'M7A','Phase III','3200' from dual
union all
select 'M7B','Phase III','3500' from dual
union all
select 'M7C','Phase III','3700' from dual
union all
select 'M7P','Phase III','3604' from dual
union all
select 'MPoC','Phase IIa','3700' from dual
) src 
on (src.dev_mlstn_code=dst.dev_mlstn_code)
when matched then
update set study_phase_name=src.study_phase_name, drv_mlstn_code=src.drv_mlstn_code
when not matched then
insert (dev_mlstn_code,study_phase_name,drv_mlstn_code) values (src.dev_mlstn_code,src.study_phase_name,src.drv_mlstn_code);
commit;
prompt ---->END    lead_study_config
prompt ---->
prompt ---->