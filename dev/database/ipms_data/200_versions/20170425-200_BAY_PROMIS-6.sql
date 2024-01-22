prompt 
prompt ---->START Create DB tables TARGET_CLASS and TARGET_ORIGIN
prompt 
create table Target_Class (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));
create table Target_Origin (
	code nvarchar2(10) not null primary key,
	name nvarchar2(100) not null,
	description nvarchar2(500),
	is_active number(1) default 1 not null check(is_active in (0,1)));
prompt 
prompt ---->END Create DB tables TARGET_CLASS and TARGET_ORIGIN
prompt ---->START Fill DB tables TARGET_CLASS and TARGET_ORIGIN with data
prompt 
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
insert into target_origin (code,name,is_active) select 'CAC','Collaboration – Academic','1' from dual where not exists(select 1 from target_origin where code = 'CAC');
insert into target_origin (code,name,is_active) select 'CIN','Collaboration – Industry','1' from dual where not exists(select 1 from target_origin where code = 'CIN');
insert into target_origin (code,name,is_active) select 'IH','In-House','1' from dual where not exists(select 1 from target_origin where code = 'IH');
insert into target_origin (code,name,is_active) select 'LIT','Literature','1' from dual where not exists(select 1 from target_origin where code = 'LIT');
insert into target_origin (code,name,is_active) select 'OTH','Other','1' from dual where not exists(select 1 from target_origin where code = 'OTH');
insert into target_origin (code,name,is_active) select 'UNK','Unknown','1' from dual where not exists(select 1 from target_origin where code = 'UNK');
commit;
prompt 
prompt ---->END Fill DB tables TARGET_CLASS and TARGET_ORIGIN with data
prompt 
alter table project add 
(
tc_code nvarchar2(10) references Target_Class(code),
to_code nvarchar2(10) references Target_Origin(code),
details_comment nvarchar2(2000)
);