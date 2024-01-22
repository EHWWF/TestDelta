alter table project_area add (is_running_import varchar2(10));
update project_area set is_running_import=code;
alter table project_area modify is_running_import not null;
create unique index project_area_is_import_ui on project_area(is_running_import);
comment on column project_area.is_running_import is 'Dedicated column for monitoring ongoing nightly import. If column has value with upper case letters: YES, then it means that the import for that area code is running now. Else (in order to have uniqness index here) the value of the column is equal area code ';