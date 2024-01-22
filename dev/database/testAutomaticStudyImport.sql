select l.content, l.* from sys_log l order by create_date desc;
select l.content, l.* from sys_log l WHERE subject='dttest' order by create_date desc;
select to_char(m.request_date,'YYYY-MM-DD HH24:MI') req, m.* from message m where request_date >=sysdate-1/24 order by request_date desc;
select * from response_qt;

declare
  v nvarchar2(10);
  project_id nvarchar2(100):='601-3635';
begin
  update timeline set is_syncing=0 where id=project_id||'-RAW';
  commit;
  v:=import_pkg.launch(project_id,import_pkg.type_raw,0);
  commit;
end;


declare
  v          nvarchar2(10);
begin

  for r in (select id from project prj where prj.is_active=1 and prj.area_code in ('PRE-POT','POST-POT') and rownum<5) loop
    begin
      update timeline
      set is_syncing = 0
      where id = r.id || '-RAW';
      commit;

      v := import_pkg.launch(r.id, import_pkg.type_raw, 0);
      commit;

      exception
      when others then null;
    end;
  end loop;
end;


select * from project
select * from configuration
select * from import order by create_date desc
select * from import_study where import_id=1158369
--parent 193297

select * from study_data_vw where project_id='601-3635' and study_id='137921'
select * from study where project_id='601-3635'  and study_modus_no=2

select * from project prj where prj.is_active=1
select * from program where lower(code) like '%bin%'
select * from project where name like '%ciclib%'
select is_syncing from timeline where id ='601-3635-RAW'
update timeline set is_syncing=0 where id='601-3635-RAW'

select * from combase_study_vw st
  left join sophia_study_vw sp on (sp.project_id='435910' and sp.study_id=st.study_id)
where '435910'=st.project_id;
-- combase: select * from  bdr_stu_pjx prjstd where prjstd.pjx_no='435910'
-- sophia: select * from study where study_id ='13792'
-- sophia: select * from patient_figures where study_id ='13792'

select * from  bdr_stu_pjx@combase_db prjstd where prjstd.pjx_no='435910'

select * from configuration

select
  ba.category_id as bac,
  sg.ba_code,
  --sg.ba_code as table_name_his,
  prg.name as program_name,
  prg.id as program_id,
  prj.name as project_name,
  prj.code as project_code,
  prj.id as project_id,
  sg.create_date,
  null as change_comment,
  sg.user_id as log_user_id,
  sg.description,
  sg.id
from sys_guid sg
  join business_activity ba on (sg.ba_code=ba.code)
  join project prj on (sg.project_id=prj.id)
  join program prg on (prj.program_id=prg.id)
where sg.ba_code in
      (
        'importstudy'
      )
order by create_date desc