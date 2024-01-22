alter table milestone add(is_lead_study_relevant number(1) default 0 not null);
update milestone set is_lead_study_relevant=1 where code in ('M4B','M4C','M5B','M6A','M6B','M7A','M7B','M7C');
commit;