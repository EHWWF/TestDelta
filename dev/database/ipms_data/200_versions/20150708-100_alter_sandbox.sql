alter table program_sandbox disable all triggers;
update program_sandbox set code = 'codeNull' where code is null;
commit;
update program_sandbox set name = 'nameNull' where name is null;
commit;
alter table program_sandbox modify code NVARCHAR2(20) not null;
alter table program_sandbox modify name NVARCHAR2(100) not null;
alter table program_sandbox enable all triggers;