alter table sys_guid add (project_id nvarchar2(20));
create index sys_guid_project_id_idx on sys_guid (project_id);
alter table sys_guid add (program_id nvarchar2(20));
create index sys_guid_program_id_idx on sys_guid (program_id);
comment on column sys_guid.project_id is 'Should be provided by ADF if possible and applies for the activity.';
comment on column sys_guid.program_id is 'Must be empty if project_id is provided. And analogically as project_id should be provided by ADF.';