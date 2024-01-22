alter table project_category add(create_date date default sysdate not null);
create unique index project_category_ui_upper on project_category (upper(code));