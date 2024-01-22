package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.ProgramTopVersionViewImpl;
import com.bayer.ipms.model.views.ProgramViewRowImpl;
import com.bayer.ipms.model.views.ProjectGoalViewImpl;
import com.bayer.ipms.model.views.ProjectGoalViewRowImpl;
import com.bayer.ipms.model.views.ProjectViewRowImpl;
import com.bayer.ipms.model.views.common.LicenseDetailsViewRow;
import com.bayer.ipms.model.views.common.CollaborationDetailsViewRow;
import com.bayer.ipms.model.views.common.CostsProbabilityInternalViewRow;
import com.bayer.ipms.model.views.common.CostsProbabilitySpecificViewRow;
import com.bayer.ipms.model.views.common.ProgramView;
import com.bayer.ipms.model.views.common.ProgramViewRow;
import com.bayer.ipms.model.views.common.ProjectRelatedDevViewRow;
import com.bayer.ipms.model.views.common.ProjectRelatedMspViewRow;
import com.bayer.ipms.model.views.common.ProjectView;
import com.bayer.ipms.model.views.common.ProjectView2Row;
import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.model.views.common.RoadmapViewRow;
import com.bayer.ipms.model.views.common.TargetProductProfileView;
import com.bayer.ipms.model.views.common.TeamMemberViewRow;
import com.bayer.ipms.model.views.common.TimelineBaselineViewRow;
import com.bayer.ipms.model.views.common.TimelineViewRow;
import com.bayer.ipms.view.base.IPMSViewBean;
import com.bayer.ipms.view.events.ContextualEventHandler;
import com.bayer.ipms.view.utils.ViewUtils;

import java.io.IOException;
import java.io.OutputStream;

import java.sql.Date;

import java.util.Calendar;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.ResourceBundle;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.share.ADFContext;
import oracle.adf.share.logging.ADFLogger;
import oracle.adf.view.rich.component.rich.RichPopup;
import oracle.adf.view.rich.component.rich.data.RichTree;
import oracle.adf.view.rich.component.rich.data.RichTreeTable;
import oracle.adf.view.rich.component.rich.fragment.RichDynamicDeclarativeComponent;
import oracle.adf.view.rich.component.rich.input.RichInputDate;
import oracle.adf.view.rich.component.rich.input.RichInputText;
import oracle.adf.view.rich.component.rich.input.RichSelectBooleanCheckbox;
import oracle.adf.view.rich.component.rich.input.RichSelectOneChoice;
import oracle.adf.view.rich.component.rich.input.RichSelectOneRadio;
import oracle.adf.view.rich.component.rich.layout.RichPanelStretchLayout;
import oracle.adf.view.rich.component.rich.layout.RichShowDetailItem;
import oracle.adf.view.rich.component.rich.output.RichOutputText;
import oracle.adf.view.rich.context.AdfFacesContext;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;

import oracle.binding.BindingContainer;

import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewCriteria;
import oracle.jbo.ViewCriteriaItem;
import oracle.jbo.ViewCriteriaManager;
import oracle.jbo.ViewCriteriaRow;
import oracle.jbo.ViewObject;
import oracle.jbo.domain.generic.GenericClob;
import oracle.jbo.uicli.binding.JUCtrlHierBinding;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.myfaces.trinidad.event.DisclosureEvent;
import org.apache.myfaces.trinidad.event.PollEvent;
import org.apache.myfaces.trinidad.event.ReturnEvent;
import org.apache.myfaces.trinidad.event.SelectionEvent;
import org.apache.myfaces.trinidad.model.CollectionModel;


public class ProjectViewBean extends IPMSViewBean {

    protected static ADFLogger logger = ADFLogger.createADFLogger(ProjectViewBean.class);

    protected String activeTab = "sdiOverview";
    private static final String TIMELINE_VIEW_IT = "TimelineViewIterator";
    private static final String PROJECT_VIEW_IT = "ProjectViewIterator";
    private static final String SEARCH_RELATED_PRJ_CODE = "itSearchRelatedPrjCode";
    private static final String SEARCH_RELATED_PRJ_NAME = "itSearchRelatedPrjName";
    private static final String BTN_OVERVIEW_OK = "btnOverviewCharactOk";
    private static final String BTN_OVERVIEW_CANCEL = "btnOverviewCharactCancel";
    private static final String PROJECT_1_VIEW_IT = "ProjectView1Iterator";

    private String baselineTimelineId;
    private RichSelectOneChoice projectTimelinesSOC;
    private Integer timelineBaselineNodeLevel = 1;
    private String searchRelatedPrjName = "";
    private String searchRelatedPrjCode = "";
    private UIComponent rootComponent;
    private RichTreeTable prjTopNonIndtabTree;
    private RichTreeTable prjtoptab;


    private UIComponent goalTable;
    private Integer programGoalId;
    private String programId;
    private String projectId;
    private RichInputText trReaTextBind;


    public void setBaselineTimelineId(String baselineTimelineId) {
        this.baselineTimelineId = baselineTimelineId;
    }

    public String getBaselineTimelineId() {
        return baselineTimelineId;
    }

    public void setTimelineBaselineNodeLevel(Integer timelineBaselineNodeLevel) {
        this.timelineBaselineNodeLevel = timelineBaselineNodeLevel;
    }

    public Integer getTimelineBaselineNodeLevel() {
        return timelineBaselineNodeLevel;
    }

    public ProjectViewBean() {
        super(PROJECT_VIEW_IT);
    }


    public void setActiveTab(String tabId) {
        this.activeTab = tabId;
        Map session = ADFContext.getCurrent().getSessionScope();
        session.put("activeTabId", tabId);
    }

    public String getActiveTab() {
        return activeTab;
    }


    public void onReturnImport(ReturnEvent event) {
        ViewUtils.getIteratorBinding("CostsViewIterator").executeQuery();
        ViewUtils.getIteratorBinding("ResourcesViewIterator").executeQuery();
    }

    protected void rollback() {
        super.rollback();
    }

    public void onDelete(DialogEvent event) {
        ProjectViewRow prj = (ProjectViewRow) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getCurrentRow();

        if ("RBIN".equals(prj.getProgramId())) {
            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).removeCurrentRow();
            UtilitiesBean.setBaCode("ProjectDelete");
            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                     .getDataControl()
                     .commitTransaction();
            UtilitiesBean.setBaCode(null);
        } else {
            prj.setNewProgramId("RBIN");
            UtilitiesBean.setBaCode("ProjectMove");
            prj.moveProject();
            UtilitiesBean.setBaCode(null);
        }

