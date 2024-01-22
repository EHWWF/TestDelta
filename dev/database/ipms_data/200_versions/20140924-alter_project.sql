alter table project disable all triggers;
alter table project modify is_active number(1,0) default 0;
alter table project enable all triggers;