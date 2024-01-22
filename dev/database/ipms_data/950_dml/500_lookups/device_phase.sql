prompt ---->
prompt ---->
prompt 
prompt ---->START    device_phase
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into device_phase(code,name,is_active) select 'IDE','Ideation','1' from dual where not exists(select 1 from device_phase where code = 'IDE');
insert into device_phase(code,name,is_active) select 'DPL','Design Planning','1' from dual where not exists(select 1 from device_phase where code = 'DPL');
insert into device_phase(code,name,is_active) select 'DOU','Design Outputs','1' from dual where not exists(select 1 from device_phase where code = 'DOU');
insert into device_phase(code,name,is_active) select 'DVE','Design Verification','1' from dual where not exists(select 1 from device_phase where code = 'DVE');
insert into device_phase(code,name,is_active) select 'DVA','Design Validation','1' from dual where not exists(select 1 from device_phase where code = 'DVA');
insert into device_phase(code,name,is_active) select 'DTR','Design Transfer','1' from dual where not exists(select 1 from device_phase where code = 'DTR');
insert into device_phase(code,name,is_active) select 'CPH','Commercial Phase','1' from dual where not exists(select 1 from device_phase where code = 'CPH');

commit;
prompt ---->END    device_phase
prompt ---->
prompt ---->