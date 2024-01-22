prompt ---->
prompt ---->
prompt 
prompt ---->START    termination_reason
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into termination_reason(code,name,is_active) select '1','Scientific','1' from dual where not exists(select 1 from termination_reason where code = '1');
insert into termination_reason(code,name,is_active) select '2','Strategic','1' from dual where not exists(select 1 from termination_reason where code = '2');
insert into termination_reason(code,name,is_active) select '3','Safety','1' from dual where not exists(select 1 from termination_reason where code = '3');
insert into termination_reason(code,name,is_active) select '4','Other','1' from dual where not exists(select 1 from termination_reason where code = '4');
insert into termination_reason(code,name,is_active) select '5','Business','1' from dual where not exists(select 1 from termination_reason where code = '5');

insert into termination_reason(code,name,is_active, ref_reason_code) select '6','Animal Model Efficacy','1','1' from dual where not exists(select 1 from termination_reason where code = '6');
insert into termination_reason(code,name,is_active, ref_reason_code) select '7','Assay Robustness ','1','1' from dual where not exists(select 1 from termination_reason where code = '7');
insert into termination_reason(code,name,is_active, ref_reason_code) select '8','Drug Metabolism ','1','1' from dual where not exists(select 1 from termination_reason where code = '8');
insert into termination_reason(code,name,is_active, ref_reason_code) select '9','Formulation','1','1' from dual where not exists(select 1 from termination_reason where code = '9');
insert into termination_reason(code,name,is_active, ref_reason_code) select '10','Hypothesis/Target Validation ','1','1' from dual where not exists(select 1 from termination_reason where code = '10');
insert into termination_reason(code,name,is_active, ref_reason_code) select '11','No Hits Found/No Progressable Leads ','1','1' from dual where not exists(select 1 from termination_reason where code = '11');
insert into termination_reason(code,name,is_active, ref_reason_code) select '12','Other ','1','1' from dual where not exists(select 1 from termination_reason where code = '12');
insert into termination_reason(code,name,is_active, ref_reason_code) select '13','PK','1','1' from dual where not exists(select 1 from termination_reason where code = '13');
insert into termination_reason(code,name,is_active, ref_reason_code) select '14','Process R&D (large scale synthesis)','1','1' from dual where not exists(select 1 from termination_reason where code = '14');
insert into termination_reason(code,name,is_active, ref_reason_code) select '15','Selectivity/Specificity In Vitro','1','1' from dual where not exists(select 1 from termination_reason where code = '15');
insert into termination_reason(code,name,is_active, ref_reason_code) select '16','Toxicology','1','1' from dual where not exists(select 1 from termination_reason where code = '16');
insert into termination_reason(code,name,is_active, ref_reason_code) select '17','Commercial Viability','1','5' from dual where not exists(select 1 from termination_reason where code = '17');
insert into termination_reason(code,name,is_active, ref_reason_code) select '18','Merger/Acquisition','1','5' from dual where not exists(select 1 from termination_reason where code = '18');
insert into termination_reason(code,name,is_active, ref_reason_code) select '19','Other','1','5' from dual where not exists(select 1 from termination_reason where code = '19');
insert into termination_reason(code,name,is_active, ref_reason_code) select '20','Patent Issue','1','5' from dual where not exists(select 1 from termination_reason where code = '20');
insert into termination_reason(code,name,is_active, ref_reason_code) select '21','Portfolio Decision','1','5' from dual where not exists(select 1 from termination_reason where code = '21');
insert into termination_reason(code,name,is_active, ref_reason_code) select '22','Clinical Safety','1','1' from dual where not exists(select 1 from termination_reason where code = '22');
insert into termination_reason(code,name,is_active, ref_reason_code) select '23','Efficacy','1','1' from dual where not exists(select 1 from termination_reason where code = '23');
insert into termination_reason(code,name,is_active, ref_reason_code) select '24','PK/Bioavailability','1','1' from dual where not exists(select 1 from termination_reason where code = '24');
insert into termination_reason(code,name,is_active, ref_reason_code) select '25','Cost Of Goods','1','5' from dual where not exists(select 1 from termination_reason where code = '25');
insert into termination_reason(code,name,is_active, ref_reason_code) select '26','Legal Divestiture','1','5' from dual where not exists(select 1 from termination_reason where code = '26');
insert into termination_reason(code,name,is_active, ref_reason_code) select '27','Market Potential','1','5' from dual where not exists(select 1 from termination_reason where code = '27');
insert into termination_reason(code,name,is_active, ref_reason_code) select '28','Resources','1','5' from dual where not exists(select 1 from termination_reason where code = '28');
insert into termination_reason(code,name,is_active, ref_reason_code) select '29','Strategic','1','5' from dual where not exists(select 1 from termination_reason where code = '29');

commit;
prompt ---->END    termination_reason
prompt ---->
prompt ---->