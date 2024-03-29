package com.bayer.ipms.model.services;

import com.bayer.ipms.model.base.IPMSApplicationModuleImpl;
import com.bayer.ipms.model.base.IPMSViewObjectImpl;
import com.bayer.ipms.model.services.common.WorkspaceAppModule;
import com.bayer.ipms.model.utils.ModelUtils;
import com.bayer.ipms.model.views.ProgramViewImpl;
import com.bayer.ipms.model.views.ProjectViewImpl;
import com.bayer.ipms.model.views.TaskViewImpl;
import com.bayer.ipms.model.views.estimates.LatestEstimateViewImpl;
import com.bayer.ipms.model.views.estimates.LatestEstimatesProcessViewImpl;
import com.bayer.ipms.model.views.estimates.LatestEstimatesTagViewImpl;
import com.bayer.ipms.model.views.estimates.common.LatestEstimatesProcessView;
import com.bayer.ipms.model.views.estimates.common.LatestEstimatesProcessViewRow;
import com.bayer.ipms.model.views.estimates.common.LatestEstimatesTagView;
import com.bayer.ipms.model.views.estimates.common.LatestEstimatesTagViewRow;

import com.bayer.ipms.model.views.ltc.LtcProcessViewImpl;

import com.bayer.ipms.model.views.ltc.LtcProjectViewImpl;
import com.bayer.ipms.model.views.ltc.LtcTagViewImpl;

import java.sql.Types;

