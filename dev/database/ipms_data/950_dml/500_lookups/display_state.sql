prompt ---->
prompt ---->
prompt 
prompt ---->START    display_state
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into display_state(code,name,is_active) select '1','Active','1' from dual where not exists(select 1 from display_state where code = '1');
insert into display_state(code,name,is_active) select '2','Inactive','1' from dual where not exists(select 1 from display_state where code = '2');
insert into display_state(code,name,is_active) select '3','Prepared','1' from dual where not exists(select 1 from display_state where code = '3');
insert into display_state(code,name,is_active) select '4','Planned','0' from dual where not exists(select 1 from display_state where code = '4');
insert into display_state(code,name,is_active) select '5','Withdrawn','1' from dual where not exists(select 1 from display_state where code = '5');

commit;
prompt ---->END    display_state
prompt ---->
prompt ---->