        Properties eventProps = new Properties();
        eventProps.setProperty("action", "deleteProject");
        ViewUtils.publishEvent("projectEventBinding", eventProps);
    }

    public void onActivate(DialogEvent event) {
        ProjectViewRow prj = (ProjectViewRow) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getCurrentRow();
        prj.toggleActive();

        ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                 .getDataControl()
                 .commitTransaction();

        ViewUtils.publishEvent("projectEventBinding");
    }

    public void onMove(DialogEvent event) {
        ProjectViewRow prj = (ProjectViewRow) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getCurrentRow();
        UtilitiesBean.setBaCode("ProjectMove");
        prj.move();
        UtilitiesBean.setBaCode(null);

        Properties eventProps = new Properties();
        eventProps.setProperty("action", "moveProject");
        ViewUtils.publishEvent("projectEventBinding", eventProps);
    }


    public void onPoll(PollEvent pollEvent) {

        super.refresh(false);
        ViewUtils.executeIterators(TIMELINE_VIEW_IT);
    }

    public String onRefresh() {

        super.refresh(true);

        ViewUtils.publishEvent("projectEventBinding");

        if ("sdiTpp".equals(activeTab) || "sdiTppCurrent".equals(activeTab)) {
            TppBean tpp = new TppBean();
            tpp.refreshCurrent();

        } else if ("sdiPrjTopCurrent".equals(activeTab)) {
            TopBean top = new TopBean();
            top.refreshCurrent();

        } else if ("sdiGoal".equals(activeTab)) {
            ViewUtils.getIteratorBinding("GoalPhaseIterator").executeQuery();
            ViewUtils.getIteratorBinding("ProjectGoalViewIterator").executeQuery();
            ViewUtils.reloadUiComponent("prjtblgoal");

        } else if ("sdiOverview".equals(activeTab)) {
            ViewUtils.executeIterators(TIMELINE_VIEW_IT);
            ViewUtils.reloadUiComponent("trPlans");

        } else if ("sdiStudies".equals(activeTab)) {
            ProjectViewRow projectRow = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);
            projectRow.refresh();
            ViewUtils.executeIterators("StudyViewIterator");
            ViewUtils.reloadUiComponent("studiesRaw", "studiesToolbar");
        } else if ("sdiProjectLevelActivities".equals(activeTab)) {
            ViewUtils.executeIterators("ProjectLevelActivitiesViewIterator");
            ViewUtils.reloadUiComponent("tableProjectLevelActivities");
        }
        return null;
    }

    public void onRestore(DialogEvent event) {
        ProjectViewRow prj = (ProjectViewRow) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getCurrentRow();
        DCIteratorBinding prgIt = ViewUtils.getIteratorBinding("ProgramViewIterator");
        if (prgIt.getCurrentRow()
                 .getAttribute("projectType")
                 .equals("D2Prj")) {
            String prgId = prgIt.findRowsByAttributeValue("Code", true, "RESERVED-PT-D2-PRJ")
                                .getRowAtRangeIndex(0)
                                .getAttribute("Id")
                                .toString();
            prj.setNewProgramId(prgId);
            UtilitiesBean.setBaCode("ProjectRestore");
            prj.move();
            UtilitiesBean.setBaCode(null);

            Properties eventProps = new Properties();
            eventProps.setProperty("action", "moveProject");
            ViewUtils.publishEvent("projectEventBinding", eventProps);
        }
        //SAMD
        else if (prgIt.getCurrentRow()
                      .getAttribute("projectType")
                      .equals("SAMD")) {
            String prgId = prgIt.findRowsByAttributeValue("Code", true, "RESERVED-PT-SAMD")
                                .getRowAtRangeIndex(0)
                                .getAttribute("Id")
                                .toString();
            prj.setNewProgramId(prgId);
            UtilitiesBean.setBaCode("ProjectRestore");
            prj.move();
            UtilitiesBean.setBaCode(null);

            Properties eventProps = new Properties();
            eventProps.setProperty("action", "moveProject");
            ViewUtils.publishEvent("projectEventBinding", eventProps);
        }
    }

    public void onRename(DialogEvent event) {
        UtilitiesBean.setBaCode("ProjectEdit");
        ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                 .getDataControl()
                 .commitTransaction();
        UtilitiesBean.setBaCode(null);

        UtilitiesBean.setBaCode("UnlockSendReceive");
        ((ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT)).send();
        UtilitiesBean.setBaCode(null);

        ViewUtils.publishEvent("projectEventBinding");
    }

    public void onEditPreviousNames(DialogEvent event) {
        UtilitiesBean.setBaCode("ProjectEdit");
        ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                 .getDataControl()
                 .commitTransaction();
        UtilitiesBean.setBaCode(null);

        ViewUtils.publishEvent("projectEventBinding");
    }


    public void onPublish(DialogEvent event) {
        TimelineViewRow tl = (TimelineViewRow) ViewUtils.getIteratorBinding(TIMELINE_VIEW_IT).getCurrentRow();
        UtilitiesBean.setBaCode("TimelinePublish");
        tl.publish();
        UtilitiesBean.setBaCode(null);
        ViewUtils.reloadUiComponent("plans", "trPlans", "tlbPlans");
        this.onRefresh();
    
    }

    protected void refresh(boolean forced) {
        super.refresh(forced);

        ProjectViewRow proj = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);

        ViewUtils.executeIterators(TIMELINE_VIEW_IT, "MilestoneDecisionViewIterator", "MilestoneDecisionSamdViewIterator",
                                   "MilestoneDevelopmentViewIterator", "MilestoneRegionalViewIterator",
                                   "StudyViewIterator", "GoalPhaseIterator");

        if (forced) {
            ViewUtils.executeIterators("CostsViewIterator", "ResourcesViewIterator", "FundingViewIterator",
                                       "IngredientViewIterator", "NewsViewIterator", "LicenseViewIterator",
                                       "ProjectMemberViewIterator", "CostsProbabilityInternalViewIterator",
                                       "GoalPhaseIterator");
        }

        for (TimelineViewRow tl : proj.getVersions().values()) {
            ((RowSetIterator) tl.getSensorView()).getRowSet().executeQuery();
        }

        ViewUtils.reloadUiComponent("plans", "trPlans", "tlbPlans", "sensors");

        ViewUtils.publishEvent("projectEventBinding");
    }

    public String onIdentify() {
        ProjectViewRow proj = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);
        proj.identify();

        ViewUtils.reloadUiComponent("content", "tools");

        return null;
    }

    public String onForecast() {
        ProjectViewRow proj = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);

        UtilitiesBean.setBaCode("ProjectForecast");
        proj.forecast();
        UtilitiesBean.setBaCode(null);

        ViewUtils.executeIterators("CostsViewIterator");

        return null;
    }

    public void onPlans(ActionEvent event) {
        onCommit(event);
    }

    public void onIngredients(ActionEvent event) {

        ProjectViewRow row = (ProjectViewRow) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getCurrentRow();
        row.updateAssignedSubstances();

        UtilitiesBean.setBaCode("ProjectEdit");
        ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                 .getDataControl()
                 .commitTransaction();
        UtilitiesBean.setBaCode(null);
        ViewUtils.executeIterators("IngredientViewIterator");
        ((RichPopup) ViewUtils.getUiComponent("popApi")).hide();
        this.setEditArea(null);
    }


    public void onPopApiCancel(ActionEvent event) {
        ((RichPopup) ViewUtils.getUiComponent("popApi")).cancel();
        this.setEditArea(null);
    }


    public void onProbability(DialogEvent event) {
        UtilitiesBean.setBaCode("ProjectEdit");
        onPopupSubmit(event);
        UtilitiesBean.setBaCode(null);
        ViewUtils.reloadUiComponent("ptstab");
    }

    public String onApplyDefaultProbabilities() {
        RowSetIterator rows = ViewUtils.getIteratorBinding("CostsProbabilityInternalViewIterator").getRowSetIterator();
        rows.reset();
        for (Row row = rows.first(); row != null; row = rows.next()) {
            CostsProbabilityInternalViewRow prob = (CostsProbabilityInternalViewRow) row;
            CostsProbabilitySpecificViewRow def = prob.getDefault();
            if (def != null) {
                prob.setProbability(def.getProbability());
            }
        }

        return null;
    }

    public void onSubstanceFilter(ValueChangeEvent event) {
        DCIteratorBinding it = ViewUtils.getIteratorBinding("SubstanceViewIterator");
        ViewObject vo = it.getViewObject();
        ProjectViewRow prj = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);

        String filter = event.getNewValue().toString();
        vo.setWhereClause("Code in('" + StringUtils.join(prj.getSubstances(), "','") + "')" +
                          "or upper(Name) like upper('%" + filter + "%')");
        vo.clearCache();
        vo.executeQuery();

        ViewUtils.reloadUiComponent("substances");
    }

    public void onRelatedProjectFilter(ValueChangeEvent event) {
        String cid = event.getComponent().getId();
        if (SEARCH_RELATED_PRJ_CODE.equals(cid) || SEARCH_RELATED_PRJ_NAME.equals(cid)) {
            DCIteratorBinding it = ViewUtils.getIteratorBinding("AllDevProjectViewIterator");
            ViewObject vo = it.getViewObject();
            ProjectViewRow prj = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);

            if (SEARCH_RELATED_PRJ_CODE.equals(cid)) {
                this.searchRelatedPrjCode = event.getNewValue().toString();
            } else if (SEARCH_RELATED_PRJ_NAME.equals(cid)) {
                this.searchRelatedPrjName = event.getNewValue().toString();
            }
            vo.setWhereClause("Id in('" + StringUtils.join(prj.getRelatedProjectsIds(), "','") + "') " +
                              "or (upper(Code) like upper('%" + this.searchRelatedPrjCode + "%') " +
                              "and upper(Name) like upper('%" + this.searchRelatedPrjName + "%'))");
            vo.clearCache();
            vo.executeQuery();

            ViewUtils.reloadUiComponent("smsRp");
        }

    }

    public void resetRelatedProjectFilter() {
        // reset search field values
        this.searchRelatedPrjCode = "";
        this.searchRelatedPrjName = "";
        ((RichInputText) ViewUtils.getUiComponent(SEARCH_RELATED_PRJ_CODE)).setValue(this.searchRelatedPrjCode);
        ((RichInputText) ViewUtils.getUiComponent(SEARCH_RELATED_PRJ_NAME)).setValue(this.searchRelatedPrjName);
        // resert where clause for iterator
        DCIteratorBinding it = ViewUtils.getIteratorBinding("AllDevProjectViewIterator");
        ViewObject vo = it.getViewObject();
        vo.setWhereClause("");
        vo.clearCache();
        vo.executeQuery();
        //PROMIS- 604
        DCIteratorBinding itSamd = ViewUtils.getIteratorBinding("SAMDProjectsViewIterator");
        ViewObject voSamd = itSamd.getViewObject();
        voSamd.setWhereClause("");
        voSamd.clearCache();
        voSamd.executeQuery();

    }

    public void onTransition(DialogEvent event) {
        String d2ProjectId = null;
        String SAMDProjectId = null;
        String d3TransitionId = null;
        String d3DateType = null;
        Date d3Date = null;
        String substanceType = null;
        String areaCode = null;
        String projectStatus = null;
        String therapeuticArea = null;

        ProjectViewRow prj = (ProjectViewRow) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getCurrentRow();

        // Getting D2 Project ID
        String d2ProjectIndex = (String) ((RichSelectOneChoice) ViewUtils.getUiComponent("d2soc")).getValue();
        if (d2ProjectIndex != null) {
            ProjectViewRow d2Project =
                (ProjectViewRow) ViewUtils.getIteratorBinding("D2ProjectsViewIterator")
                .getRowAtRangeIndex(Integer.parseInt(d2ProjectIndex));
            if (d2Project != null)
                d2ProjectId = d2Project.getId();
        }

        // Getting SAMD Project ID
        String SAMDProjectIndex = (String) ((RichSelectOneChoice) ViewUtils.getUiComponent("d2soc")).getValue();
        if (SAMDProjectIndex != null) {
            ProjectViewRow SAMDProject =
                (ProjectViewRow) ViewUtils.getIteratorBinding("SAMDProjectsViewIterator")
                .getRowAtRangeIndex(Integer.parseInt(SAMDProjectIndex));
            if (SAMDProject != null)
                SAMDProjectId = SAMDProject.getId();
        }

        // Getting D3 Transition Project ID
        String d3TransitionIndex = (String) ((RichSelectOneChoice) ViewUtils.getUiComponent("d3soc")).getValue();
        if (d3TransitionIndex != null) {
            ProjectViewRow d3Transition =
                (ProjectViewRow) ViewUtils.getIteratorBinding("D3TransitionViewIterator")
                .getRowAtRangeIndex(Integer.parseInt(d3TransitionIndex));
            if (d3Transition != null)
                d3TransitionId = d3Transition.getId();
        }

        // Check if D2 Project Data has been set
        boolean isUpdDevDataChecked =
            (Boolean) ((RichSelectBooleanCheckbox) ViewUtils.getUiComponent("updDevDataSBC")).getValue();

        if (isUpdDevDataChecked) {
            // Get Substance Type code
            substanceType = (String) ((RichSelectOneChoice) ViewUtils.getUiComponent("substanceTypeSOC")).getValue();

            // Get Area Code
            areaCode = (String) ((RichSelectOneChoice) ViewUtils.getUiComponent("areaCodeSOC")).getValue();

            // Project State Code
            projectStatus = (String) ((RichSelectOneChoice) ViewUtils.getUiComponent("projStateSOC")).getValue();

            // Get TA Code
            therapeuticArea = (String) ((RichSelectOneChoice) ViewUtils.getUiComponent("taSOC")).getValue();

            // Get D3 date
            d3Date = (Date) ((RichInputDate) ViewUtils.getUiComponent("newD3DateID")).getValue();

            // Get D3 date type (i.e. plan or actual)
            d3DateType = (String) ((RichSelectOneRadio) ViewUtils.getUiComponent("d3DateTypeSOR")).getValue();
        }

        // Execute development project transition
        prj.conductTransition(d3DateType, d3Date, d3TransitionId, d2ProjectId, substanceType, areaCode, projectStatus,
                              therapeuticArea);
    }

    public void onD2ProjectDataSelection(ValueChangeEvent valueChangeEvent) {
        // 1. Getting selected D2 Project data
        String d2ProjectIndex = null;

        // Deleting the pre-selected values
        ((RichSelectOneChoice) ViewUtils.getUiComponent("substanceTypeSOC")).setValue(null);
        ((RichSelectOneChoice) ViewUtils.getUiComponent("projStateSOC")).setValue(null);
        ((RichSelectOneChoice) ViewUtils.getUiComponent("taSOC")).setValue(null);
        ((RichInputDate) ViewUtils.getUiComponent("d3DateID")).setValue(null);
        ((RichInputDate) ViewUtils.getUiComponent("newD3DateID")).setValue(null);

        ((RichOutputText) ViewUtils.getUiComponent("d3DateTypeActualOT")).setVisible(false);
        ((RichOutputText) ViewUtils.getUiComponent("d3DateTypePlannedOT")).setVisible(false);
        ((RichOutputText) ViewUtils.getUiComponent("d3DateTypeGenericOT")).setVisible(false);

        if (valueChangeEvent.getNewValue() != null) {
            // 1.0. Get selected D2 Project drop-down index
            d2ProjectIndex = valueChangeEvent.getNewValue().toString();

            // 1.1. Get D2 Project by selected index
            ProjectViewRow d2Project =
                (ProjectViewRow) ViewUtils.getIteratorBinding("D2ProjectsViewIterator")
                .getRowAtRangeIndex(Integer.parseInt(d2ProjectIndex));

            // 1.2. Get all D2 Project timelines
            Row[] timelines = d2Project.getTimelineView().getAllRowsInRange();

            // 1.3. Iterate the timelines in order to find the Current timeline version
            TimelineViewRow currentPlan = null;
            for (Row timeline : timelines)
                if ("CUR".equals(timeline.getAttribute("TypeCode"))) {
                    currentPlan = (TimelineViewRow) timeline;
                    break;
                }

            // 1.4. Update the D3 Date and New D3 Date values with the value of the D3 Milestone from the selected D2 project
            if (currentPlan != null) {
                // 1.4.1. Get all milestones of the selected D2 project
                Row[] milestones = d2Project.getQplanMilestonesView().getAllRowsInRange();

                // 1.4.2.a. Iterate the milestones and
                for (Row milestone : milestones) {
                    // 1.4.2.b. find the D3 milestone
                    if ("D3".equals(milestone.getAttribute("MilestoneCode"))) {
                        // 1.4.3. Check whether the D3 milestone has actual date set
                        if (milestone.getAttribute("ActualDate") != null) {
                            ((RichInputDate) ViewUtils.getUiComponent("d3DateID"))
                                .setValue(milestone.getAttribute("ActualDate"));
                            ((RichInputDate) ViewUtils.getUiComponent("newD3DateID"))
                                .setValue(milestone.getAttribute("ActualDate"));
                            ((RichOutputText) ViewUtils.getUiComponent("d3DateTypeActualOT")).setVisible(true);
                        }

                        // 1.4.4. Else check whether the D3 milestone has planned date set
                        else if (milestone.getAttribute("PlanDate") != null) {
                            ((RichInputDate) ViewUtils.getUiComponent("d3DateID"))
                                .setValue(milestone.getAttribute("PlanDate"));
                            ((RichInputDate) ViewUtils.getUiComponent("newD3DateID"))
                                .setValue(milestone.getAttribute("PlanDate"));
                            ((RichOutputText) ViewUtils.getUiComponent("d3DateTypePlannedOT")).setVisible(true);
                        }

                        // 1.4.5. Else check whether the D3 milestone has generic date set
                        else if (milestone.getAttribute("GenericDate") != null) {
                            ((RichInputDate) ViewUtils.getUiComponent("d3DateID"))
                                .setValue(milestone.getAttribute("GenericDate"));
                            ((RichInputDate) ViewUtils.getUiComponent("newD3DateID"))
                                .setValue(milestone.getAttribute("GenericDate"));
                            ((RichOutputText) ViewUtils.getUiComponent("d3DateTypeGenericOT")).setVisible(true);
                        }

                        break; // stop the iteration
                    }
                }
            }

            // 1.5. Set D2 Project masterdata
            ((RichSelectOneChoice) ViewUtils.getUiComponent("substanceTypeSOC"))
                .setValue(d2Project.getAttribute("SubstanceTypeCode"));
            ((RichSelectOneChoice) ViewUtils.getUiComponent("projStateSOC"))
                .setValue(d2Project.getAttribute("StateCode"));
            ((RichSelectOneChoice) ViewUtils.getUiComponent("taSOC")).setValue(d2Project.getAttribute("TaCode"));

            // 1.6 Display the new PIDT release date
            ((RichShowDetailItem) ViewUtils.getUiComponent("prjCntrlTab")).setDisclosed(true);
        }
    }


    public void onPidtRelease(DialogEvent dialogEvent) {
        ProjectViewRow prj = (ProjectViewRow) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getCurrentRow();

        UtilitiesBean.setBaCode("ProjectRelease");
        prj.releaseToPidt();
        UtilitiesBean.setBaCode(null);
    }

    public void onFpsSend(DialogEvent dialogEvent) {
        ProjectViewRow prj = (ProjectViewRow) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getCurrentRow();

        UtilitiesBean.setBaCode("ProjectPublishFPS");
        prj.releaseToFps();
        UtilitiesBean.setBaCode(null);
    }


    @Override
    public void onCommit(ActionEvent actionEvent) {

        ProjectViewRow prjRow = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);

        if (BTN_OVERVIEW_OK.equals(actionEvent.getComponent().getId())) {
            // Update related projects and phase planning according to multi select controls
            prjRow.updateRelatedProjects();
            prjRow.updateAssignedPhasePlanning();
            prjRow.updateAssignedRelatedDevProjects();
            prjRow.updateAssignedRelatedSucc();
            prjRow.updateAssignedRelatedPred();
            resetRelatedProjectFilter();

        }

        // super.onCommit is replaced by it's code to have possibility to clear TppProfileCategoryViewIterator cache after commit and before UI reload
        getDataControl().commitTransaction();
        this.editable = null;
        UtilitiesBean.setBaCode(null);

        if ("contrComm".equals(actionEvent.getComponent().getId())) {
            prjRow.setRelation(prjRow.getD3transitionProjectId(), prjRow.getD3transitionProjectIdOld());
        }

        if ("tppok".equals(actionEvent.getComponent().getId())) {
            UtilitiesBean.setBaCode("TPPEdit");
        } else if ("prPlnOk".equals(actionEvent.getComponent().getId())) {
            UtilitiesBean.setBaCode("TimelinePublish");
        } else if (BTN_OVERVIEW_OK.equals(actionEvent.getComponent().getId())) {
            ViewUtils.executeIterators("ProjectView2Iterator");
            ViewUtils.executeIterators("ProjectDeviceViewIterator");
        } else
            UtilitiesBean.setBaCode("ProjectEdit");

        if (actionEvent.getComponent()
                       .getId()
                       .equals("tppok")) {
            DCIteratorBinding itTppCat = ViewUtils.getIteratorBinding("TppProfileCategoryViewIterator");
            itTppCat.executeQuery();
        }

        ViewUtils.reloadUiComponent("content", "tools");
    }

    @Override
    public void onRollback(ActionEvent actionEvent) {
        if (BTN_OVERVIEW_CANCEL.equals(actionEvent.getComponent().getId())) {
            resetRelatedProjectFilter();
        }
        super.onRollback(actionEvent);
    }

    public void handleFpsReleasePopup(ActionEvent actionEvent) {
        ProjectViewRow prj = (ProjectViewRow) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getCurrentRow();
        UIComponent source = (UIComponent) actionEvent.getSource();

        // If Release button has been clicked, then release the project to FPS
        if ("release".equals(source.getId()))
            prj.releaseToFps();

        // else (Cancel button has been clicked) hide the popup
        else {
            RichPopup popup = (RichPopup) ViewUtils.getUiComponent("popFpsRelease");
            popup.hide();
        }
    }

    public boolean isFpsReleaseBlocked() {
        ProjectViewRow prj = (ProjectViewRow) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getCurrentRow();

        // 1. Iterate through all the rows of the QplanMasterdataView
        RowSetIterator projectMasterdataIterator = prj.getQplanMasterdataView().createRowSetIterator(null);
        projectMasterdataIterator.reset();

        while (projectMasterdataIterator.hasNext()) {
            Row row = projectMasterdataIterator.next();
            // 1.1. look for the blocking elements
            if (row.getAttribute("ElementIsBlocking") != null && "1".equals(row.getAttribute("ElementIsBlocking"))) {
                // 1.2. Return true, if at least one such element is found
                projectMasterdataIterator.closeRowSetIterator();
                return true;
            }
        }
        projectMasterdataIterator.closeRowSetIterator();

        return false;
    }

    public void onUntipify(DialogEvent event) {

        DCIteratorBinding reservedPrgIt = ViewUtils.getIteratorBinding("ReservedProgramsViewIterator");
        ProgramViewRow reservedPrgRow =
            (ProgramViewRow) reservedPrgIt.findRowsByAttributeValue("Code", true, "RESERVED-PT-UNT")
            .getRowAtRangeIndex(0);
        ProjectViewRow prjRow = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);
        prjRow.setProgramId(reservedPrgRow.getId());
        prjRow.setAreaCode(null);

        UtilitiesBean.setBaCode("ProjectTypify");
        super.onCommit(null);
        UtilitiesBean.setBaCode(null);
        prjRow.removeDistributed();
    }

    private void refreshTimelineRow(TimelineViewRow row) {


        String maxLtcProcessId = row.getMaxLtcProcessId();
        row.refresh();
        row.setMaxLtcProcessId(maxLtcProcessId);

    }

    public boolean getIsBusyAnyTimeline() {

        RowSetIterator timelineIt = ViewUtils.getIteratorBinding(TIMELINE_VIEW_IT).getRowSetIterator();
        TimelineViewRow currentRow = (TimelineViewRow) timelineIt.getCurrentRow();

        TimelineViewRow timelineRow = (TimelineViewRow) timelineIt.first();

        //--Do not check project timelines if no project timeline is available created yet
        if (timelineRow == null) {
            return false;
        }

        if (timelineRow.getIsSyncing()) {
            return true;
        }

        while (timelineIt.hasNext()) {
            timelineRow = (TimelineViewRow) timelineIt.next();
            if (timelineRow.getIsSyncing()) {
                return true;
            }
        }

        timelineIt.setCurrentRow(currentRow);

        return false;
        
    }

    public void onTimelinePoll(PollEvent pollEvent) {

        RowSetIterator timelineIt = ViewUtils.getIteratorBinding(TIMELINE_VIEW_IT).getRowSetIterator();
        TimelineViewRow currentRow = (TimelineViewRow) timelineIt.getCurrentRow();

        TimelineViewRow timelineRow = (TimelineViewRow) timelineIt.first();

        refreshTimelineRow(timelineRow);

        while (timelineIt.hasNext()) {
            timelineRow = (TimelineViewRow) timelineIt.next();
            refreshTimelineRow(timelineRow);
        }

        timelineIt.setCurrentRow(currentRow);

        ViewUtils.getIteratorBinding("TimelineSensorViewIterator").executeQuery();

        ViewUtils.reloadUiComponent("sensors");
        
        if (!currentRow.getIsSyncing()) {

            ViewUtils.executeIterators("MilestoneDecisionViewIterator", "MilestoneDecisionSamdViewIterator", "MilestoneDevelopmentViewIterator",
                                       "MilestoneRegionalViewIterator", "StudyViewIterator" , TIMELINE_VIEW_IT);
            
            ViewUtils.reloadUiComponent("tools", "syncmsg", "plans", "trPlans", "tlbPlans");

        }

    }


    public void tabDisclosure(DisclosureEvent event) {

        RichShowDetailItem detItem = ((RichShowDetailItem) event.getComponent());

        if (detItem.isDisclosed()) {

            setActiveTab(detItem.getId());

            if ("sdiTpp".equals(activeTab) || "sdiTppCurrent".equals(activeTab)) {

                DCIteratorBinding tppCIt = ViewUtils.getIteratorBinding("TargetProductProfileCurrentViewIterator");
                TargetProductProfileView tppVo = (TargetProductProfileView) tppCIt.getViewObject();
                tppVo.setProjectIdVar((String) ViewUtils.runValueEl("#{bindings.Id.inputValue}"));
                tppVo.getViewCriteriaManager().setApplyViewCriteriaName("ParticularProject", true);
                tppCIt.executeQuery();

                ViewUtils.discloseAllTreeTableNodes("tpptab");
            } else if ("sdiTppVersions".equals(activeTab)) {

                DCIteratorBinding tppVIt = ViewUtils.getIteratorBinding("TargetProductProfileVersionsViewIterator");
                TargetProductProfileView tppVo = (TargetProductProfileView) tppVIt.getViewObject();
                tppVo.setProjectIdVar((String) ViewUtils.runValueEl("#{bindings.Id.inputValue}"));
                tppVo.getViewCriteriaManager().setApplyViewCriteriaName("ParticularProject", true);
                tppVIt.executeQuery();

                ViewUtils.discloseAllTreeTableNodes("tblTppVersionValues");
            } else if ("sdiPrjTopCurrent".equals(activeTab)) {
                //ViewUtils.discloseAllTreeTableNodes("prjtoptab");
                //ViewUtils.discloseAllTreeTableNodes("prjTopNonIndtab");








            } else if ("sdiProjectLevelActivities".equals(activeTab)) {

                ProjectViewRow projectRow = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);
                TimelineViewRow tmlRow = projectRow.getVersions().get("RAW");

                RichPanelStretchLayout pslPA = ((RichPanelStretchLayout) ViewUtils.getUiComponent("pslPA"));
                RichOutputText otConflict = ((RichOutputText) ViewUtils.getUiComponent("otConflict"));

                if (tmlRow.getIsPaConflict()) {
                    pslPA.setVisible(false);
                    otConflict.setVisible(true);
                } else {
                    pslPA.setVisible(true);
                    otConflict.setVisible(false);
                }
            }
        }
    }

    public void onUnlock(ActionEvent actionEvent) {
        ProjectViewRow prj = (ProjectViewRow) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getCurrentRow();
        UtilitiesBean.setBaCode("UnlockSendReceive");
        prj.unlock();
        UtilitiesBean.setBaCode(null);
    }

    public void onSend(ActionEvent actionEvent) {
        ProjectViewRow prj = (ProjectViewRow) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getCurrentRow();
        UtilitiesBean.setBaCode("UnlockSendReceive");
        prj.send();
        UtilitiesBean.setBaCode(null);
    }

    public void onReceive(ActionEvent actionEvent) {
        ProjectViewRow prj = (ProjectViewRow) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getCurrentRow();
        UtilitiesBean.setBaCode("UnlockSendReceive");
        prj.receive();
        UtilitiesBean.setBaCode(null);
    }

    public void onTimelineUnlock(ActionEvent actionEvent) {
        TimelineViewRow tl = (TimelineViewRow) ViewUtils.getIteratorBinding(TIMELINE_VIEW_IT).getCurrentRow();
        UtilitiesBean.setBaCode("UnlockSendReceive");
        tl.unlock();
        UtilitiesBean.setBaCode(null);

        this.onRefresh();
    }

    public void onTimelineReceive(ActionEvent actionEvent) {
        TimelineViewRow tl = (TimelineViewRow) ViewUtils.getIteratorBinding(TIMELINE_VIEW_IT).getCurrentRow();
        UtilitiesBean.setBaCode("UnlockSendReceive");
        tl.receive();
        UtilitiesBean.setBaCode(null);

        this.onRefresh();
    }

    public void onMaintainBaselines(DialogEvent event) {
        RichInputText selectedStudy = (RichInputText) ViewUtils.getUiComponent("clnBslTimelineId_in01");
        this.baselineTimelineId = selectedStudy.getValue().toString();

        if (this.baselineTimelineId != null && !this.baselineTimelineId.equals("")) {
            UtilitiesBean.setBaCode("MaintainBaselines");
            // Execute the ProjectView.maintainBaselines() methodAction with baselineTimelineId pageFlowScope parameter
            ViewUtils.getOperationBinding("maintainBaselines").execute();
            UtilitiesBean.setBaCode(null);

            TimelineViewRow tl = (TimelineViewRow) ViewUtils.getIteratorBinding(TIMELINE_VIEW_IT).getCurrentRow();
            tl.refresh();
            ViewUtils.reloadUiComponent("tlbPlans");
        }
    }

    public void onSetBaselineTimelineId(ValueChangeEvent valueChangeEvent) {
        this.baselineTimelineId = (String) valueChangeEvent.getNewValue();
    }

    public void setProjectTimelinesSOC(RichSelectOneChoice projectTimelinesSOC) {
        this.projectTimelinesSOC = projectTimelinesSOC;
    }

    public RichSelectOneChoice getProjectTimelinesSOC() {
        return projectTimelinesSOC;
    }

    public void onReport(FacesContext facesContext, OutputStream outputStream) {

        TimelineViewRow tmlnRow = (TimelineViewRow) ViewUtils.getCurrentRow(TIMELINE_VIEW_IT);
        GenericClob cl = (GenericClob) tmlnRow.getExcelReport();

        try {
            IOUtils.copy(cl.getCharacterStream(), outputStream);
            cl.closeCharacterStream();
            outputStream.flush();
        } catch (IOException e) {
            logger.severe("Could not generate Excel output stream: " + e.getStackTrace());
        }
    }

    public void onBaselineReport(FacesContext facesContext, OutputStream outputStream) {

        TimelineViewRow tmlnRow = (TimelineViewRow) ViewUtils.getIteratorBinding(TIMELINE_VIEW_IT)
                                                             .getViewObject()
                                                             .getCurrentRow();
        TimelineBaselineViewRow tmbsRow = (TimelineBaselineViewRow) tmlnRow.getTimelineBaselineView().getCurrentRow();

        GenericClob cl = (GenericClob) tmbsRow.getExcelReport();

        try {
            IOUtils.copy(cl.getCharacterStream(), outputStream);
            cl.closeCharacterStream();
            outputStream.flush();
        } catch (IOException e) {
            logger.severe("Could not generate Excel output stream: " + e.getStackTrace());
        }
    }

    public void onTimelineBaselineTreeSelect(SelectionEvent selectionEvent) {
        if (!selectionEvent.getAddedSet()
                           .iterator()
                           .hasNext()) {
            return;
        }

        RichTreeTable tree = (RichTreeTable) selectionEvent.getSource();
        JUCtrlHierBinding treeBinding = (JUCtrlHierBinding) ((CollectionModel) tree.getValue()).getWrappedData();

        ViewUtils.runMethodEl("#{bindings." + treeBinding.getName() + ".treeModel.makeCurrent}",
                              new Class[] { SelectionEvent.class }, new Object[] { selectionEvent });

        List<?> keys = (List<?>) selectionEvent.getAddedSet()
                                               .iterator()
                                               .next();

        timelineBaselineNodeLevel = keys.size();
    }

    public void onReturnLtcProvide(ReturnEvent returnEvent) {
        logger.finest("***** LTC Provide return logic");
        onRefresh();
    }

    public boolean isImportOutdated() {

        ProjectView2Row prjRow = (ProjectView2Row) ViewUtils.getIteratorBinding("ProjectView2Iterator").getCurrentRow();

        ResourceBundle bundle =
            (ResourceBundle) ResourceBundle.getBundle("com.bayer.ipms.view.bundles.ConfigurationBundle");


        int days =
            Integer.parseInt(ResourceBundle.getBundle("com.bayer.ipms.view.bundles.ConfigurationBundle")
                             .getString("PRJ-IMP-OUTDATE-DAYS"));

        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, 0 - days);

        if (prjRow.getLastImportDate() != null && prjRow.getLastImportDate().before(cal.getTime())) {
            return true;
        }
        return false;
    }

    public void onPopApiFetch(PopupFetchEvent event) {
        this.setEditArea("popApiEditArea");
    }


    public void expandTopProjectTree(org.apache.myfaces.trinidad.event.PollEvent e) {
        ViewUtils.discloseAllTreeTableNodes("prjTopNonIndtab");
        ViewUtils.discloseAllTreeTableNodes("prjtoptab");
        AdfFacesContext.getCurrentInstance().addPartialTarget(prjtoptab);
        AdfFacesContext.getCurrentInstance().addPartialTarget(prjTopNonIndtabTree);
    }

    public void programMenuChangedEventConsumer(String param) {
        System.err.println("programMenuChangedEventConsumer project EVENT RECEIVED................" + param);
        expandTopProjectTree(null);
    }

    public void initProjectTopCurrentScreen() {
        ProgramTopVersionViewImpl vo =
            (ProgramTopVersionViewImpl) ViewUtils.getIteratorBinding("ProgramTopCurrentViewIterator").getViewObject();
        ProgramTopVersionViewImpl vo2 =
            (ProgramTopVersionViewImpl) ViewUtils.getIteratorBinding("ProgramTopNonIndVersionCategoryViewIterator")
            .getViewObject();

        String projectId = null;
        String projectType = (String) AdfFacesContext.getCurrentInstance()
                                                     .getPageFlowScope()
                                                     .get("projectType");
        if ("D2Prj".equals(projectType)) {
            projectId = (String) AdfFacesContext.getCurrentInstance()
                                                .getPageFlowScope()
                                                .get("projectId");
        }
        vo.setProjectIdBindVar(projectId);
        vo.executeQuery();
        vo2.setProjectIdBindVar(projectId);
        vo2.executeQuery();

        System.err.println("initProjectTopCurrentScreen end , projectId " + projectId + ", projectType:" + projectType);


    }

    public void setRootComponent(UIComponent rootComponent) {
        this.rootComponent = rootComponent;
    }

    public UIComponent getRootComponent() {
        return rootComponent;
    }

    public void setPrjTopNonIndtabTree(RichTreeTable prjTopNonIndtabTree) {
        this.prjTopNonIndtabTree = prjTopNonIndtabTree;
    }

    public RichTreeTable getPrjTopNonIndtabTree() {
        return prjTopNonIndtabTree;
    }

    public void setPrjtoptab(RichTreeTable prjtoptab) {
        this.prjtoptab = prjtoptab;
    }

    public RichTreeTable getPrjtoptab() {
        return prjtoptab;
    }

    public void onMaintainGoalsReturn(ReturnEvent returnEvent) {
        ProjectGoalViewImpl vo =
            (ProjectGoalViewImpl) ViewUtils.getIteratorBinding("ProjectGoalViewIterator").getViewObject();
        ViewObject vos00 = vo.getApplicationModule().findViewObject("ProjectGoalTargetYearView");
        if (vos00 != null)
            vos00.executeQuery();

        AdfFacesContext.getCurrentInstance().addPartialTarget(goalTable);
    }

    public String gotoEditGoals() {
        ProjectGoalViewRowImpl projectGoalRow =
            (ProjectGoalViewRowImpl) ViewUtils.getIteratorBinding("ProjectGoalViewIterator").getCurrentRow();
        ProgramViewRowImpl programRow =
            (ProgramViewRowImpl) ViewUtils.getIteratorBinding("ProgramViewIterator").getCurrentRow();
        System.err.println("edit goal: " + projectGoalRow.getGoal() + ", id:" + projectGoalRow.getId());
        setProgramGoalId(projectGoalRow.getId().intValueExact());
        setProgramId(programRow.getId());
        return "maintain-goals";
    }

    public String gotoAddGoals() {
        ProgramViewRowImpl programRow =
            (ProgramViewRowImpl) ViewUtils.getIteratorBinding("ProgramViewIterator").getCurrentRow();
        ProjectViewRowImpl projectRow =
            (ProjectViewRowImpl) ViewUtils.getIteratorBinding("ProjectViewIterator").getCurrentRow();
        setProgramGoalId(null);
        setProgramId(programRow.getId());
        setProjectId(projectRow.getId());
        return "maintain-goals";
    }


    public void setProgramGoalId(Integer programGoalId) {
        this.programGoalId = programGoalId;
    }

    public Integer getProgramGoalId() {
        return programGoalId;
    }

    public void setProgramId(String programId) {
        this.programId = programId;
    }

    public String getProgramId() {
        return programId;
    }

    public void setProjectId(String projectId) {
        this.projectId = projectId;
    }

    public String getProjectId() {
        return projectId;
    }


    public void setGoalTable(UIComponent goalTable) {
        this.goalTable = goalTable;
    }

    public UIComponent getGoalTable() {
        return goalTable;
    }


    public void onGoalDelete(DialogEvent event) {

        // Take target iterator
        ProjectGoalViewImpl projectGoalVO =
            (ProjectGoalViewImpl) ViewUtils.getIteratorBinding("ProjectGoalViewIterator").getViewObject();
        projectGoalVO.deleteGoal();
        projectGoalVO.getDBTransaction().commit();
        projectGoalVO.executeQuery();

        AdfFacesContext.getCurrentInstance().addPartialTarget(goalTable);
    }


    public void onGoalSelect(SelectionEvent selectionEvent) {
        Iterator it = selectionEvent.getAddedSet().iterator();
        Key newKey = null;
        while (it.hasNext()) {
            List keyList = (List) it.next();
            System.err.println("selectionEvent " + keyList + ", " + keyList.get(0).getClass());
            if (keyList != null && keyList.size() > 0)
                newKey = (Key) keyList.get(0);
        }

        ProjectGoalViewImpl projectGoalVO =
            (ProjectGoalViewImpl) ViewUtils.getIteratorBinding("ProjectGoalViewIterator").getViewObject();

        //ViewUtils.runMethodEl("#{bindings.ProjectGoalView.collectionModel.makeCurrent}",
        //                      new Class[] { SelectionEvent.class }, new Object[] { selectionEvent });
        if (newKey != null) {
            Row row = projectGoalVO.getRow(newKey);
            projectGoalVO.setCurrentRow(row);
        }

    }

    /*
 * Method to manipulate data on RoadmapTable -- PROMIS-604
 */

    public void roadMapPopupList(PopupFetchEvent popupFetchEvent) {

        if (popupFetchEvent.getLaunchSourceClientId().contains("b1_addRoadmap")) {
            this.setEditArea("popRoadMapEditArea");
            BindingContainer bc = BindingContext.getCurrent().getCurrentBindingsEntry();
            bc.getOperationBinding("RoadMapCreateInsert").execute();
        }

    }

    public void onPopupCancel(PopupCanceledEvent event) {
        this.setEditArea(null);
        super.onPopupCancel(event);
    }

    public void onRoadmapEdit(DialogEvent event) {

        this.setEditArea("popRoadMapEditArea");
        if (event.getOutcome()
                 .name()
                 .equals("ok")) {
            UtilitiesBean.setBaCode("ProjectEdit");
            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                     .getDataControl()
                     .commitTransaction();
            UtilitiesBean.setBaCode(null);
            ViewUtils.executeIterators("RoadmapViewIterator");
            this.setEditArea(null);
        }
        if (event.getOutcome()
                 .name()
                 .equals("cancel")) {
            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                     .getDataControl()
                     .rollbackTransaction();
            this.setEditArea(null);
        }
    }

    public void deleteRoadMap(ActionEvent event) {
        RoadmapViewRow rdRow = (RoadmapViewRow) ViewUtils.getIteratorBinding("RoadmapViewIterator")
                                                         .getViewObject()
                                                         .getCurrentRow();
        if (rdRow != null) {
            ViewUtils.getOperationBinding("RoadmapDelete").execute();
            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                     .getDataControl()
                     .commitTransaction();
            ViewUtils.reloadUiComponent("tblRoadmap");
        }
    }


    /*
     * Method to manipulate data on Collaboration Details - PROMIS-602
     */
    public void collaborationPopupList(PopupFetchEvent popupFetchEvent) {

        if (popupFetchEvent.getLaunchSourceClientId().contains("b1_addCollaboration")) {
            this.setEditArea("parametersEditArea");
            BindingContainer bc = BindingContext.getCurrent().getCurrentBindingsEntry();
            bc.getOperationBinding("CollaborationCreateInsert").execute();
        }
    }

    public void terminationCodeVCL(ValueChangeEvent vce) {
        // getTrReaTextBind().setValue(null);
        //getTrReaTextBind().resetValue();

        vce.getComponent().processUpdates(FacesContext.getCurrentInstance());
        FacesContext.getCurrentInstance().renderResponse();
    }


    public void onCollaborationEdit(DialogEvent event) {

        this.setEditArea("parametersEditArea");
        if (event.getOutcome()
                 .name()
                 .equals("ok")) {
            //  UtilitiesBean.setBaCode("ProjectEdit");
            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                     .getDataControl()
                     .commitTransaction();
            // UtilitiesBean.setBaCode(null);
            ViewUtils.executeIterators("CollaborationDetailsViewIterator");
            this.setEditArea("parametersEditArea");
        }
        if (event.getOutcome()
                 .name()
                 .equals("cancel")) {
            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                     .getDataControl()
                     .rollbackTransaction();
            this.setEditArea("parametersEditArea");
        }
    }

    public void deleteCollaboration(ActionEvent event) {
        CollaborationDetailsViewRow collRow = (CollaborationDetailsViewRow) ViewUtils.getIteratorBinding("CollaborationDetailsViewIterator")
                                                                                     .getViewObject()
                                                                                     .getCurrentRow();
        if (collRow != null) {
            ViewUtils.getOperationBinding("CollaborationDetailsDelete").execute();
            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                     .getDataControl()
                     .commitTransaction();
            ViewUtils.reloadUiComponent("tblCollaboration");
        }
    }

    public void onPopupCancelDetails(PopupCanceledEvent event) {
        ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                 .getDataControl()
                 .rollbackTransaction();
        this.setEditArea("parametersEditArea");
    }

    public void setTrReaTextBind(RichInputText trReaTextBind) {
        this.trReaTextBind = trReaTextBind;
    }

    public RichInputText getTrReaTextBind() {
        return trReaTextBind;
    }

    /*
     * Method to manipulate data on License Details - PROMIS-602
     */
    public void licenseDetailsPopupList(PopupFetchEvent popupFetchEvent) {

        if (popupFetchEvent.getLaunchSourceClientId().contains("b1_addLicenseDetails")) {
            this.setEditArea("parametersEditArea");
            BindingContainer bc = BindingContext.getCurrent().getCurrentBindingsEntry();
            bc.getOperationBinding("LicenseDetailsCreateInsert").execute();
        }
    }

    public void onLicenseDetailsEdit(DialogEvent event) {

        this.setEditArea("popLicenseDetailsEditArea");
        if (event.getOutcome()
                 .name()
                 .equals("ok")) {
            // UtilitiesBean.setBaCode("ProjectEdit");
            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                     .getDataControl()
                     .commitTransaction();
            // UtilitiesBean.setBaCode(null);
            ViewUtils.executeIterators("LicenseDetailsViewIterator");
            this.setEditArea("parametersEditArea");
        }
        if (event.getOutcome()
                 .name()
                 .equals("cancel")) {
            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                     .getDataControl()
                     .rollbackTransaction();
            this.setEditArea("parametersEditArea");
        }
    }

    public void deleteLicenseDetails(ActionEvent event) {
        LicenseDetailsViewRow collRow = (LicenseDetailsViewRow) ViewUtils.getIteratorBinding("LicenseDetailsViewIterator")
                                                                         .getViewObject()
                                                                         .getCurrentRow();
        if (collRow != null) {
            ViewUtils.getOperationBinding("LicenseDetailsDelete").execute();
            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                     .getDataControl()
                     .commitTransaction();
            ViewUtils.reloadUiComponent("tblLicenseDetails");
        }
    }

    /**
     *
     * Create New Dev Project Under Samd Project-- PROMIS 604
     */
    public void onProjectCreatePopupFetch(PopupFetchEvent event) {
        ViewUtils.getOperationBinding("CreatePrEdit").execute();
        ProjectViewRow prjcurRow = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);
        ProjectViewRow prjRow = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_1_VIEW_IT);
        prjRow.setCategoryCode("NF");
        prjRow.setStateCode("0");
        prjRow.setSubstanceTypeCode("0");
        prjRow.setAreaCode("POST-POT");
        prjRow.setPhaseCode("9");
        prjRow.setPriorityCode("n.a.");         //PROMIS-602
        prjRow.setAttribute("PhaseEstimatedCode", "NA");
        prjRow.setAttribute("Name", prjcurRow.getAttribute("Name"));
        prjRow.setAttribute("SourceCode", prjcurRow.getAttribute("SourceCode"));
        prjRow.setAttribute("ProposedSbeCode", prjcurRow.getAttribute("SbeCode"));
    }

    public void onProjectCreatePopupCancel(PopupCanceledEvent event) {
        super.onPopupCancel(event);
    }

    /*
 * Method to create Dev project from Samd project --PROMIS 604
 */
    public void onProjectCreate(DialogEvent event) {

        UtilitiesBean.setBaCode("ProjectCreate");
        ProjectViewRow prjInstRow = (ProjectViewRow) ViewUtils.getCurrentRow("ProjectView1Iterator");
        ProjectViewRow prjcurRow = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);
        String curId=prjcurRow.getAttribute("Id").toString();
        onPopupSubmit(event);
        String newId = prjInstRow.getAttribute("Id").toString();
        onDevProjectIdSet(curId, newId);
        prjInstRow.setRelation(prjInstRow.getPredecessorProjectId(), null);
        UtilitiesBean.setBaCode(null);

        UtilitiesBean.setBaCode("UnlockSendReceive");
        prjInstRow.send();
        UtilitiesBean.setBaCode(null);

        Properties eventProps = new Properties();
        Object object = eventProps.setProperty("action", "createProject");
        ViewUtils.publishEvent("projectEventBinding", eventProps);

        if (UtilitiesBean.isUserInRole("ProjectCreateDev")) {
            prjInstRow.notifyProjectCreated();
        }

        ViewUtils.executeIterators("ProjectRelatedDevViewIterator", "AllDevPrjMntViewIterator", "ProjectViewIterator");
        ViewUtils.reloadUiComponent("sdiOverview");

    }

    /**
     * Method to insert Project Code of newly created Dev project and assosiated Samd Id-- PROMIS 604
     */
    public void onMspProjectIdSet(String devCode, String samdId) {

        ViewUtils.getOperationBinding("CreateInsertRelatedMsp").execute();
        ProjectRelatedMspViewRow prjRowMsp =
            (ProjectRelatedMspViewRow) ViewUtils.getCurrentRow("ProjectRelatedMspView1Iterator");
        if (prjRowMsp.getAttribute("ProjectCode").toString() != null)
            prjRowMsp.setAttribute("ProjectCode", devCode);
        prjRowMsp.setAttribute("RelMspProjectId", samdId);

    }
    
    /**
     * Method to insert Project Code of newly created Dev project and assosiated Samd Id-- PROMIS 604
     */
    public void onDevProjectIdSet(String samdId, String devCode) {

        ViewUtils.getOperationBinding("CreateInsertRelatedDev").execute();
        ProjectRelatedDevViewRow prjRowDev =
            (ProjectRelatedDevViewRow) ViewUtils.getCurrentRow("ProjectRelatedDevView1Iterator");
        if (prjRowDev.getAttribute("ProjectId").toString() != null)
            prjRowDev.setAttribute("ProjectId", samdId);
        prjRowDev.setAttribute("DevProjectId", devCode);

    }

    public void onPredecessorChange(ValueChangeEvent event) {

        event.getComponent().processUpdates(FacesContext.getCurrentInstance());
        ProjectViewRow prjRow = (ProjectViewRow) ViewUtils.getCurrentRow("ProjectView1Iterator");

        if (prjRow.getPredecessorProjectId() != null) {
            ProjectView predPrjVo =
                (ProjectView) ViewUtils.getIteratorBinding("AllD2ProjectViewIterator").getViewObject();
            Key key = new Key(new Object[] { prjRow.getPredecessorProjectId() });
            ProjectViewRow prjPredRow = (ProjectViewRow) predPrjVo.findByKey(key, 1)[0];
            UtilitiesBean.prefillProjectPredecessor(prjPredRow, prjRow);
        }
    }

}


