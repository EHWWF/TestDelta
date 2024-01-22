create table timeline_wbs as select * from timeline_wbs_vw;
alter table timeline_wbs add (create_date date default sysdate);
alter table timeline_wbs add (update_date date);
create index timeline_wbs_prj_id_indx on timeline_wbs (project_id);
create index timeline_wbs_study_id_indx on timeline_wbs (study_id);
create index timeline_wbs_tml_id_indx on timeline_wbs (timeline_id);
create index timeline_wbs_wbs_id_indx on timeline_wbs (wbs_id);