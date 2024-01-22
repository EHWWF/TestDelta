alter table import add (notify_id varchar2(50));
update import set notify_id=id||':'||status_code;
alter table import modify(notify_id varchar2(50) constraint import_notify_id_cnn not null);