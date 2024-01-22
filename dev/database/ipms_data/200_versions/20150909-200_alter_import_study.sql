create sequence import_study_id_seq maxvalue 9999999999999999999 minvalue 1 cycle;
alter table import_study add(id nvarchar2(20));
update import_study set id=import_study_id_seq.nextval;
commit;
alter table import_study drop primary key;
alter table import_study add primary key (id);