--drop package activity_log;
alter table guid rename to sys_guid;
alter table guid_transaction rename to sys_guid_transaction;
alter table message add (transaction_id nvarchar2(100));

DECLARE
	pk_name nvarchar2(30);
begin
 SELECT c.constraint_name INTO pk_name  FROM user_constraints c join user_cons_columns cl on cl.constraint_name=c.constraint_name WHERE c.table_name='SYS_GUID_TRANSACTION' and c.constraint_type='R' and cl.column_name='GUID';
	EXECUTE IMMEDIATE 'ALTER TABLE SYS_GUID_TRANSACTION DROP CONSTRAINT '||pk_name;
end;
/