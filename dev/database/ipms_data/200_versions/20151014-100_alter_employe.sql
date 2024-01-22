alter table employee add (create_date date default sysdate not null);
alter table employee add (update_date date);