alter table sophia_all_resources_merge add (decision_start varchar2(100), commit_state varchar2(100));
alter table import_resources_ged add (decision_start varchar2(100), commit_state varchar2(100));
alter table resources_ged add (decision_start varchar2(100), commit_state varchar2(100));

create index sophia_all_resources_m_idx9  on sophia_all_resources_merge (decision_start);
create index sophia_all_resources_m_idx10  on sophia_all_resources_merge (commit_state);

alter table import_study add (branch_flag number(1));
alter table study add (branch_flag number(1) constraint study_branch_flag_chk check(branch_flag in (1,0)));