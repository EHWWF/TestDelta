prompt ---->
prompt ---->
prompt 
prompt ---->START    target_class
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into target_class (code,name,is_active) select 'CCG','Cytokine/Chemokine/Growth Factor','1' from dual where not exists(select 1 from target_class where code = 'CCG');
insert into target_class (code,name,is_active) select 'GPC','GPCR Receptor','1' from dual where not exists(select 1 from target_class where code = 'GPC');
insert into target_class (code,name,is_active) select 'KIN','Kinase','1' from dual where not exists(select 1 from target_class where code = 'KIN');
insert into target_class (code,name,is_active) select 'NHR','Nuclear Hormone Receptor','1' from dual where not exists(select 1 from target_class where code = 'NHR');
insert into target_class (code,name,is_active) select 'OTH','Other','1' from dual where not exists(select 1 from target_class where code = 'OTH');
insert into target_class (code,name,is_active) select 'OSMR','Other Cell Surface Membrane Bound Receptor','1' from dual where not exists(select 1 from target_class where code = 'OSMR');
insert into target_class (code,name,is_active) select 'OEZ','Other Enzyme','1' from dual where not exists(select 1 from target_class where code = 'OEZ');
insert into target_class (code,name,is_active) select 'OPA','Other Protein-Nucleic Acid Interaction','1' from dual where not exists(select 1 from target_class where code = 'OPA');
insert into target_class (code,name,is_active) select 'POL','Polymerase','1' from dual where not exists(select 1 from target_class where code = 'POL');
insert into target_class (code,name,is_active) select 'PRO','Protease/Peptidase','1' from dual where not exists(select 1 from target_class where code = 'PRO');
insert into target_class (code,name,is_active) select 'TRA','Transporter','1' from dual where not exists(select 1 from target_class where code = 'TRA');
insert into target_class (code,name,is_active) select 'UNK','Unknown','1' from dual where not exists(select 1 from target_class where code = 'UNK');

commit;
prompt ---->END    target_class
prompt ---->
prompt ---->