prompt ---->
prompt ---->
prompt 
prompt ---->START    phase
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

merge into phase ooo using (select '1' code,'Preclinical' name,'1' is_active ,'5' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'Preclinical',ooo.is_active = '1',ooo.ordering = '5' when not matched then insert (code,name,is_active,ordering) values ('1','Preclinical','1','5');
merge into phase ooo using (select '2' code,'Phase I' name,'1' is_active ,'10' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'Phase I',ooo.is_active = '1',ooo.ordering = '10' when not matched then insert (code,name,is_active,ordering) values ('2','Phase I','1','10');
merge into phase ooo using (select '3' code,'Phase IIa' name,'1' is_active ,'23' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'Phase IIa',ooo.is_active = '1',ooo.ordering = '23' when not matched then insert (code,name,is_active,ordering) values ('3','Phase IIa','1','23');
merge into phase ooo using (select '4' code,'Phase IIb' name,'1' is_active ,'27' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'Phase IIb',ooo.is_active = '1',ooo.ordering = '27' when not matched then insert (code,name,is_active,ordering) values ('4','Phase IIb','1','27');
merge into phase ooo using (select '5' code,'Phase III' name,'1' is_active ,'30' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'Phase III',ooo.is_active = '1',ooo.ordering = '30' when not matched then insert (code,name,is_active,ordering) values ('5','Phase III','1','30');
merge into phase ooo using (select '6' code,'Submission' name,'1' is_active ,'50' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'Submission',ooo.is_active = '1',ooo.ordering = '50' when not matched then insert (code,name,is_active,ordering) values ('6','Submission','1','50');
merge into phase ooo using (select '7' code,'Launch' name,'1' is_active ,'60' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'Launch',ooo.is_active = '1',ooo.ordering = '60' when not matched then insert (code,name,is_active,ordering) values ('7','Launch','1','60');
merge into phase ooo using (select '8' code,'FSB' name,'0' is_active ,'' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'FSB',ooo.is_active = '0',ooo.ordering = '' when not matched then insert (code,name,is_active,ordering) values ('8','FSB','0','');
merge into phase ooo using (select '9' code,'n/a' name,'1' is_active ,'' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'n/a',ooo.is_active = '1',ooo.ordering = '' when not matched then insert (code,name,is_active,ordering) values ('9','n/a','1','');
merge into phase ooo using (select '10' code,'IV' name,'0' is_active ,'40' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'IV',ooo.is_active = '0',ooo.ordering = '40' when not matched then insert (code,name,is_active,ordering) values ('10','IV','0','40');
merge into phase ooo using (select '11' code,'Registration' name,'1' is_active ,'32' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'Registration',ooo.is_active = '1',ooo.ordering = '32' when not matched then insert (code,name,is_active,ordering) values ('11','Registration','1','32');
merge into phase ooo using (select '12' code,'Approval' name,'1' is_active ,'36' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'Approval',ooo.is_active = '1',ooo.ordering = '36' when not matched then insert (code,name,is_active,ordering) values ('12','Approval','1','36');
merge into phase ooo using (select '15' code,'Lead Optimization' name,'1' is_active ,'0' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'Lead Optimization',ooo.is_active = '1',ooo.ordering = '0' when not matched then insert (code,name,is_active,ordering) values ('15','Lead Optimization','1','0');
merge into phase ooo using (select '16' code,'PoC-D6' name,'1' is_active ,'25' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'PoC-D6',ooo.is_active = '1',ooo.ordering = '25' when not matched then insert (code,name,is_active,ordering) values ('16','PoC-D6','1','25');
merge into phase ooo using (select '34' code,'Phase II' name,'1' is_active ,'20' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'Phase II',ooo.is_active = '1',ooo.ordering = '20' when not matched then insert (code,name,is_active,ordering) values ('34','Phase II','1','20');
merge into phase ooo using (select '14' code,'Lead Generation' name,'1' is_active ,'-14' ordering from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'Lead Generation',ooo.is_active = '1',ooo.ordering = '-14' when not matched then insert (code,name,is_active,ordering) values ('14','Lead Generation','1','-14');

commit;
prompt ---->END    phase
prompt ---->
prompt ---->

/
prompt ---->START    phase
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
INSERT INTO IPMS_DATA.PHASE (CODE, NAME, IS_ACTIVE, ORDERING) VALUES ('SAMD.1', 'Ideation', '1', 150);
INSERT INTO IPMS_DATA.PHASE (CODE, NAME, IS_ACTIVE, ORDERING) VALUES ('SAMD.2', 'Feasibility/Concept Finalization', '1', 160);
INSERT INTO IPMS_DATA.PHASE (CODE, NAME, IS_ACTIVE, ORDERING) VALUES ('SAMD.3', 'Product Development', '1', 170);
INSERT INTO IPMS_DATA.PHASE (CODE, NAME, IS_ACTIVE, ORDERING) VALUES ('SAMD.4', 'Product Deployment & Localization', '1', 180);
INSERT INTO IPMS_DATA.PHASE (CODE, NAME, IS_ACTIVE, ORDERING) VALUES ('SAMD.5', 'Life Cycle Management', '1', 190);

commit;
prompt ---->END    phase
prompt ---->
prompt ---->