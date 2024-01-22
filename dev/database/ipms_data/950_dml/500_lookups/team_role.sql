prompt ---->
prompt ---->
prompt 
prompt ---->START    team_role
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'ALL_MNG','Alliance Manager','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'ALL_MNG');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'ALL_MNG_Core','Alliance Manager (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'ALL_MNG_Core');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'ASS','Assistant','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'ASS');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'BPL','Biomarker Project Leader','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'BPL');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'BPL_Core','Biomarker Project Leader (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'BPL_Core');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'CALL','CALL','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'CALL');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'CALL_Core','CALL (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'CALL_Core');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'ECL_CPL','Early Clin Leader/ Clin Pharm Leader','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'ECL_CPL');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'ECL_CPL_Core','Early Clin Leader/ Clin Pharm Leader (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'ECL_CPL_Core');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GCL','Global Clinical Leader (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GCL');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GED_TOX_DMPK','GED (Tox & DMPK)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GED_TOX_DMPK');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GED_TOX_DMPK_Core','GED (Tox & DMPK) (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GED_TOX_DMPK_Core');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GMACS_MASL','GMACS/MASL','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GMACS_MASL');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GMACS_MASL_Core','GMACS/MASL (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GMACS_MASL_Core');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GMA_PH','GMA Physician','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GMA_PH');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GMA_PH_Core','GMA Physician (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GMA_PH_Core');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GPDC_GB','GCPD/GB Rep','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GPDC_GB');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GPDC_GB_Core','GCPD/GB Rep (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GPDC_GB_Core');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GPH','Global Program Head','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GPH');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GPM','Global Program Manager','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GPM');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GRS','Global Reg Strategist (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GRS');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GSL','Global Safety Leader','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GSL');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GSL_Core','Global Safety Leader (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GSL_Core');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'GST','Guest','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'GST');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'LGL','Legal','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'LGL');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'LGL_Core','Legal (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'LGL_Core');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'LOPL','Lead Optimization Project Leader','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'LOPL');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'MKT_REP','Marketing Rep','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'MKT_REP');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'MKT_REP_Core','Marketing Rep (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'MKT_REP_Core');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'PH_REP','Pharmacology Rep','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'PH_REP');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'PH_REP_Core','Pharmacology Rep (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'PH_REP_Core');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'PPC','Program Patent Counsel','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'PPC');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'PPC_Core','Program Patent Counsel (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'PPC_Core');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'PS_MNG','PS Manager','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'PS_MNG');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'PS_MNG_Core','PS Manager (Core)','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'PS_MNG_Core');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'RPL','Regional Project Leader','1','1','1','1' from dual where not exists(select 1 from team_role where code = 'RPL');
insert into team_role(code,name,is_active,is_dev_relevant,is_prdmnt_relevant,is_d2prj_relevant) select 'LOPC','LOP Coordinator','1','0','0','1' from dual where not exists(select 1 from team_role where code = 'LOPC');

commit;
prompt ---->END    team_role
prompt ---->
prompt ---->