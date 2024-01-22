prompt ---->
prompt ---->
prompt 
prompt ---->START    costs_subtype
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into costs_subtype(code,name,is_active) select 'CRO','CRO','0' from dual where not exists(select 1 from costs_subtype where code = 'CRO');
insert into costs_subtype(code,name,is_active) select 'ECG','ECG','0' from dual where not exists(select 1 from costs_subtype where code = 'ECG');
insert into costs_subtype(code,name,is_active) select 'OEC','Other External Cost','1' from dual where not exists(select 1 from costs_subtype where code = 'OEC');
insert into costs_subtype(code,name,is_active) select 'OEI','Other External Cost Insourced','1' from dual where not exists(select 1 from costs_subtype where code = 'OEI');

commit;
prompt ---->END    costs_subtype
prompt ---->
prompt ---->