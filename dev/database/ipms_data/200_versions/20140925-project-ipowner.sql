alter table project add(ipowner_code nvarchar2(20));

alter table project
add constraint project_ipowner_code_fk foreign key
(
  ipowner_code 
)
references ipowner
(
  code 
)
enable;