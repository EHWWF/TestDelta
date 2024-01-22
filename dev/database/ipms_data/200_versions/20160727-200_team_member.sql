alter table team_member disable all triggers;
drop index team_member_idx2;
alter table team_member add (unique_assignment nvarchar2(40));
update team_member set unique_assignment=(case when get_program_code(program_id)='RESERVED-PT-D2-PRJ' then id else program_id||'|'||employee_code end) where unique_assignment is null;
commit;
alter table team_member modify (unique_assignment not null);
create unique index team_member_idx2 on team_member (unique_assignment);
comment on column team_member.unique_assignment is 'The column unique_assignment is used only for having unique combination for team role assignment. Because it is depended on external table PROGRAM and in order to avoid dependencies an function based indexes the column stores values prepared by trigger.';
alter table team_member enable all triggers;