import oracle.jbo.server.ViewLinkImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Sep 18 18:52:12 EEST 2015
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class WorkspaceAppModuleImpl extends IPMSApplicationModuleImpl implements WorkspaceAppModule {
    /**
     * This is the default constructor (do not remove).
     */
    public WorkspaceAppModuleImpl() {
    }

    /**
     * Container's getter for TaskView.
     * @return TaskView
     */
    public TaskViewImpl getTaskView() {
        return (TaskViewImpl) findViewObject("TaskView");
    }

    /**
     * Container's getter for ProjectView.
     * @return ProjectView
     */
    public ProjectViewImpl getProjectView() {
        return (ProjectViewImpl) findViewObject("ProjectView");
    }

    /**
     * Container's getter for LatestEstimatesTaskView.
     * @return LatestEstimatesTaskView
     */
    public IPMSViewObjectImpl getLatestEstimatesTaskView() {
        return (IPMSViewObjectImpl) findViewObject("LatestEstimatesTaskView");
    }

    /**
     * Container's getter for TimelineView.
     * @return TimelineView
     */
    public IPMSViewObjectImpl getTimelineView() {
        return (IPMSViewObjectImpl) findViewObject("TimelineView");
    }

    /**
     * Container's getter for ProcessView.
     * @return ProcessView
     */
    public LatestEstimatesProcessViewImpl getProcessView() {
        return (LatestEstimatesProcessViewImpl) findViewObject("ProcessView");
    }

    /**
     * Container's getter for LatestEstimateView.
     * @return LatestEstimateView
     */
    public LatestEstimateViewImpl getLatestEstimateView() {
        return (LatestEstimateViewImpl) findViewObject("LatestEstimateView");
    }

    /**
     * Container's getter for LatestEstimatesProcessView.
     * @return LatestEstimatesProcessView
     */
    public LatestEstimatesProcessViewImpl getLatestEstimatesProcessView() {
        return (LatestEstimatesProcessViewImpl) findViewObject("LatestEstimatesProcessView");
    }

    /**
     * Container's getter for ProgramView.
     * @return ProgramView
     */
    public ProgramViewImpl getProgramView() {
        return (ProgramViewImpl) findViewObject("ProgramView");
    }

    /**
     * Container's getter for PlanAssumptionRequestView.
     * @return PlanAssumptionRequestView
     */
    public IPMSViewObjectImpl getPlanAssumptionRequestView() {
        return (IPMSViewObjectImpl) findViewObject("PlanAssumptionRequestView");
    }

    /**
     * Container's getter for TaskProject.
     * @return TaskProject
     */
    public ViewLinkImpl getTaskProject() {
        return (ViewLinkImpl) findViewLink("TaskProject");
    }

    /**
     * Container's getter for TimelineProject.
     * @return TimelineProject
     */
    public ViewLinkImpl getTimelineProject() {
        return (ViewLinkImpl) findViewLink("TimelineProject");
    }

    /**
     * Container's getter for TaskProcess.
     * @return TaskProcess
     */
    public ViewLinkImpl getTaskProcess() {
        return (ViewLinkImpl) findViewLink("TaskProcess");
    }

    /**
     * Container's getter for TaskProgram.
     * @return TaskProgram
     */
    public ViewLinkImpl getTaskProgram() {
        return (ViewLinkImpl) findViewLink("TaskProgram");
    }

    /**
     * Container's getter for TaskAssumptionRequest.
     * @return TaskAssumptionRequest
     */
    public ViewLinkImpl getTaskAssumptionRequest() {
        return (ViewLinkImpl) findViewLink("TaskAssumptionRequest");
    }

    public String getName() {
        return super.getName();
    }

    /**
     * Container's getter for LatestEstimatesTagView1.
     * @return LatestEstimatesTagView1
     */
    public LatestEstimatesTagViewImpl getLatestEstimatesTagView() {
        return (LatestEstimatesTagViewImpl) findViewObject("LatestEstimatesTagView");
    }

    /**
     * Container's getter for LepLet1.
     * @return LepLet1
     */
    public ViewLinkImpl getLepLet() {
        return (ViewLinkImpl) findViewLink("LepLet");
    }

    

    public void initLeExcelForm(String tagId, String processId, String programId) {

        Boolean isProcessNextYear;
        LatestEstimatesTagViewRow letRow = ((LatestEstimatesTagView) getLatestEstimatesTagView1()).getRowById(tagId);
        ModelUtils.setAttributeBindingValue("ProcessYear", letRow.getYear());
        ModelUtils.setAttributeBindingValue("CostsForecastNumberVersion", (String)callStoredFunction(Types.VARCHAR, "estimates_pkg.get_latest_fc_numbver", null));

        if (programId != null) {
            ModelUtils.setAttributeBindingValue("LeScope", "program");
        } else if (processId != null) {
            ModelUtils.setAttributeBindingValue("LeScope", "process");
        } else if (tagId != null) {
            ModelUtils.setAttributeBindingValue("LeScope", "tag");
        }

        if (processId != null) {
            LatestEstimatesProcessViewRow lepRow =
                ((LatestEstimatesProcessView) getLatestEstimatesProcessView()).getRowById(processId);
            ModelUtils.setAttributeBindingValue("TagProcessName", lepRow.getName());
            ModelUtils.setAttributeBindingValue("ProcessComments", lepRow.getComments());
            isProcessNextYear = lepRow.getIsNextYear();
        } else {
            ModelUtils.setAttributeBindingValue("TagProcessName", letRow.getName());
            isProcessNextYear =
                ((LatestEstimatesProcessView) getLatestEstimatesProcessView()).isNextYearProcessAvailable(tagId);
        }

        ModelUtils.setAttributeBindingValue("ProcessIsNextYear", isProcessNextYear ? "1" : "0");
    }
    
    public void commitLe(){
        
        ModelUtils.setBaCode("EstimatesProvide");
        
        getDBTransaction().commit();
        
        ModelUtils.setBaCode(null);
    }

    /**
     * Container's getter for LatestEstimatesTagView1.
     * @return LatestEstimatesTagView1
     */
    public LatestEstimatesTagViewImpl getLatestEstimatesTagView1() {
        return (LatestEstimatesTagViewImpl) findViewObject("LatestEstimatesTagView1");
    }

    /**
     * Container's getter for LtcProcessView1.
     * @return LtcProcessView1
     */
    public LtcProcessViewImpl getLtcProcessView() {
        return (LtcProcessViewImpl) findViewObject("LtcProcessView");
    }

    /**
     * Container's getter for TaskLtcProcess1.
     * @return TaskLtcProcess1
     */
    public ViewLinkImpl getTaskLtcProcess() {
        return (ViewLinkImpl) findViewLink("TaskLtcProcess");
    }

    /**
     * Container's getter for LtcTagView1.
     * @return LtcTagView1
     */
    public LtcTagViewImpl getLtcTagView() {
        return (LtcTagViewImpl) findViewObject("LtcTagView");
    }

    /**
     * Container's getter for LtcpLtcT1.
     * @return LtcpLtcT1
     */
    public ViewLinkImpl getLtcpLtcT() {
        return (ViewLinkImpl) findViewLink("LtcpLtcT");
    }

    /**
     * Container's getter for LtcProjectView1.
     * @return LtcProjectView1
     */
    public LtcProjectViewImpl getLtcProjectView() {
        return (LtcProjectViewImpl) findViewObject("LtcProjectView");
    }

    /**
     * Container's getter for LtcProcessProjects1.
     * @return LtcProcessProjects1
     */
    public ViewLinkImpl getLtcProcessProjects() {
        return (ViewLinkImpl) findViewLink("LtcProcessProjects");
    }

    /**
     * Container's getter for LtcProjectView1.
     * @return LtcProjectView1
     */
    public LtcProjectViewImpl getTaskLtcProjectView() {
        return (LtcProjectViewImpl) findViewObject("TaskLtcProjectView");
    }

    /**
     * Container's getter for TaskLtcProjects1.
     * @return TaskLtcProjects1
     */
    public ViewLinkImpl getTaskLtcProjects() {
        return (ViewLinkImpl) findViewLink("TaskLtcProjects");
    }
}

