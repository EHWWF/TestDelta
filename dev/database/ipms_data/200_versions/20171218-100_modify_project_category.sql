begin
for r in (select constraint_name from user_constraints where table_name='PROJECT' and constraint_type='R' and r_constraint_name =(select constraint_name from user_constraints where table_name='PROJECT_CATEGORY' and constraint_type='P')) loop
execute immediate 'alter table project drop constraint '||r.constraint_name;
end loop;
end;
/
update project set category_code=upper(category_code), project_group_code=upper(project_group_code);
update project_category set code=upper(code);
commit;

alter table project add constraint project_category_fk foreign key (category_code) references project_category(code);
alter table project add constraint project_project_group_fk foreign key (project_group_code) references project_category(code);

drop index project_category_ui_upper;

create unique index project_category_ui
  on project_category (code)
/