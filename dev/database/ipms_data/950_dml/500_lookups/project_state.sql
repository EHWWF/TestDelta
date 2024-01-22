prompt ---->
prompt ---->
prompt 
prompt ---->START    project_state
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
insert into project_state(code,name,is_active) select '0','Prepared','1' from dual where not exists(select 1 from project_state where code = '0');
insert into project_state(code,name,is_active) select '1','Going','1' from dual where not exists(select 1 from project_state where code = '1');
insert into project_state(code,name,is_active) select '2','On Hold','1' from dual where not exists(select 1 from project_state where code = '2');
insert into project_state(code,name,is_active) select '3','Launched','1' from dual where not exists(select 1 from project_state where code = '3');
insert into project_state(code,name,is_active) select '4','Submitted','1' from dual where not exists(select 1 from project_state where code = '4');
insert into project_state(code,name,is_active) select '5','Terminated','1' from dual where not exists(select 1 from project_state where code = '5');
insert into project_state(code,name,is_active) select '6','Completed','1' from dual where not exists(select 1 from project_state where code = '6');
insert into project_state(code,name,is_active) select '7','Split','1' from dual where not exists(select 1 from project_state where code = '7');
insert into project_state(code,name,is_active) select '9','Removed','1' from dual where not exists(select 1 from project_state where code = '9');
insert into project_state(code,name,is_active) select '10','Withdrawn','1' from dual where not exists(select 1 from project_state where code = '10');
commit;
prompt ---->END    project_state
prompt ---->
prompt ---->