prompt ---->
prompt ---->
prompt 
prompt ---->START    priority
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
insert into priority(code,name,is_active) select 'n.a.','Not Defined','1' from dual where not exists(select 1 from priority where code = 'n.a.');
insert into priority(code,name,is_active) select '1','High','1' from dual where not exists(select 1 from priority where code = '1');
insert into priority(code,name,is_active) select '2','Medium','1' from dual where not exists(select 1 from priority where code = '2');
insert into priority(code,name,is_active) select '3','Low','1' from dual where not exists(select 1 from priority where code = '3');

commit;
prompt ---->END    priority
prompt ---->
prompt ---->