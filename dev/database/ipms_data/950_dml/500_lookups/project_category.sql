prompt ---->
prompt ---->
prompt 
prompt ---->START    project_category
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
merge into project_category ooo using (select 'ME' code,'molecular entity' name,'1' is_active ,'1' is_promis, '9001' correlation_id from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'molecular entity',ooo.is_active = '1',ooo.is_promis = '1', correlation_id='9001' when not matched then insert (code,name,is_active,is_promis,correlation_id) values ('ME','molecular entity','1','1','9001');
merge into project_category ooo using (select 'NF' code,'new formulation' name,'1' is_active ,'1' is_promis, '9002' correlation_id from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'new formulation',ooo.is_active = '1',ooo.is_promis = '1', correlation_id='9002' when not matched then insert (code,name,is_active,is_promis,correlation_id) values ('NF','new formulation','1','1','9002');
merge into project_category ooo using (select 'NI' code,'new indication' name,'1' is_active ,'1' is_promis, '9003' correlation_id from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'new indication',ooo.is_active = '1',ooo.is_promis = '1', correlation_id='9003' when not matched then insert (code,name,is_active,is_promis,correlation_id) values ('NI','new indication','1','1','9003');
merge into project_category ooo using (select 'NM' code,'new molecule' name,'1' is_active ,'1' is_promis, '9004' correlation_id from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'new molecule',ooo.is_active = '1',ooo.is_promis = '1', correlation_id='9004' when not matched then insert (code,name,is_active,is_promis,correlation_id) values ('NM','new molecule','1','1','9004');
merge into project_category ooo using (select 'ped' code,'pediatric project' name,'1' is_active ,'1' is_promis, '9005' correlation_id from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'pediatric project',ooo.is_active = '1',ooo.is_promis = '1', correlation_id='9005' when not matched then insert (code,name,is_active,is_promis,correlation_id) values ('ped','pediatric project','1','1','9005');
commit;
prompt ---->END    project_category
prompt ---->
prompt ---->