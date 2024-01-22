alter table project_category add (is_promis number(1,0) default 0 not null check(is_promis in (0,1)));

alter table project_category add(maingroup_code nvarchar2(20));

alter table project_category
add constraint project_cat_maingroup_code_fk foreign key
(
  maingroup_code 
)
references maingroup
(
  code 
)
enable;