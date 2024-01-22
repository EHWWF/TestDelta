prompt 
prompt ---->START D1 milestone is reported to QuickPLAN for D2 Projects
prompt 
insert into qplan_element_type (code, name, order_by, is_active, milestone_code) values ('DateD01', 'D1', 95, 1, 'D1');
insert into project_area_qplan_config (area_code, element_code, is_mandatory) values ('D2-PRJ', 'DateD01', 1);
prompt 
prompt ---->END D1 milestone is reported to QuickPLAN for D2 Projects
prompt ---->START ComTox milestone code is renamed to FiM-RC
prompt 
insert into milestone (code,name,is_active,type_code,is_lead_study_relevant,wbs_category)
select 'FiM-RC',name,is_active,type_code,is_lead_study_relevant,wbs_category
from milestone where code = 'ComTox';
update qplan_element_type set milestone_code = 'FiM-RC' where milestone_code = 'ComTox';
delete from milestone where code = 'ComTox';
commit;
prompt 
prompt ---->ERROR FEHLER -- it is just a markup that after deployment some action must be taken
prompt ---->END ComTox milestone code is renamed to FiM-RC
prompt ---->Milestone Code changed from ComTox to FiM-RC as part of BAY_PROMIS-7 - Update P6 and run ReatTimeline for selected projects.
prompt ---->Please, change global activity code in Primavera P6 as follows: Milestone Type -> Development Milestones -> ComTox TO FiM-RC
prompt