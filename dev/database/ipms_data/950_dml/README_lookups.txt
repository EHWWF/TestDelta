Some lookups, that are not managed by End User are deleted from excel file and 
moved to separate DML folder.
Now, with every DB deployment will be all rows recreated.
-------------------------------------------------------------------------
...\dev\database\ipms_data\950_dml\500_lookups\project_area_milestone.sql
...\dev\database\ipms_data\950_dml\500_lookups\project_area_qplan_config.sql
...\dev\database\ipms_data\950_dml\500_lookups\configuration.sql
...\dev\database\ipms_data\950_dml\500_lookups\qplan_element_type.sql
...\dev\database\ipms_data\950_dml\500_lookups\license_type.sql

-------------------------------------------------------------------------
Useful SQL for preparing inserts: 


select termination_code,area_code
,'insert into termination_reason_area_code(termination_code,area_code) select '''||termination_code||''','''||area_code
||''' from dual where not exists(select 1 from termination_reason_area_code where termination_code = '''||termination_code||''' and area_code ='''||area_code||''');' insertttt 
from termination_reason_area_code 
order by area_code,to_number(termination_code);




select code, name, is_active,calculation_method_code
,'insert into prefill_type(code,name,is_active,calculation_method_code) select '''||code||''','''||name||''','''||is_active||
''','''||calculation_method_code||''' from dual where not exists(select 1 from prefill_type where code = '''||code||''');' insertttt 
from 
prefill_type 
--where code NOT in ('post D9')
--where code in ('1','2','3','n.a.')
--order by 1;
--order by to_number(code);


select code, name, is_active
,'insert into timeline_type(code,name,is_active) select '''||code||''','''||name||''','''||is_active||
''' from dual where not exists(select 1 from timeline_type where code = '''||code||''');' insertttt 
from 
timeline_type 
--where code NOT in ('post D9')
--where code in ('PCA','ONC','WHC','STH','CAR','HEM','R&I','CME','MOI','DRM','OPH','NEU')
--where code in ('R&I','SM','GM')
--where code in ('lic/acq','self')
order by 1;
--order by to_number(code);


select code, name, is_active
,'merge into function ooo using (select '''||code||''' code,'''||name||''' name,'''||is_active
||''' is_active from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = '''||name||''',ooo.is_active = '''||is_active
||''' when not matched then insert (code,name,is_active) values ('''||code||''','''||name||''','''||is_active||''');' insertttt 
from 
function 
--where code NOT in ('post D9')
--where code in ('ADJ','ADJBAY')
order by 1;


select code, name, is_active
,'merge into project_category ooo using (select '''||code||''' code,'''||name||''' name,'''||is_active
||''' is_active ,'''||is_promis||''' is_promis from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = '''||name||''',ooo.is_active = '''||is_active
||''',ooo.is_promis = '''||is_promis||''' when not matched then insert (code,name,is_active,is_promis) values ('''||code||''','''||name||''','''||is_active||''','''||is_promis||''');' insertttt 
from 
project_category  where is_promis=1 and maingroup_code is not null
--where code NOT in ('post D9')
--where code in ('ADJ','ADJBAY')
order by 1;


