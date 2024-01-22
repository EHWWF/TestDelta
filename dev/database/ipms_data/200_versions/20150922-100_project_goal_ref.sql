declare
	pk_name nvarchar2(30);
begin
	select c.constraint_name 
	into pk_name
	from user_constraints c 
	join user_cons_columns cl on cl.constraint_name=c.constraint_name where c.table_name='GOAL' and c.constraint_type='R' and cl.column_name='PROJECT_ID';
	
	execute immediate 'ALTER TABLE GOAL DROP CONSTRAINT '||pk_name;
	
end;
/

alter table goal add constraint goal_project_fk1 foreign key (project_id) references project (id) on delete cascade enable;