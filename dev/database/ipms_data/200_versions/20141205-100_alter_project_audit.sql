alter table project_audit disable all triggers;
alter table project_audit add(severity_code nvarchar2(10) default 'INFO' not null references notice_severity(code));
alter table project_audit enable all triggers;