alter table project disable all triggers;
alter table project add(gt_timeline_type nvarchar2(10) default 'CUR' not null references Timeline_Type(code));
alter table project enable all triggers;
