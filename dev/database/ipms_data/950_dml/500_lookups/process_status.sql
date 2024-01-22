prompt ---->
prompt ---->
prompt 
prompt ---->START    process_status
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into process_status(code,name,is_active) select 'FIN','Finished','1' from dual where not exists(select 1 from process_status where code = 'FIN');
insert into process_status(code,name,is_active) select 'NEW','New','1' from dual where not exists(select 1 from process_status where code = 'NEW');
insert into process_status(code,name,is_active) select 'PLAN','Planned','1' from dual where not exists(select 1 from process_status where code = 'PLAN');
insert into process_status(code,name,is_active) select 'RUN','Running','1' from dual where not exists(select 1 from process_status where code = 'RUN');

commit;
prompt ---->END    process_status
prompt ---->
prompt ---->