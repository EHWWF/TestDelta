--------------------------------------------------------
--  DDL for Materialized View PROJECT_DIM
--------------------------------------------------------
DROP MATERIALIZED VIEW PROJECT_DIM;
  CREATE MATERIALIZED VIEW IPMS_REPO.PROJECT_DIM (ID, PROGRAM_ID, CODE, NAME, SHORT_NAME, PROJECT_STATE_CODE, PROJECT_STATE, IS_ACTIVE, IS_LEAD, LE_OVERVIEW_CODE, LE_OVERVIEW, SBE_CODE, SBE, GBU_CODE, GBU, THERAPEUTIC_AREA_CODE, THERAPEUTIC_AREA, PROJECT_AREA_CODE, PROJECT_AREA, PHASE_CODE, PHASE, PRIORITY_CODE, PRIORITY, LC_TYPE_CODE, LC_TYPE, SUBGROUP_CODE, SUBGROUP_NAME, MAINGROUP_CODE, MAINGROUP_NAME, SUBSTANCE_TYPE_CODE, SUBSTANCE_TYPE, SOURCE_CODE, SOURCE, TARGET_CLASS_CODE, TARGET_CLASS, TARGET_ORIGIN_CODE, TARGET_ORIGIN, ENPV, NPV, PEAK_SALES, PORTFOLIO_PROJECT, HPR, IS_REGIONAL, IS_ORPHAN_DRUG, COLLABORATION, PIP_PROJECT, PIP_DATE, PDCO_DATE, IS_PDCO_POSITIVE, IS_WAIVER, PIP_ACTIVITIES, TERMINATION_NAME, TERMINATION_CODE, TERMINATION_DATE, TERMINATION_REASON, PTS_PRECLINICAL, PTS_PHASE1, PTS_PHASE2, PTS_PHASE3, PTS_SUBMISSION, PTS_TOTAL, REVIEW_MEETING_DATE, DETAILS_PARTNER, DETAILS_PROGRESS, PROGRESS_DATE, DETAILS_CRITERIA, DETAILS_MESH, DETAILS_INDICATION, DETAILS_PRODUCT, DETAILS_GOAL, DETAILS_ACTION, DETAILS_COMPETITION, DETAILS_PATENT, DETAILS_SALES, DETAILS_PMO, DETAILS_COMMENT, DETAILS_MODALITY, COMBINATION_CODE, COMBINATION_ID, PREFERRED_BAY_NO, P6_RAW_PLAN, P6_CURRENT_PLAN, P6_APPROVED_PLAN, PLANNING_ENABLED, IP_OWNER_CODE, IP_OWNER, D1_MILESTONE_FOR_D1_PRJ, D1_GOAL_FACTOR_FOR_D1_PRJ, START_HTS_MILESTONE, LSA_DATE, TERMINATION_GOAL_FACTOR, D2_COMPOUND, SUCCESSOR_PROJECT_ID, PREDECESSOR_PROJECT_ID, D3TRANSITION_PROJECT_ID, LO_REVIEW_MEETING_DATE, LO_REVIEW_RESULT_CODE, THERAPEUTIC_RESEARCH_GROUP, TARGET_GENE_CODE, EXPLORATORY_RESEARCH, GENERAL_PROJECT_FRAME, PHASE_ESTIMATED_CODE, PHASE_ESTIMATED, PTR_FOR_D2_CODE, PTR_FOR_D3_CODE, PREVIOUS_NAMES, DEVICE_PROJECT, BPI_NO, PROJECT_DEVICE_TYPE_CODE, PROJECT_DEVICE_TYPE_NAME, REGULATORY_CODE, REGULATORY_NAME, REGULATORY_OTHER, DEVICE_PHASE_CODE, DEVICE_PHASE_NAME, DET_OBJECTIVE_MSP, DET_RATIONALE_MSP, DET_SCOPE_MSP, DET_INTENDED_USE_MSP, DET_BENEFITS_MSP, DET_EXECUTIVE_SUMMARY_MSP, DET_RISKS_MSP, DET_HIGHLIGHTS_MSP, DET_ACTIVITIES_EVENTS_MSP, DET_BUDGET_MSP, DET_SAMD_STATUS_MSP, DET_SAMD_STATUS_CODE_MSP, DET_BUDGET_STATUS_MSP, DET_BUDGET_STATUS_CODE_MSP)
  ORGANIZATION HEAP PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE USERS   NO INMEMORY 
  BUILD IMMEDIATE
  USING INDEX 
  REFRESH FORCE ON DEMAND
  USING DEFAULT LOCAL ROLLBACK SEGMENT
  USING ENFORCED CONSTRAINTS DISABLE ON QUERY COMPUTATION DISABLE QUERY REWRITE
  AS select
	p.id,
	p.program_id,
	p.code,
	p.name,
	p.abbreviation as short_name,
	p.state_code as project_state_code,
	pstate.name as project_state,
	p.is_active,
	p.is_lead,
	p.development_phase_code as le_overview_code,
	devphase.name as le_overview,
	p.sbe_code,
	sbe.name as sbe,
	p.pidt_bu_code as gbu_code,
	gbu.name as gbu,
	p.ta_code as therapeutic_area_code,
	pta.name as therapeutic_area,
	p.area_code as project_area_code,
	area.name as project_area,
	p.phase_code,
	phase.name as phase,
	p.priority_code,
	prio.name as priority,
	cast(category.code as nvarchar2(20)) as lc_type_code,
	category.name as lc_type,
	cast(subgroup.code as nvarchar2(20)) as subgroup_code,
	subgroup.name as subgroup_name,
	mg.code as maingroup_code,
	mg.name as maingroup_name,
	p.substance_type_code,
	substance_type.name as substance_type,
	p.source_code,
	source.name as source,
	p.tc_code as target_class_code,
	ptc.name as target_class,
	p.to_code as target_origin_code,
	pto.name as target_origin,
	p.enpv,
	p.npv,
	p.peak_sales,
	p.is_portfolio as portfolio_project,
	p.is_hpr as hpr,
	p.is_regional,
	p.is_orphan_drug,
	--p.is_direct_phase3,
	--p.is_combined_phase2,
	p.is_collaboration as collaboration,
	p.is_pip as pip_project,
	p.pip_date,
	p.pdco_date,
	p.is_pdco_positive,
	p.is_waiver,
	p.pip_activities,
	substr(termination.name,1,100) as termination_name,
	p.termination_code,
	p.termination_date,
	p.termination_reason,
	pts_preclinical.probability as pts_preclinical,
	pts_phase1.probability as pts_phase1,
	pts_phase2.probability as pts_phase2,
	pts_phase3.probability as pts_phase3,
	pts_submission.probability as pts_submission,
	round(100 * nvl(pts_preclinical.probability / 100, 0) * nvl(pts_phase1.probability / 100, 0) * nvl(pts_phase2.probability / 100, 0) * nvl(pts_phase3.probability / 100, 0) * nvl(pts_submission.probability / 100, 0)) as pts_total,
	p.review_date as review_meeting_date,
	p.details_partner,
	p.details_progress,
	p.progress_date,
	p.details_criteria,
	p.details_mesh,
	p.details_indication,
	p.details_product,
	p.details_goal,
	p.details_action,
	p.details_competition,
	p.details_patent,
	p.details_sales,
	p.details_pmo,
	p.details_comment,
	--p.details_modality,
	ipms_Data.configuration_pkg.get_names_for_codes(p.details_modality) details_modality,
	combination.combination_code,
	combination.combination_name as combination_id,
	pbay.name as preferred_bay_no,
	p.id||'-RAW' as p6_raw_plan,
	p.id||'-CUR' as p6_current_plan,
	p.id||'-APR' as p6_approved_plan,
	p.planning_enabled,
	p.ipowner_code as ip_owner_code,
	ipowner.name as ip_owner,
	p.d1_decision_date as d1_milestone_for_d1_prj,
	pgfd1.goal_factor as d1_goal_factor_for_d1_prj,
	p.start_hts_date as start_hts_milestone,
	p.lsa_date,
	pgft.goal_factor as termination_goal_factor,
	cast(decode(p.area_code,'D1',null,p.d2_compound) as nvarchar2(80)) d2_compound,
	p.succ_project_id as successor_project_id,
	p.predecessor_project_id,
	p.d3transition_project_id,
	p.lo_review_meeting_date,
	p.lo_review_result_code,
	p.trg as therapeutic_research_group,
	p.target_gene_code,
	p.er as exploratory_research,
	p.general_project_frame,
	p.phase_estimated_code,
	phase_estimated.name as phase_estimated,
	--p.d2_planned_date,
	--p.d2_achieved_date,
	p.ptr_for_d2_code,
	p.ptr_for_d3_code,
	p.previous_names,
	p.is_device_project as device_project,
	p.bpi_no,
	p.project_device_type_code,
	pdt.name as project_device_type_name,
	substr(p.regulatory_code,1,instr(p.regulatory_code||';',';')-1) as regulatory_code,
	rt.name as regulatory_name,
	p.regulatory_other,
	p.device_phase_code,
	dp.name device_phase_name,
	p.DETAILS_OBJECTIVE DET_OBJECTIVE_MSP,--promis 604
	p.DETAILS_RATIONALE DET_RATIONALE_MSP,
	p.DETAILS_SCOPE DET_SCOPE_MSP,
	p.DETAILS_INTENDED_USE DET_INTENDED_USE_MSP,
	p.DETAILS_BENEFITS DET_BENEFITS_MSP,
	p.DETAILS_EXECUTIVE_SUMMARY DET_EXECUTIVE_SUMMARY_MSP,
	p.DETAILS_RISKS DET_RISKS_MSP,
	p.DETAILS_HIGHLIGHTS DET_HIGHLIGHTS_MSP,
	p.DETAILS_ACTIVITIES_EVENTS DET_ACTIVITIES_EVENTS_MSP,
	p.DETAILS_BUDGET DET_BUDGET_MSP,
    ss.NAME DET_SAMD_STATUS_MSP,
	p.DETAILS_SAMD_STATUS DET_SAMD_STATUS_CODE_MSP,
    bs.NAME DET_BUDGET_STATUS_MSP,
	p.DETAILS_BUDGET_STATUS DET_BUDGET_STATUS_CODE_MSP   
