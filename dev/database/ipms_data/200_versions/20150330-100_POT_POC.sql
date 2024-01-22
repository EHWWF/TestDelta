insert into configuration(code, name, value)
select 'POC', 'PoC Milestone ID', 'poc' from dual
where not exists(select 1 from configuration where code = 'POC');
delete from configuration where code = 'POT';
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DatePoC','PoC (Proof of Concept)','150','PoC','1' from dual where not exists(select 1 from qplan_element_type where code = 'DatePoC');
update qplan_element_type set is_active = 0 where code = 'DatePoT' and is_active=1;
update milestone set is_active = '0' where code = 'PoT';
merge into milestone ooo using (select 'PoC' code,'Proof of Concept' name,'1' is_active,'DEC' type_code from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'Proof of Concept',ooo.is_active = '1',ooo.type_code = 'DEC' when not matched then insert (code,name,is_active,type_code) values ('PoC','Proof of Concept','1','DEC');
update phase_milestone set milestone_code = 'PoC' where milestone_code = 'PoT';
update generic_timeline set milestone_code = 'PoC' where milestone_code = 'PoT';
commit;