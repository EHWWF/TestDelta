alter table import_subgroup modify(code nvarchar2(60));

drop index project_category_ui_upper;

alter table project_category modify(code nvarchar2(60));

create unique index project_category_ui_upper
  on project_category (UPPER("CODE"));