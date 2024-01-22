alter table import_study add (fpfv_date date);
comment on column import_study.fpfv_date is 'FPFV date that we get from the table: dis_study_mview.';