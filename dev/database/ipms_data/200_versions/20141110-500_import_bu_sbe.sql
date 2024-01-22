alter table strategic_business_entity add(gbu_code nvarchar2(20));
alter table strategic_business_entity add(create_date date default sysdate not null);
alter table global_business_unit add(create_date date default sysdate not null);
alter table import_sbe add(gbu_code nvarchar2(20));
alter table import_masterdata add(gbu_code nvarchar2(20));
alter table project_category modify(code nvarchar2(20));
alter table project modify(category_code nvarchar2(20));