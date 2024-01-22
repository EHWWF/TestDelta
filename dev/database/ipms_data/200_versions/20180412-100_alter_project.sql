alter table project add (previous_names nvarchar2(4000));

create index project_idx3 on project (previous_names);
