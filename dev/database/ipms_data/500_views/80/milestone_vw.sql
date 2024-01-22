create or replace view milestone_vw as
select * from milestone_all_vw where is_active=1;

drop table milestone_tmp;

create global temporary table milestone_tmp
on commit delete rows
as (select * from milestone_vw where 1=0);

create index milestone_tmp_idx1 on milestone_tmp(project_id);