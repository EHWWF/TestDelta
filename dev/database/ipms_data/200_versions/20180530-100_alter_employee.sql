alter table employee drop column name;
alter table employee add (name varchar2(200));

update employee set name=replace(replace(surname,',')||', '||replace(forename,','),'  ',' ');
commit;
