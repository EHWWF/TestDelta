prompt ---->
prompt ---->
prompt 
prompt ---->START    study_status
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into study_status(code,name,is_active) select 'COMM','Committed','1' from dual where not exists(select 1 from study_status where code = 'COMM');
insert into study_status(code,name,is_active) select 'OTHER','Other','1' from dual where not exists(select 1 from study_status where code = 'OTHER');
insert into study_status(code,name,is_active) select 'PLAN','Planned','1' from dual where not exists(select 1 from study_status where code = 'PLAN');
insert into study_status(code,name,is_active) select 'RUN','Running','1' from dual where not exists(select 1 from study_status where code = 'RUN');

commit;
prompt ---->END    study_status
prompt ---->
prompt ---->