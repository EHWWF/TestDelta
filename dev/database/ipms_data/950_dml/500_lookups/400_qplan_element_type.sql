prompt ---->
prompt ---->
prompt 
prompt ---->START    qplan_element_type
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DrugSubstance','com.bayer.ipms.model.views.ProjectView.BayName_LABEL','40','','1' from dual where not exists(select 1 from qplan_element_type where code = 'DrugSubstance');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'PlanningCode','com.bayer.ipms.model.views.ProjectView.PlanningCode_LABEL','60','','1' from dual where not exists(select 1 from qplan_element_type where code = 'PlanningCode');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'LeadProject','com.bayer.ipms.model.views.ProjectView.IsLead_LABEL','15','','1' from dual where not exists(select 1 from qplan_element_type where code = 'LeadProject');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DrugSubstanceType','com.bayer.ipms.model.views.ProjectView.SubstanceTypeCode_LABEL','5','','1' from dual where not exists(select 1 from qplan_element_type where code = 'DrugSubstanceType');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'LeadCandidateType','com.bayer.ipms.model.views.ProjectView.CategoryCode_LABEL','10','','1' from dual where not exists(select 1 from qplan_element_type where code = 'LeadCandidateType');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'ProjectPriority','com.bayer.ipms.model.views.ProjectView.PriorityName_LABEL','20','','1' from dual where not exists(select 1 from qplan_element_type where code = 'ProjectPriority');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'ProjectArea','com.bayer.ipms.model.views.ProjectView.AreaCode_LABEL','25','','1' from dual where not exists(select 1 from qplan_element_type where code = 'ProjectArea');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'ProjectStatus','com.bayer.ipms.model.views.ProjectView.StateCode_LABEL','30','','1' from dual where not exists(select 1 from qplan_element_type where code = 'ProjectStatus');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'TherapeuticArea','com.bayer.ipms.model.views.ProjectView.TaName_LABEL','35','','1' from dual where not exists(select 1 from qplan_element_type where code = 'TherapeuticArea');
update qplan_element_type set is_active = 0 where code = 'TherapeuticArea' and is_active=1;
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'StrategicBusinessEntity','com.bayer.ipms.model.views.ProjectView.SbeName_LABEL','36','','1' from dual where not exists(select 1 from qplan_element_type where code = 'StrategicBusinessEntity');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'ProgramID','com.bayer.ipms.model.views.ProgramView.Code_LABEL','45','','1' from dual where not exists(select 1 from qplan_element_type where code = 'ProgramID');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'ProgramName','com.bayer.ipms.model.views.ProgramView.SearchName_LABEL','50','','1' from dual where not exists(select 1 from qplan_element_type where code = 'ProgramName');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'ProjectID','com.bayer.ipms.model.views.ProjectView.Code_LABEL','55','','1' from dual where not exists(select 1 from qplan_element_type where code = 'ProjectID');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'ProjectName','com.bayer.ipms.model.views.ProjectView.SearchName_LABEL','65','','1' from dual where not exists(select 1 from qplan_element_type where code = 'ProjectName');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'ControllingPortfolio','Red/Green-Flag','70','','1' from dual where not exists(select 1 from qplan_element_type where code = 'ControllingPortfolio');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DateD01','D1','95','D1','1' from dual where not exists(select 1 from qplan_element_type where code = 'DateD01');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DateD02','D2','100','D2','1' from dual where not exists(select 1 from qplan_element_type where code = 'DateD02');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DateCSM','CSM','105','CSM','1' from dual where not exists(select 1 from qplan_element_type where code = 'DateCSM');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DateD03','D3 (Start preclinical development)','110','D3','1' from dual where not exists(select 1 from qplan_element_type where code = 'DateD03');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DatePCC','Preclinical Candidate','115','PCC','1' from dual where not exists(select 1 from qplan_element_type where code = 'DatePCC');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DateCombToxFiMRC','Combined Tox / FiM Release Conference','120','FiM-RC','1' from dual where not exists(select 1 from qplan_element_type where code = 'DateCombToxFiMRC');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DateD04','D4 (Start Clinical development)','130','D4','1' from dual where not exists(select 1 from qplan_element_type where code = 'DateD04');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DateIND','M4A','140','M4A','1' from dual where not exists(select 1 from qplan_element_type where code = 'DateIND');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DatePoC','PoC (Proof of Concept)','150','PoC','1' from dual where not exists(select 1 from qplan_element_type where code = 'DatePoC');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DateD05','Phase IIa Decision','155','D5','1' from dual where not exists(select 1 from qplan_element_type where code = 'DateD05');
update qplan_element_type set is_active = 0 where code = 'DatePoT' and is_active=1;
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DateD06','D6 (Start Phase IIb)','160','D6','1' from dual where not exists(select 1 from qplan_element_type where code = 'DateD06');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DateD07','D7 (Start Phase III)','170','D7','1' from dual where not exists(select 1 from qplan_element_type where code = 'DateD07');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DateD08','D8 (Release for submission)','180','D8','1' from dual where not exists(select 1 from qplan_element_type where code = 'DateD08');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DateD09','M9 - First Launch','190','M9','1' from dual where not exists(select 1 from qplan_element_type where code = 'DateD09');
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DateTermination','Termination date','200','','1' from dual where not exists(select 1 from qplan_element_type where code = 'DateTermination');
update qplan_element_type set is_active = 0 where code = 'DateTermination' and is_active=1;
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'DateCompletion','Completion date','210','','1' from dual where not exists(select 1 from qplan_element_type where code = 'DateCompletion');
update qplan_element_type set is_active = 0 where code = 'DateCompletion' and is_active=1;
insert into qplan_element_type(code,name,order_by,milestone_code,is_active) select 'ProjectFinishedDate','Project finished','220','','1' from dual where not exists(select 1 from qplan_element_type where code = 'ProjectFinishedDate');

commit;
prompt ---->END    qplan_element_type
prompt ---->
prompt ---->