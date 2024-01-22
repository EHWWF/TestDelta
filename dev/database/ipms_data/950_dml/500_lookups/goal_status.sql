prompt ---->
prompt ---->
prompt 
prompt ---->START    goal_status
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
insert into goal_status(code,name,is_active) select '1','On Track','1' from dual where not exists(select 1 from goal_status where code = '1');
insert into goal_status(code,name,is_active) select '2','At Risk','1' from dual where not exists(select 1 from goal_status where code = '2');
insert into goal_status(code,name,is_active) select '3','Achieved','1' from dual where not exists(select 1 from goal_status where code = '3');
insert into goal_status(code,name,is_active) select '4','Not Achieved','1' from dual where not exists(select 1 from goal_status where code = '4');
insert into goal_status(code,name,is_active) select '5','Withdrawn','1' from dual where not exists(select 1 from goal_status where code = '5');

commit;
prompt ---->END    goal_status
prompt ---->
prompt ---->