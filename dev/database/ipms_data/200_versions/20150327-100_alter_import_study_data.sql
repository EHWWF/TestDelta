alter table import_study_data add(is_existing number);
alter table import_study_data add constraint import_stuydy_data_chk1 check (is_existing in (1,0));