from ipms_data.project p
left join ipms_data.budget_status bs on bs.CODE = p.DETAILS_BUDGET_STATUS
left join ipms_data.samd_status ss on ss.CODE = p.DETAILS_SAMD_STATUS
left join ipms_data.combination_vw combination on combination.project_id = p.id
left join ipms_data.bay_number pbay on pbay.code = p.bay_code
left join ipms_data.project_state pstate on pstate.code = p.state_code
left join ipms_data.display_state displaystate on displaystate.code = p.display_state_code
left join ipms_data.development_phase devphase on devphase.code = p.development_phase_code
left join ipms_data.strategic_business_entity sbe on sbe.code = p.sbe_code
left join ipms_data.global_business_unit gbu on gbu.code = p.pidt_bu_code
left join ipms_data.therapeutic_area pta on pta.code = p.ta_code
left join ipms_data.project_area area on area.code = p.area_code
left join ipms_data.phase phase on phase.code = p.phase_code
left join ipms_data.priority prio on prio.code = p.priority_code
left join ipms_data.project_category category on (category.code = p.category_code and category.is_promis=1)
left join ipms_data.project_category subgroup on (subgroup.code = p.project_group_code)
left join ipms_data.maingroup mg on (subgroup.maingroup_code = mg.code)
left join ipms_data.substance_type substance_type on substance_type.code = p.substance_type_code
left join ipms_data.project_source source on source.code = p.source_code
left join ipms_data.target_class ptc on ptc.code = p.tc_code
left join ipms_data.target_origin pto on pto.code = p.to_code
left join --ipms_data.termination_reason termination on termination.code = p.termination_code
		(--PROMIS-748
		select tr.code, decode(trg.name,null,null,trg.name||' - ')||tr.name name
		from ipms_data.termination_reason tr
		left join ipms_data.termination_reason trg on (tr.ref_reason_code=trg.code)
		) termination on (termination.code = p.termination_code)
