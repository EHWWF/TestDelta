alter table timeline modify(project_id nvarchar2(20) null);
alter table timeline add constraint timeline_chk1 check (project_id is not null and type_code !='SND' or type_code ='SND');