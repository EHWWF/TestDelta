prompt ---->
prompt ---->
prompt 
prompt ---->START    project_area_qplan_config
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
delete from project_area_qplan_config;
insert into project_area_qplan_config(area_code,element_code,is_mandatory)
with table_source as
(
select 'PRE-POT' area_code,'DrugSubstance' element_code,'1' is_mandatory from dual union all
select 'PRE-POT','PlanningCode','1' from dual union all
select 'PRE-POT','LeadProject','0' from dual union all
select 'PRE-POT','DrugSubstanceType','1' from dual union all
select 'PRE-POT','ProjectPriority','0' from dual union all
select 'PRE-POT','ProjectArea','1' from dual union all
select 'PRE-POT','ProjectStatus','1' from dual union all
select 'PRE-POT','StrategicBusinessEntity','1' from dual union all
select 'PRE-POT','ProgramID','0' from dual union all
select 'PRE-POT','ProgramName','0' from dual union all
select 'PRE-POT','ProjectID','1' from dual union all
select 'PRE-POT','ProjectName','1' from dual union all
select 'PRE-POT','ControllingPortfolio','1' from dual union all
select 'PRE-POT','DateD03','0' from dual union all
select 'PRE-POT','DatePCC','0' from dual union all
select 'PRE-POT','DateCombToxFiMRC','0' from dual union all
select 'PRE-POT','DateD04','1' from dual union all
select 'PRE-POT','DateD05','0' from dual union all
select 'PRE-POT','DateIND','0' from dual union all
select 'PRE-POT','DatePoC','0' from dual union all
select 'PRE-POT','DateD06','1' from dual union all
select 'PRE-POT','DateD07','1' from dual union all
select 'PRE-POT','DateD08','1' from dual union all
select 'PRE-POT','DateD09','0' from dual union all
select 'PRE-POT','ProjectFinishedDate','0' from dual union all
select 'PRE-POT','LeadCandidateType','1' from dual union all
select 'POST-POT','DrugSubstance','1' from dual union all
select 'POST-POT','PlanningCode','1' from dual union all
select 'POST-POT','LeadProject','0' from dual union all
select 'POST-POT','DrugSubstanceType','1' from dual union all
select 'POST-POT','ProjectPriority','0' from dual union all
select 'POST-POT','ProjectArea','1' from dual union all
select 'POST-POT','ProjectStatus','1' from dual union all
select 'POST-POT','StrategicBusinessEntity','1' from dual union all
select 'POST-POT','ProgramID','0' from dual union all
select 'POST-POT','ProgramName','0' from dual union all
select 'POST-POT','ProjectID','1' from dual union all
select 'POST-POT','ProjectName','1' from dual union all
select 'POST-POT','ControllingPortfolio','1' from dual union all
select 'POST-POT','DateD03','0' from dual union all
select 'POST-POT','DatePCC','0' from dual union all
select 'POST-POT','DateCombToxFiMRC','0' from dual union all
select 'POST-POT','DateD04','1' from dual union all
select 'POST-POT','DateD05','0' from dual union all
select 'POST-POT','DateIND','0' from dual union all
select 'POST-POT','DatePoC','0' from dual union all
select 'POST-POT','DateD06','1' from dual union all
select 'POST-POT','DateD07','1' from dual union all
select 'POST-POT','DateD08','1' from dual union all
select 'POST-POT','DateD09','0' from dual union all
select 'POST-POT','ProjectFinishedDate','0' from dual union all
select 'POST-POT','LeadCandidateType','1' from dual union all
select 'D2-PRJ','DrugSubstance','1' from dual union all
select 'D2-PRJ','PlanningCode','1' from dual union all
select 'D2-PRJ','LeadProject','0' from dual union all
select 'D2-PRJ','DrugSubstanceType','1' from dual union all
select 'D2-PRJ','ProjectPriority','0' from dual union all
select 'D2-PRJ','ProjectArea','1' from dual union all
select 'D2-PRJ','ProjectStatus','1' from dual union all
select 'D2-PRJ','StrategicBusinessEntity','1' from dual union all
select 'D2-PRJ','ProjectID','1' from dual union all
select 'D2-PRJ','ProjectName','1' from dual union all
select 'D2-PRJ','ControllingPortfolio','0' from dual union all
select 'D2-PRJ','DateD01','1' from dual union all
select 'D2-PRJ','DateD02','1' from dual union all
select 'D2-PRJ','DateCSM','1' from dual union all
select 'D2-PRJ','DateD03','0' from dual union all
select 'D2-PRJ','DatePCC','0' from dual union all
select 'D2-PRJ','ProjectFinishedDate','0' from dual union all
select 'D2-PRJ','LeadCandidateType','0' from dual union all
select 'RS','ControllingPortfolio','0' from dual union all
select 'D3-TR','DrugSubstance','0' from dual union all
select 'D3-TR','PlanningCode','1' from dual union all
select 'D3-TR','LeadProject','0' from dual union all
select 'D3-TR','DrugSubstanceType','0' from dual union all
select 'D3-TR','ProjectPriority','0' from dual union all
select 'D3-TR','ProjectArea','1' from dual union all
select 'D3-TR','ProjectStatus','0' from dual union all
select 'D3-TR','StrategicBusinessEntity','1' from dual union all
select 'D3-TR','ProjectID','1' from dual union all
select 'D3-TR','ProjectName','1' from dual union all
select 'D3-TR','ControllingPortfolio','1' from dual union all
select 'D3-TR','DateCSM','1' from dual union all
select 'D3-TR','DateD03','0' from dual union all
select 'D3-TR','DatePCC','0' from dual union all
select 'LG','ControllingPortfolio','0' from dual union all
select 'D3-TR','DateD04','1' from dual union all
select 'D3-TR','DateD05','0' from dual union all
select 'LG','ProjectFinishedDate','0' from dual union all
select 'D3-TR','DateD06','1' from dual union all
select 'D3-TR','DateD07','1' from dual union all
select 'D3-TR','DateD08','1' from dual union all
select 'D3-TR','DateD09','0' from dual union all
select 'LG','DrugSubstance','0' from dual union all
select 'LG','DrugSubstanceType','0' from dual union all
select 'D3-TR','ProjectFinishedDate','0' from dual union all
select 'D3-TR','LeadCandidateType','0' from dual union all
select 'PRD-MNT','ControllingPortfolio','1' from dual union all
select 'PRD-MNT','ProjectFinishedDate','0' from dual union all
select 'PRD-MNT','DrugSubstance','1' from dual union all
select 'RS','ProjectFinishedDate','0' from dual union all
select 'RS','DrugSubstance','0' from dual union all
select 'RS','DrugSubstanceType','0' from dual union all
select 'RS','LeadCandidateType','0' from dual union all
select 'RS','LeadProject','0' from dual union all
select 'RS','PlanningCode','1' from dual union all
select 'RS','ProjectArea','1' from dual union all
select 'RS','ProjectID','1' from dual union all
select 'RS','ProjectName','1' from dual union all
select 'RS','ProjectPriority','0' from dual union all
select 'RS','ProjectStatus','0' from dual union all
select 'RS','StrategicBusinessEntity','1' from dual union all
select 'LG','LeadCandidateType','0' from dual union all
select 'LG','LeadProject','0' from dual union all
select 'LG','PlanningCode','1' from dual union all
select 'LG','ProjectArea','1' from dual union all
select 'LG','ProjectID','1' from dual union all
select 'LG','ProjectName','1' from dual union all
select 'LG','ProjectPriority','0' from dual union all
select 'LG','ProjectStatus','0' from dual union all
select 'LG','StrategicBusinessEntity','1' from dual union all
select 'LO','ControllingPortfolio','0' from dual union all
select 'LO','ProjectFinishedDate','0' from dual union all
select 'LO','DrugSubstance','0' from dual union all
select 'LO','DrugSubstanceType','0' from dual union all
select 'LO','LeadCandidateType','0' from dual union all
select 'LO','LeadProject','0' from dual union all
select 'LO','PlanningCode','1' from dual union all
select 'LO','ProjectArea','1' from dual union all
select 'LO','ProjectID','1' from dual union all
select 'LO','ProjectName','1' from dual union all
select 'LO','ProjectPriority','0' from dual union all
select 'LO','ProjectStatus','0' from dual union all
select 'LO','StrategicBusinessEntity','1' from dual union all
select 'PRD-MNT','DrugSubstanceType','0' from dual union all
select 'PRD-MNT','LeadCandidateType','0' from dual union all
select 'PRD-MNT','LeadProject','0' from dual union all
select 'PRD-MNT','PlanningCode','1' from dual union all
select 'PRD-MNT','ProgramID','0' from dual union all
select 'PRD-MNT','ProgramName','0' from dual union all
select 'PRD-MNT','ProjectArea','1' from dual union all
select 'PRD-MNT','ProjectID','1' from dual union all
select 'PRD-MNT','ProjectName','1' from dual union all
select 'PRD-MNT','ProjectPriority','0' from dual union all
select 'PRD-MNT','ProjectStatus','0' from dual union all
select 'PRD-MNT','StrategicBusinessEntity','1' from dual union all
select 'CO','ControllingPortfolio','1' from dual union all
select 'CO','ProjectFinishedDate','0' from dual union all
select 'CO','DrugSubstance','0' from dual union all
select 'CO','DrugSubstanceType','0' from dual union all
select 'CO','LeadCandidateType','0' from dual union all
select 'CO','LeadProject','0' from dual union all
select 'CO','PlanningCode','1' from dual union all
select 'CO','ProjectArea','1' from dual union all
select 'CO','ProjectID','1' from dual union all
select 'CO','ProjectName','1' from dual union all
select 'CO','ProjectPriority','0' from dual union all
select 'CO','ProjectStatus','0' from dual union all
select 'CO','StrategicBusinessEntity','1' from dual
) 
select area_code,element_code,is_mandatory from table_source;
commit;
prompt ---->END    project_area_qplan_config
prompt ---->
prompt ---->