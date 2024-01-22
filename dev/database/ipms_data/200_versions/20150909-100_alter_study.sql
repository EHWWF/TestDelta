alter table import_study add (therapeutic_group_code nvarchar2(12));
alter table import_study add (therapeutic_group_desc nvarchar2(120));
alter table study add (therapeutic_group_code nvarchar2(12));
alter table study add (therapeutic_group_desc nvarchar2(120));
comment on column study.therapeutic_group_desc is 'Column name and content is taken form Sophia but it stores: Managing Medical Unit.';