alter table employee rename column guid to guid2;
alter table employee add(guid varchar2(255));
update employee set guid = guid2;
commit;
alter table employee drop column guid2;
alter table employee modify(guid varchar2(255) constraint employee_guid_cnn not null);
