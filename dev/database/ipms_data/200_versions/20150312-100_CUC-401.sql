DECLARE
	pk_name nvarchar2(30);
BEGIN
 SELECT c.constraint_name INTO pk_name  FROM user_constraints c join user_cons_columns cl on cl.constraint_name=c.constraint_name WHERE c.table_name='GENERIC_TIMELINE' and c.constraint_type='R' and cl.column_name='PROJECT_ID';
	EXECUTE IMMEDIATE 'ALTER TABLE generic_timeline DROP CONSTRAINT '||pk_name;
END;
/

alter table generic_timeline
add constraint generic_timeline_fk1 foreign key
(
  project_id 
)
references project
(
  id 
) on delete cascade
enable;