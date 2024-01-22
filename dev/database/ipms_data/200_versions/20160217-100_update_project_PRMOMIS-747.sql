alter table project disable all triggers;
update project set state_code='1' where area_code='D1' and is_active = 1 and state_code is null;
commit;
update project set state_code=null where area_code='D1' and is_active = 0 and state_code is not null;
commit;
alter table project enable all triggers;