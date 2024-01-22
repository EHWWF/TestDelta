alter table study disable all triggers;
update study st
set st.IS_TIMELINE_AUTO_IMPORT=1
where st.is_timeline_auto_import<>1 and st.id||'####'||st.project_id in 
(select s.id||'####'||s.project_id 
 from study s
 join study_data_vw s_vw on s_vw.project_id=s.PROJECT_ID and s_vw.STUDY_ID=s.ID
 where s.IS_TIMELINE_AUTO_IMPORT=0 and
       s_vw.PLACEHOLDER=0 and 
       s_vw.TIMELINE_TYPE_CODE='RAW');
commit;
alter table study enable all triggers;