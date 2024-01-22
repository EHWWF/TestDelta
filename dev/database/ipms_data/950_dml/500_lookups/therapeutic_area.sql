prompt ---->
prompt ---->
prompt 
prompt ---->START    therapeutic_area
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

insert into therapeutic_area(code,name,is_active) select 'CAR','Cardiology','1' from dual where not exists(select 1 from therapeutic_area where code = 'CAR');
insert into therapeutic_area(code,name,is_active) select 'CME','Contrast Media','1' from dual where not exists(select 1 from therapeutic_area where code = 'CME');
insert into therapeutic_area(code,name,is_active) select 'DRM','Dermatology','1' from dual where not exists(select 1 from therapeutic_area where code = 'DRM');
insert into therapeutic_area(code,name,is_active) select 'HEM','Hematology','1' from dual where not exists(select 1 from therapeutic_area where code = 'HEM');
insert into therapeutic_area(code,name,is_active) select 'R&I','Radiology & Intervention','1' from dual where not exists(select 1 from therapeutic_area where code = 'R&I');
insert into therapeutic_area(code,name,is_active) select 'MOI','Molecular Imaging','1' from dual where not exists(select 1 from therapeutic_area where code = 'MOI');
insert into therapeutic_area(code,name,is_active) select 'NEU','Neurology','1' from dual where not exists(select 1 from therapeutic_area where code = 'NEU');
insert into therapeutic_area(code,name,is_active) select 'ONC','Oncology','1' from dual where not exists(select 1 from therapeutic_area where code = 'ONC');
insert into therapeutic_area(code,name,is_active) select 'OPH','Ophthalmology','1' from dual where not exists(select 1 from therapeutic_area where code = 'OPH');
insert into therapeutic_area(code,name,is_active) select 'PCA','Primary Care','1' from dual where not exists(select 1 from therapeutic_area where code = 'PCA');
insert into therapeutic_area(code,name,is_active) select 'STH','Specialty Therapeutics','1' from dual where not exists(select 1 from therapeutic_area where code = 'STH');
insert into therapeutic_area(code,name,is_active) select 'WHC','Women''s Healthcare','1' from dual where not exists(select 1 from therapeutic_area where code = 'WHC');

commit;
prompt ---->END    therapeutic_area
prompt ---->
prompt ---->