prompt ---->
prompt ---->
prompt 
prompt ---->START    probability_rule
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into probability_rule(code,name,is_active) select 'AFTER','On or After','1' from dual where not exists(select 1 from probability_rule where code = 'AFTER');
insert into probability_rule(code,name,is_active) select 'BEFORE','Before','1' from dual where not exists(select 1 from probability_rule where code = 'BEFORE');

commit;
prompt ---->END    probability_rule
prompt ---->
prompt ---->