alter table import disable all triggers;
alter table import add(source varchar2(20) default null);
alter table import enable all triggers;