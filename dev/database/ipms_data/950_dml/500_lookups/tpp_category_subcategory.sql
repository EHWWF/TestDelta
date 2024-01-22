prompt ---->
prompt ---->
prompt 
prompt ---->START    tpp_category/tpp_subcategory
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;

merge into tpp_category ooo using (select 'IN' code, 'Intake'   name, '1' is_active, null description from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = nnn.name, ooo.is_active = nnn.is_active, ooo.description = nnn.description when not matched then insert (code, name, is_active, description) values (nnn.code, nnn.name, nnn.is_active, nnn.description);
merge into tpp_category ooo using (select 'BE' code, 'Benefits' name, '1' is_active, null description from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = nnn.name, ooo.is_active = nnn.is_active, ooo.description = nnn.description when not matched then insert (code, name, is_active, description) values (nnn.code, nnn.name, nnn.is_active, nnn.description);
merge into tpp_category ooo using (select 'RI' code, 'Risks'    name, '1' is_active, null description from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = nnn.name, ooo.is_active = nnn.is_active, ooo.description = nnn.description when not matched then insert (code, name, is_active, description) values (nnn.code, nnn.name, nnn.is_active, nnn.description);

merge into tpp_subcategory ooo using (select 'IN' category_code, 'PPD' code, 'Pharmaceutical Product Description'   name, '1' is_active, null description from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.category_code = nnn.category_code, ooo.name = nnn.name, ooo.is_active = nnn.is_active, ooo.description = nnn.description when not matched then insert (code, category_code, name, is_active, description) values (nnn.code, nnn.category_code, nnn.name, nnn.is_active, nnn.description);
merge into tpp_subcategory ooo using (select 'BE' category_code, 'CLE' code, 'Clinical Efficacy'                    name, '1' is_active, null description from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.category_code = nnn.category_code, ooo.name = nnn.name, ooo.is_active = nnn.is_active, ooo.description = nnn.description when not matched then insert (code, category_code, name, is_active, description) values (nnn.code, nnn.category_code, nnn.name, nnn.is_active, nnn.description);
merge into tpp_subcategory ooo using (select 'BE' category_code, 'QOL' code, 'Quality of Life'                      name, '1' is_active, null description from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.category_code = nnn.category_code, ooo.name = nnn.name, ooo.is_active = nnn.is_active, ooo.description = nnn.description when not matched then insert (code, category_code, name, is_active, description) values (nnn.code, nnn.category_code, nnn.name, nnn.is_active, nnn.description);
merge into tpp_subcategory ooo using (select 'BE' category_code, 'HCR' code, 'Healthcare Resource'                  name, '1' is_active, null description from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.category_code = nnn.category_code, ooo.name = nnn.name, ooo.is_active = nnn.is_active, ooo.description = nnn.description when not matched then insert (code, category_code, name, is_active, description) values (nnn.code, nnn.category_code, nnn.name, nnn.is_active, nnn.description);
merge into tpp_subcategory ooo using (select 'BE' category_code, 'SCA' code, 'Societal Aspects'                     name, '1' is_active, null description from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.category_code = nnn.category_code, ooo.name = nnn.name, ooo.is_active = nnn.is_active, ooo.description = nnn.description when not matched then insert (code, category_code, name, is_active, description) values (nnn.code, nnn.category_code, nnn.name, nnn.is_active, nnn.description);
merge into tpp_subcategory ooo using (select 'RI' category_code, 'CLS' code, 'Clinical Safety'                      name, '1' is_active, null description from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.category_code = nnn.category_code, ooo.name = nnn.name, ooo.is_active = nnn.is_active, ooo.description = nnn.description when not matched then insert (code, category_code, name, is_active, description) values (nnn.code, nnn.category_code, nnn.name, nnn.is_active, nnn.description);

commit;
prompt ---->END    tpp_category/tpp_subcategory
prompt ---->
prompt ---->