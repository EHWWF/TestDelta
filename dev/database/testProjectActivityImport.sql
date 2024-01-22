declare
  l_project_id import.project_id%type := '601-3635';
  l_import_id  import.id%type;
begin
  update timeline set is_syncing=0 where id ='601-3635-RAW';
  insert into import (status_code, project_id, type_mask, is_manual, source) values ('NEW', '601-3635', 4096, 0, 'CMBS') --4096 --6232
  returning id into l_import_id;
  import_pkg.launch(l_import_id);
  commit;
end;


declare
  v nvarchar2(10);
begin
  update timeline set is_syncing=0 where id ='601-3635-RAW'; commit;
  import_resources_pkg.merge_sophia_all_resources;
  v:=import_pkg.launch('601-3635',import_pkg.TYPE_PROJECT(),0); commit;
end;


select t.error_stack, t.* from sys_log t order by create_date desc;
select to_char(m.request_date,'YYYY-MM-DD HH24:MI') req, m.* from message m where request_date >=sysdate-1/2 order by request_date desc


select * from import  order by create_date desc;
select * from import_project_activity where import_id = 1163072 order by project_activity_id
select * from project_activity order by project_activity_id
select * from timeline_project_activity_vw where project_id='601-3635' order by study_element_id
select * from sophia_project_activities_vw  where project_id='601-3635' order by project_activity_id
select * from sophia_import.project_activities where project_id='435910' order by project_activity_id

select * from timeline where id='601-3635-RAW'

select * from configuration
  select * from import

truncate table project_activity;

select * from timeline where id='601-3635-RAW'
select * from milestone where wbs_category is not null
select * from phase_milestone where milestone_code='M4B'
select * from phase
select import_pkg.type_raw from dual


begin project_activities_pkg.timeline_merge('601-3635'); commit; end;
begin timeline_pkg.refresh_materialized_data('601-3635-RAW'); commit; end;
begin timeline_pkg.merge_timeline_activity('601-3635-RAW'); end;
begin   update timeline set is_syncing=0 where id ='601-3635-RAW'; timeline_pkg.receive('601-3635-RAW'); commit; end;
begin import_pkg.launch(1162397); commit; end;

drop table import_project_activity

select * from dba_flashback_archive_tables

SELECT versions_operation, t.* FROM import
VERSIONS BETWEEN TIMESTAMP TO_TIMESTAMP('2018-09-05 15:20:00', 'YYYY-MM-DD HH24:MI:SS') AND systimestamp t
where t.id='601-3635-RAW'

select timeline_id from timeline_wbs_category_vw
  where timeline_id like '%-RAW' and category_name is not null
group by timeline_id
having count(*)=1

select * from timeline_wbs_category_vw where timeline_id='1405-7694-RAW'

