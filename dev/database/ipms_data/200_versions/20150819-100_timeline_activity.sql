create table timeline_activity as select * from timeline_activity_vw;
alter table timeline_activity add (create_date date default sysdate);
alter table timeline_activity add (update_date date);
create index timeline_act_prj_id_idx on timeline_activity (project_id);
create index timeline_act_study_e_id_idx on timeline_activity (study_element_id);
create index timeline_act_tml_id_idx on timeline_activity (timeline_id);
create index timeline_act_act_id_idx on timeline_activity (activity_id);
create index timeline_act_par_wbs_id_idx on timeline_activity (parent_wbs_id);

alter table timeline_wbs modify (wbs_id varchar2(100) );
alter table timeline_wbs modify (parent_wbs_id varchar2(100) );
alter table timeline_wbs modify (study_id varchar2(100) );
alter table timeline_wbs modify (code varchar2(100) );
alter table timeline_wbs modify (name varchar2(100) );
alter table timeline_wbs modify (study_phase varchar2(100) );
alter table timeline_wbs modify (sequence_number varchar2(100) );

alter table timeline_activity modify (activity_id varchar2(100) );
alter table timeline_activity modify (parent_wbs_id varchar2(100) );
alter table timeline_activity modify (study_element_id varchar2(100) );
alter table timeline_activity modify (type varchar2(100) );
alter table timeline_activity modify (integration_type varchar2(100) );
alter table timeline_activity modify (code varchar2(100) );
alter table timeline_activity modify (name varchar2(100) );
alter table timeline_activity modify (milestone_code varchar2(100) );
alter table timeline_activity modify (phase_code varchar2(100) );

create unique index timeline_wbs_uidx on timeline_wbs (timeline_id,wbs_id);
create unique index timeline_act_uidx on timeline_activity (timeline_id,activity_id,parent_wbs_id);