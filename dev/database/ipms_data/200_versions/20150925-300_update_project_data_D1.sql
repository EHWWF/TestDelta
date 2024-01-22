alter table project disable all triggers;
update project set pidt_release_date=sysdate where area_code in ('PRD-MNT','RS','LG','LO','D3-TR','CO','D1') and pidt_release_date is null;
commit;
alter table project enable all triggers;