DECLARE
pk_name nvarchar2(30);
begin
select c.constraint_name into pk_name  from user_constraints c join user_cons_columns cl on cl.constraint_name=c.constraint_name where c.table_name='TIMELINE' and c.constraint_type='R' and cl.column_name='LTCI_ID';
EXECUTE IMMEDIATE 'ALTER TABLE TIMELINE DROP CONSTRAINT '||pk_name;
end;
/
DECLARE
pk_name nvarchar2(30);
begin
select c.constraint_name into pk_name  from user_constraints c join user_cons_columns cl on cl.constraint_name=c.constraint_name where c.table_name='TIMELINE_BASELINE' and c.constraint_type='R' and cl.column_name='LTCI_ID';
EXECUTE IMMEDIATE 'ALTER TABLE TIMELINE_BASELINE DROP CONSTRAINT '||pk_name;
end;
/