alter table project add(pidt_bu_code nvarchar2(10));
comment on column project.pidt_bu_code is 'The PIDT_BU_CODE is relevant for the Green List and is imported from PIDT/COMBASE. Also must be shown at UI for all other (except DEV and D2) project types.';
alter table project
add constraint project_pidt_bu_code_fk foreign key
(
  pidt_bu_code 
)
references global_business_unit
(
  code 
)
enable;