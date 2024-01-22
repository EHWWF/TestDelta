alter table timeline_wbs_category add (category_object_id nvarchar2(20));
alter table import_study add (wbs_category_object_id nvarchar2(20));