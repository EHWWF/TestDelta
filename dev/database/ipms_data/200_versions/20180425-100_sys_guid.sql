alter table sys_guid add (record_count number);
comment on column sys_guid.record_count is 'The number of records impacted but this activity action.';
alter table sys_guid add (warning nvarchar2(4000));
comment on column sys_guid.warning is 'Information that should not be visible to end user it just for investigation on errors while setting record_count value.';
update sys_guid set status_code='DONE', record_count=1 where status_code is null;
commit;