prompt ---->
prompt ---->
prompt 
prompt ---->START    milestone_type
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
insert into milestone_type(code,name,is_active) select 'DEC','Decision','1' from dual where not exists(select 1 from milestone_type where code = 'DEC');
insert into milestone_type(code,name,is_active) select 'DEV','Development','1' from dual where not exists(select 1 from milestone_type where code = 'DEV');
insert into milestone_type(code,name,is_active) select 'REG','Regional','1' from dual where not exists(select 1 from milestone_type where code = 'REG');

commit;
prompt ---->END    milestone_type
prompt ---->
prompt ---->

/
prompt ---->START    milestone_type
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

Insert into IPMS_DATA.MILESTONE_TYPE (CODE,NAME,IS_ACTIVE) values ('DEC-SAMD','SaMD Decision',1);

commit;
prompt ---->END    milestone_type
prompt ---->
prompt ---->