package com.bayer.ipms.model.views.client;


import com.bayer.ipms.model.views.common.CostsProbabilitySpecificViewRow;
import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.model.views.common.TimelineViewRow;

import java.util.Map;

import oracle.jbo.Row;
import oracle.jbo.RowIterator;
import oracle.jbo.RowSet;
import oracle.jbo.client.remote.RowImpl;
import oracle.jbo.domain.Date;


// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Jun 28 12:36:40 EEST 2013
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ProjectViewRowClient extends RowImpl implements ProjectViewRow {
    /**
     * This is the default constructor (do not remove).
     */
    public ProjectViewRowClient() {
    }


    public boolean isLead() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "isLead", null, null);
        return ((Boolean)_ret).booleanValue();
    }


    public void setIsGddopInformed(Integer value) {
        setAttribute("IsGddopInformed", value);
    }


    public void informGddOp() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "informGddOp", null, null);
        return;
    }


    public void sendNotification() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "sendNotification", null, null);
        return;
    }


    public void setRelations() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "setRelations", null, null);
        return;
    }


    public void setTimelineRawId(String value) {
        setAttribute("TimelineRawId", value);
    }


    public void conductTransition(String decisionDateType, java.util.Date d3Date, String d3TrProjectId,
                                  String d2ProjectId, String substanceTypeCode, String areaCode, String stateCode,
                                  String therapeuticAreaCode) {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "conductTransition",
                                                               new String[] { "java.lang.String", "java.util.Date",
                                                                              "java.lang.String", "java.lang.String",
                                                                              "java.lang.String", "java.lang.String",
                                                                              "java.lang.String", "java.lang.String" },
                                                               new Object[] { decisionDateType, d3Date, d3TrProjectId,
                                                                              d2ProjectId, substanceTypeCode, areaCode,
                                                                              stateCode, therapeuticAreaCode });
        return;
    }

    public void forecast() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "forecast", null, null);
        return;
    }

    public Map<String, CostsProbabilitySpecificViewRow> getDefaultProbabilities() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getDefaultProbabilities", null, null);
        return (Map<String, CostsProbabilitySpecificViewRow>) _ret;
    }

    public RowSet getGlobalBusinessUnitView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getGlobalBusinessUnitView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getPhasePlanningTypeView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getPhasePlanningTypeView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getPriorityView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getPriorityView", null, null);
        return (RowSet) _ret;
    }

    public Row getProgramView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getProgramView", null, null);
        return (Row) _ret;
    }

    public RowSet getProjectAreaView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getProjectAreaView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getProjectCategoryView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getProjectCategoryView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getProjectDeviceTypeView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getProjectDeviceTypeView", null, null);
        return (RowSet) _ret;
    }
    
    public RowIterator getProjectPhasePlanningView() {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "getProjectPhasePlanningView", null, null);
        return (RowIterator) _ret;
    }
    
    public RowIterator getProjectRelatedDevView() {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "getProjectRelatedDevView", null, null);
        return (RowIterator) _ret;
    }
    
    public RowIterator getProjectRelatedSuccessorView() {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "getProjectRelatedSuccessorView", null, null);
        return (RowIterator) _ret;
    }
    
    public RowIterator getProjectRelatedPredecessorView() {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "getProjectRelatedPredecessorView", null, null);
        return (RowIterator) _ret;
    }

    public RowSet getProjectPhaseView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getProjectPhaseView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getProjectSourceView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getProjectSourceView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getProjectStateView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getProjectStateView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getQplanMasterdataView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getQplanMasterdataView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getQplanMilestonesView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getQplanMilestonesView", null, null);
        return (RowSet) _ret;
    }

    public String[] getRegulatoryCodes() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getRegulatoryCodes", null, null);
        return (String[]) _ret;
    }

    public RowSet getRegulatoryTypeView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getRegulatoryTypeView", null, null);
        return (RowSet) _ret;
    }

    public String[] getRelatedProjectsIds() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getRelatedProjectsIds", null, null);
        return (String[]) _ret;
    }

    public RowIterator getSubstanceCodeView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getSubstanceCodeView", null, null);
        return (RowIterator) _ret;
    }

    public RowSet getSubstanceTypeView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getSubstanceTypeView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getSubstanceView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getSubstanceView", null, null);
        return (RowSet) _ret;
    }

    public String[] getSubstances() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getSubstances", null, null);
        return (String[]) _ret;
    }

    public RowSet getTargetClassView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getTargetClassView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getTargetOriginView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getTargetOriginView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getTerminationReason4AreaView() {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "getTerminationReason4AreaView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getTerminationReason4AreaView_VO() {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "getTerminationReason4AreaView_VO", null, null);
        return (RowSet) _ret;
    }

    public RowSet getTerminationReasonView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getTerminationReasonView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getTherapeuticAreaView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getTherapeuticAreaView", null, null);
        return (RowSet) _ret;
    }

    public RowIterator getTimelineView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getTimelineView", null, null);
        return (RowIterator) _ret;
    }

    public Map<String, TimelineViewRow> getVersions() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getVersions", null, null);
        return (Map<String, TimelineViewRow>) _ret;
    }

    public void identify() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "identify", null, null);
        return;
    }

    public boolean isActive() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "isActive", null, null);
        return ((Boolean) _ret).booleanValue();
    }

    public boolean isBusy() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "isBusy", null, null);
        return ((Boolean) _ret).booleanValue();
    }

    public void lead() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "lead", null, null);
        return;
    }

    public void move() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "move", null, null);
        return;
    }

    public void moveProject() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "moveProject", null, null);
        return;
    }

    public void notifyProjectCreated() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "notifyProjectCreated", null, null);
        return;
    }

    public void receive() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "receive", null, null);
        return;
    }

    public void refresh() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "refresh", null, null);
        return;
    }

    public void releaseToFps() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "releaseToFps", null, null);
        return;
    }

    public void releaseToPidt() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "releaseToPidt", null, null);
        return;
    }

    public void removeDistributed() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "removeDistributed", null, null);
        return;
    }

    public void send() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "send", null, null);
        return;
    }

    public void setRegulatoryCodes(String[] codes) {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "setRegulatoryCodes",
                                                               new String[] { "[Ljava.lang.String;" },
                                                               new Object[] { codes });
        return;
    }

    public void setRelatedProjectsIds(String[] codes) {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "setRelatedProjectsIds",
                                                               new String[] { "[Ljava.lang.String;" },
                                                               new Object[] { codes });
        return;
    }

    public void setRelation(String relProjectId, String oldRelProjectId) {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "setRelation",
                                                               new String[] { "java.lang.String", "java.lang.String" },
                                                               new Object[] { relProjectId, oldRelProjectId });
        return;
    }

    public void setSubstances(String[] codes) {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "setSubstances",
                                                               new String[] { "[Ljava.lang.String;" },
                                                               new Object[] { codes });
        return;
    }

    public void toggleActive() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "toggleActive", null, null);
        return;
    }

    public void unlock() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "unlock", null, null);
        return;
    }

    public void updateAssignedPhasePlanning() {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "updateAssignedPhasePlanning", null, null);
        return;
    }
    
    public void updateAssignedRelatedDevProjects() {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "updateAssignedRelatedDevProjects", null, null);
        return;
    }
    
    public void updateAssignedRelatedMspProjects() {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "updateAssignedRelatedMspProjects", null, null);
        return;
    }
    
    public void updateAssignedRelatedSucc() {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "updateAssignedRelatedSucc", null, null);
        return;
    }
    
    public void updateAssignedRelatedPred() {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "updateAssignedRelatedPred", null, null);
        return;
    }

    public void updateAssignedSubstances() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "updateAssignedSubstances", null, null);
        return;
    }

    public void updateRelatedProjects() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "updateRelatedProjects", null, null);
        return;
    }

    public String getAreaCode() {
        return (String) getAttribute("AreaCode");
    }

    public String getCategoryCode() {
        return (String) getAttribute("CategoryCode");
    }

    public String getCode() {
        return (String) getAttribute("Code");
    }

    public String getD3transitionProjectId() {
        return (String) getAttribute("D3transitionProjectId");
    }

    public String getD3transitionProjectIdOld() {
        return (String) getAttribute("D3transitionProjectIdOld");
    }

    public String getDescription() {
        return (String) getAttribute("Description");
    }

    public String getId() {
        return (String) getAttribute("Id");
    }

    public String getImportProgramCode() {
        return (String) getAttribute("ImportProgramCode");
    }

    public String getImportProgramName() {
        return (String) getAttribute("ImportProgramName");
    }

    public String getIpownerCode() {
        return (String) getAttribute("IpownerCode");
    }

    public Boolean getIsActive() {
        return (Boolean) getAttribute("IsActive");
    }

    public Boolean getIsTypifyExcluded() {
        return (Boolean) getAttribute("IsTypifyExcluded");
    }

    public String getName() {
        return (String) getAttribute("Name");
    }

    public String getNewProgramId() {
        return (String) getAttribute("NewProgramId");
    }

    public String getPredecessorProjectId() {
        return (String) getAttribute("PredecessorProjectId");
    }

    public Integer getProbability() {
        return (Integer) getAttribute("Probability");
    }

    public String getProgramId() {
        return (String) getAttribute("ProgramId");
    }

    public String getProposedSbeCode() {
        return (String) getAttribute("ProposedSbeCode");
    }

    public String getQualifiedName() {
        return (String) getAttribute("QualifiedName");
    }

    public String getSourceCode() {
        return (String) getAttribute("SourceCode");
    }

    public String getStateCode() {
        return (String) getAttribute("StateCode");
    }

    public String getSubstanceTypeCode() {
        return (String) getAttribute("SubstanceTypeCode");
    }

    public Date getSyncDate() {
        return (Date) getAttribute("SyncDate");
    }

    public String getTimelineRawId() {
        return (String) getAttribute("TimelineRawId");
    }

    public Date getUpdateDate() {
        return (Date) getAttribute("UpdateDate");
    }

	public String getTargetGeneCode() {
        return (String) getAttribute("TargetGeneCode");
    }

    public void setAreaCode(String value) {
        setAttribute("AreaCode", value);
    }

    public void setCategoryCode(String value) {
        setAttribute("CategoryCode", value);
    }

    public void setDescription(String value) {
        setAttribute("Description", value);
    }

    public void setIpownerCode(String value) {
        setAttribute("IpownerCode", value);
    }

    public void setIsActive(Boolean value) {
        setAttribute("IsActive", value);
    }

    public void setNewProgramId(String value) {
        setAttribute("NewProgramId", value);
    }

    public void setPhaseCode(String value) {
        setAttribute("PhaseCode", value);
    }

    public void setPriorityCode(String value) {
        setAttribute("PriorityCode", value);
    }

    public void setProgramId(String value) {
        setAttribute("ProgramId", value);
    }

    public void setProposedSbeCode(String value) {
        setAttribute("ProposedSbeCode", value);
    }

    public void setSourceCode(String value) {
        setAttribute("SourceCode", value);
    }

    public void setStateCode(String value) {
        setAttribute("StateCode", value);
    }

    public void setSubstanceTypeCode(String value) {
        setAttribute("SubstanceTypeCode", value);
    }

	public void setTargetGeneCode(String value) {
        setAttribute("TargetGeneCode", value);
    }
}