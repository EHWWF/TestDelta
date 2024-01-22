prompt ---->
prompt ---->
prompt 
prompt ---->START    project_area
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
insert into project_area(code,name,is_active) select 'CO','Controlling Object','1' from dual where not exists(select 1 from project_area where code = 'CO');
insert into project_area(code,name,is_active) select 'D2-PRJ','D2-Project','1' from dual where not exists(select 1 from project_area where code = 'D2-PRJ');
insert into project_area(code,name,is_active) select 'D3-TR','D3-Transition','1' from dual where not exists(select 1 from project_area where code = 'D3-TR');
insert into project_area(code,name,is_active) select 'LG','Lead Generation','1' from dual where not exists(select 1 from project_area where code = 'LG');
insert into project_area(code,name,is_active) select 'LO','Lead Optimization','1' from dual where not exists(select 1 from project_area where code = 'LO');
insert into project_area(code,name,is_active) select 'POST-POT','post-PoT','1' from dual where not exists(select 1 from project_area where code = 'POST-POT');
insert into project_area(code,name,is_active) select 'PRD-MNT','Product Maintenance','1' from dual where not exists(select 1 from project_area where code = 'PRD-MNT');
insert into project_area(code,name,is_active) select 'PRE-POT','pre-PoT','1' from dual where not exists(select 1 from project_area where code = 'PRE-POT');
insert into project_area(code,name,is_active) select 'RS','Research','1' from dual where not exists(select 1 from project_area where code = 'RS');
insert into project_area(code,name,is_active) select 'D1','D1-Project','1' from dual where not exists(select 1 from project_area where code = 'D1');

update project_area set is_pidt=0 where code in ('PRD-MNT','RS','LG','LO','D3-TR','CO') and is_pidt=1;
update project_area set is_pidt=1 where code in ('PRE-POT','POST-POT','D2-PRJ') and is_pidt=0;
update project_area set name='Pre-D2 Area' where code='D1';

commit;
prompt ---->END    project_area
prompt ---->
prompt ---->

/

prompt ---->START    project_area
prompt ---->
prompt ---->
SET SCAN OFF;

INSERT INTO IPMS_DATA.PROJECT_AREA (CODE, NAME, IS_RUNNING_IMPORT) VALUES ('SAMD', 'SaMD', 'SAMD');

commit;
prompt ---->END    project_area
prompt ---->
prompt ---->