left join ipms_data.phase_estimated phase_estimated on phase_estimated.code = p.phase_estimated_code
left join ipms_data.costs_probability pts_preclinical on pts_preclinical.project_id = p.id and pts_preclinical.phase_code = '1' and pts_preclinical.scope_code = 'INT'
left join ipms_data.costs_probability pts_phase1 on pts_phase1.project_id = p.id and pts_phase1.phase_code = '2' and pts_phase1.scope_code = 'INT'
left join ipms_data.costs_probability pts_phase2 on pts_phase2.project_id = p.id and pts_phase2.phase_code = '34' and pts_phase2.scope_code = 'INT'
left join ipms_data.costs_probability pts_phase3 on pts_phase3.project_id = p.id and pts_phase3.phase_code = '5' and pts_phase3.scope_code = 'INT'
left join ipms_data.costs_probability pts_submission on pts_submission.project_id = p.id and pts_submission.phase_code = '6' and pts_submission.scope_code = 'INT'
left join ipms_data.ipowner ipowner on ipowner.code = p.ipowner_code
left join ipms_data.project_goal_factor pgft on (p.id = pgft.project_id) and pgft.milestone_code='Termn'
left join ipms_data.project_goal_factor pgfd1 on (p.id = pgfd1.project_id) and pgfd1.milestone_code='D1' and p.area_code='D1'
left join ipms_data.project_device_type pdt on (pdt.code = p.project_device_type_code)
left join ipms_data.regulatory_type rt on (rt.code = substr(p.regulatory_code,1,instr(p.regulatory_code||';',';')-1))
left join ipms_data.device_phase dp on (dp.code = p.device_phase_code);

   COMMENT ON MATERIALIZED VIEW IPMS_REPO.PROJECT_DIM  IS 'snapshot table for snapshot IPMS_REPO.PROJECT_DIM';
  GRANT SELECT ON IPMS_REPO.PROJECT_DIM TO MYCSD;
