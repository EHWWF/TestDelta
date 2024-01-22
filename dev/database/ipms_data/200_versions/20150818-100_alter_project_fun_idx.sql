insert into program (name,code) values('D1','RESERVED-PT-D1');
commit;
create unique index project_uidx on project (nvl(code,id)||':'||decode(area_code,'D2-PRJ','D2','D1','D1','X'));
alter table project drop constraint project_code_uk;