alter table project_audit add (parent_id nvarchar2(20));
create index project_audit_parent_fki on project_audit(parent_id);
comment on column project_audit.parent_id is 'Soft Reference to the same table: project_audit. Reference is not mandatory but if provided then it is possible to track exact change of audit record: PROMIS-528';