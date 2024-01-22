prompt ---->
prompt ---->
prompt 
prompt ---->START    target_origin
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into target_origin (code,name,is_active) select 'CAC','Collaboration – Academic','1' from dual where not exists(select 1 from target_origin where code = 'CAC');
insert into target_origin (code,name,is_active) select 'CIN','Collaboration – Industry','1' from dual where not exists(select 1 from target_origin where code = 'CIN');
insert into target_origin (code,name,is_active) select 'IH','In-House','1' from dual where not exists(select 1 from target_origin where code = 'IH');
insert into target_origin (code,name,is_active) select 'LIT','Literature','1' from dual where not exists(select 1 from target_origin where code = 'LIT');
insert into target_origin (code,name,is_active) select 'OTH','Other','1' from dual where not exists(select 1 from target_origin where code = 'OTH');
insert into target_origin (code,name,is_active) select 'UNK','Unknown','1' from dual where not exists(select 1 from target_origin where code = 'UNK');

commit;
prompt ---->END    target_origin
prompt ---->
prompt ---->