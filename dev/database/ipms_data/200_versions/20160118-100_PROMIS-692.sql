alter table employee add (forename nvarchar2(300), surname nvarchar2(300), guid nvarchar2(225));
update employee set 
forename=replace(nvl(substr(name,1, instr(name,' ')-1),'Not provided by LDAP'),','),
surname=replace(substr(name,instr(name,' '), length(name)-instr(name,' ')+1),','),
guid='dummy';
alter table employee modify (forename nvarchar2(300) not null, surname nvarchar2(300) not null, guid nvarchar2(225) not null);
drop table employee_ad_search;