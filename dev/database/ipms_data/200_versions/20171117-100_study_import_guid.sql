alter table sys_guid add (status_code nvarchar2(20));
comment on column sys_guid.status_code is 'DONE,ERROR,INFO,...';
alter table sys_guid add (description nvarchar2(4000));
comment on column sys_guid.description is 'In order to show more specific info at UI BA Tab some additional description is needed.';