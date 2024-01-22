update development_phase set name='Innovation Budget' where code='0002' and is_active=1;
commit;
alter table import_study add (phase_code nvarchar2(60));
alter table study add (phase_code nvarchar2(60));
alter table import_study add (study_name nvarchar2(120));
alter table study add (study_name nvarchar2(120));