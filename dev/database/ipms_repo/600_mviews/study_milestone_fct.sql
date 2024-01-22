drop materialized view study_milestone_fct;
create materialized view study_milestone_fct as select * from study_milestone_fct_vw;
grant select on study_milestone_fct to mycsd;