package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.ProgramGoalsViewImpl;
import com.bayer.ipms.model.views.ProgramGoalsViewRowImpl;
import com.bayer.ipms.model.views.ProgramViewRowImpl;
import com.bayer.ipms.model.views.ProjectGoalViewImpl;
import com.bayer.ipms.model.views.RoleViewImpl;
import com.bayer.ipms.model.views.RoleViewImpl.Role;
import com.bayer.ipms.model.views.UserViewImpl;
import com.bayer.ipms.model.views.common.ProgramGoalsViewRow;
import com.bayer.ipms.model.views.common.ProgramViewRow;
import com.bayer.ipms.model.views.common.ProjectTimelineView;
import com.bayer.ipms.model.views.common.ProjectTimelineViewRow;
import com.bayer.ipms.model.views.common.ProjectView;
import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.model.views.common.RoleView;
import com.bayer.ipms.model.views.common.SandboxViewRow;
import com.bayer.ipms.model.views.lookups.common.ProgramGoalTargetYearView;
import com.bayer.ipms.view.base.IPMSViewBean;
import com.bayer.ipms.view.utils.ViewUtils;

import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.component.rich.RichPopup;
import oracle.adf.view.rich.component.rich.data.RichTable;
import oracle.adf.view.rich.component.rich.data.RichTreeTable;
import oracle.adf.view.rich.component.rich.fragment.RichDynamicDeclarativeComponent;
import oracle.adf.view.rich.component.rich.layout.RichPanelHeader;
import oracle.adf.view.rich.component.rich.layout.RichShowDetailItem;
import oracle.adf.view.rich.context.AdfFacesContext;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;
import oracle.adf.view.rich.render.ClientEvent;

import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.RowSet;
import oracle.jbo.RowSetIterator;
import oracle.jbo.VariableValueManager;
import oracle.jbo.ViewObject;
import oracle.jbo.common.ViewCriteriaImpl;
import oracle.jbo.server.ViewObjectImpl;
import oracle.jbo.server.ViewRowImpl;

import org.apache.myfaces.trinidad.component.UIXCommand;
import org.apache.myfaces.trinidad.event.DisclosureEvent;
import org.apache.myfaces.trinidad.event.PollEvent;
import org.apache.myfaces.trinidad.event.ReturnEvent;
import org.apache.myfaces.trinidad.model.CollectionModel;
import org.apache.myfaces.trinidad.model.RowKeySet;
import org.apache.myfaces.trinidad.model.RowKeySetImpl;

public class ProgramViewBean extends IPMSViewBean {

    private static final String SANDBOX_VIEW_IT = "SandboxViewIterator";
    private static final String PROGRAM_VIEW_IT = "ProgramViewIterator";
    private static final String PROJECT_VIEW_IT = "ProjectViewIterator";
    private static final String IMPORT_VIEW_IT = "ImportViewIterator";
    private static final String GOAL_VIEW_IT = "ProgramGoalsIterator";
    private static final String COPY_SANDBOX = "CopySandbox";
    private static final String COPY_PROJECT = "CopyProject";
    private static final String MODIFY_SOURCE = "ModifySource";
    protected String activeTab = "sdiProjects";
    private String onSandboxPopupOpen;
    protected String insertable = null;
    private UIComponent rootComponent;
    private RichTreeTable topNonIndtabTree;
    private RichTreeTable tblTopVersionValuesTree;
    private RichTreeTable toptabTree;
    private RichTreeTable topNonIndVersiontabTree;
    
    
    private UIComponent programGoalTable;
    
    private Integer programGoalId;
    private String programId;

    public ProgramViewBean() {
        super("ProgramViewIterator");
    }

    public String getInsertable() {
        return insertable;
    }

    public void onProjectTableSelect(ClientEvent clientEvent) {
        ViewUtils.publishEvent("projectEventBinding");
    }

    protected void rollback() {
        super.rollback();

        //ViewUtils.executeIterators("UserRoleViewIterator");
    }

    public void onProjectCreate(DialogEvent event) {

        UtilitiesBean.setBaCode("ProjectCreate");
        ProjectViewRow prjRow = (ProjectViewRow) ViewUtils.getCurrentRow("ProjectViewIterator");
        onPopupSubmit(event);
        prjRow.setRelation(prjRow.getPredecessorProjectId(),null);
        UtilitiesBean.setBaCode(null);
        
        UtilitiesBean.setBaCode("UnlockSendReceive");
        prjRow.send();
        UtilitiesBean.setBaCode(null);

        Properties eventProps = new Properties();
        Object object = eventProps.setProperty("action", "createProject");
        ViewUtils.publishEvent("programEventBinding", eventProps);

        if (UtilitiesBean.isUserInRole("ProjectCreateDev")) {
            prjRow.notifyProjectCreated();
        }
    }

    public void onPredecessorChange(ValueChangeEvent event) {

        event.getComponent().processUpdates(FacesContext.getCurrentInstance());
        ProjectViewRow prjRow = (ProjectViewRow) ViewUtils.getCurrentRow("ProjectViewIterator");

        if (prjRow.getPredecessorProjectId() != null) {
            ProjectView predPrjVo =
                (ProjectView) ViewUtils.getIteratorBinding("AllD2ProjectViewIterator").getViewObject();
            Key key = new Key(new Object[] { prjRow.getPredecessorProjectId() });
            ProjectViewRow prjPredRow = (ProjectViewRow) predPrjVo.findByKey(key, 1)[0];
            UtilitiesBean.prefillProjectPredecessor(prjPredRow, prjRow);
        }
    }

    public void onRename(DialogEvent event) {
        UtilitiesBean.setBaCode("ProgramEdit");
        ViewUtils.getIteratorBinding("ProgramViewIterator").getDataControl().commitTransaction();
        UtilitiesBean.setBaCode("UnlockSendReceive");
        ((ProgramViewRow) ViewUtils.getCurrentRow("ProgramViewIterator")).send();
        UtilitiesBean.setBaCode(null);
        ViewUtils.publishEvent("programEventBinding");
    }

    public void onDelete(DialogEvent event) {
        UtilitiesBean.setBaCode("ProgramDelete");
        ViewUtils.getIteratorBinding("ProgramViewIterator").removeCurrentRow();
        ViewUtils.getIteratorBinding("ProgramViewIterator").getDataControl().commitTransaction();
        UtilitiesBean.setBaCode(null);
        Properties eventProps = new Properties();
        eventProps.setProperty("action", "deleteProgram");
        ViewUtils.publishEvent("programEventBinding", eventProps);
    }

    public String onLead() {
        ProjectViewRow prj = (ProjectViewRow) ViewUtils.getCurrentRow("ProjectViewIterator");
        UtilitiesBean.setBaCode("ProjectLead");
        prj.lead();
        UtilitiesBean.setBaCode(null);

        ViewUtils.executeIterators("ProjectViewIterator");

        return null;
    }

    protected void refresh(boolean forced) {
        super.refresh(forced);

        if (forced) {
            ViewUtils.executeIterators("ProjectViewIterator", "UserRoleViewIterator", "SandboxViewIterator",
                                       "GoalPhaseIterator", TopBean.TOP_VERSION_CAT_VIEW_IT);
        }

        ViewUtils.publishEvent("programEventBinding");
    }

    public void onProjectCreatePopupFetch(PopupFetchEvent event) {
        ViewUtils.getOperationBinding("ProjectCreateInsert").execute();
        ProjectViewRow prjRow = (ProjectViewRow) ViewUtils.getCurrentRow("ProjectViewIterator");
        prjRow.setStateCode("0");
//        prjRow.setPriorityCode("2");
        prjRow.setPriorityCode("n.a."); //PROMIS-602
    }

    
    public void onProjectCreatePopupCancel(PopupCanceledEvent event) {
        super.onPopupCancel(event);
    }

    public void onSandboxCreatePopupCancel(PopupCanceledEvent event) {

        SandboxViewRow sndView =
            (SandboxViewRow) ViewUtils.getIteratorBinding(SANDBOX_VIEW_IT).getViewObject().getCurrentRow();

        if (sndView != null) {

            RowSet rs = sndView.getProjectTimelineView();

            ViewObject voTableData = rs.getViewObject();

            ProjectTimelineView ptv = (ProjectTimelineView) voTableData;

            ptv.setTimeLineTypeCode(null);
            ptv.getViewCriteriaManager().setApplyViewCriteriaName("TimeLineTypeCR");
            ptv.executeQuery();
            refreshSandboxCurrRow();
        }

        super.onPopupCancel(event);
    }

    public void onSandboxDelete(DialogEvent event) {
        // Take target view
        RichTable target = (RichTable) ViewUtils.getUiComponent("tblSand");
        RowKeySet keySet = target.getSelectedRowKeys();
        CollectionModel cm = (CollectionModel) target.getValue();

        ProgramViewRow proViewRow =
            (ProgramViewRow) ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT).getViewObject().getCurrentRow();

        UtilitiesBean.setBaCode("SandboxPlanDelete");
        // loop through selected rows
        for (Iterator it = keySet.iterator(); it.hasNext();) {
            List<Key> keys = (List<Key>) it.next();

            SandboxViewRow snd = (SandboxViewRow) proViewRow.getSandboxView().findByKey(keys.get(0), 1)[0];
            snd.deleteStart();

            snd.setIsActive(0);

            ViewUtils.getIteratorBinding(SANDBOX_VIEW_IT).getDataControl().commitTransaction();
        }
        UtilitiesBean.setBaCode(null);

        ViewUtils.getIteratorBinding(SANDBOX_VIEW_IT).executeQuery();
        ViewUtils.reloadUiComponent("tblSand");
    }

    public void onSandboxCreate(DialogEvent dialogEvent) {

        String sndaction = getOnSandboxPopupOpen();

        if (sndaction != null) {

            if (sndaction.contains(COPY_SANDBOX) || sndaction.contains(COPY_PROJECT)) {

                UtilitiesBean.setBaCode("SandboxPlanCreate");
                onPopupSubmit(dialogEvent);
                UtilitiesBean.setBaCode(null);

                SandboxViewRow sndRow = (SandboxViewRow) ViewUtils.getCurrentRow(SANDBOX_VIEW_IT);
                sndRow.createStart();

                ProgramViewRow proViewRow = (ProgramViewRow) ViewUtils.getCurrentRow(PROGRAM_VIEW_IT);

                refreshSandboxCurrRow();

                proViewRow.refresh();

            } else if (sndaction.contains(MODIFY_SOURCE)) {

                onSourceModify(dialogEvent);
            } else
                refreshSandboxCurrRow();
        }

        SandboxViewRow sndView =
            (SandboxViewRow) ViewUtils.getIteratorBinding(SANDBOX_VIEW_IT).getViewObject().getCurrentRow();

        if (sndView != null) {

            RowSet rs = sndView.getProjectTimelineView();

            ViewObject voTableData = rs.getViewObject();

            ProjectTimelineView ptv = (ProjectTimelineView) voTableData;

            ptv.setTimeLineTypeCode(null);
            ptv.getViewCriteriaManager().setApplyViewCriteriaName("TimeLineTypeCR");
            ptv.executeQuery();
            refreshSandboxCurrRow();
        }

    }


    public void onSandboxCreatePopupFetch(PopupFetchEvent popupFetchEvent) {

        String sndaction = getOnSandboxPopupOpen();

        if (sndaction != null) {

            if (sndaction.contains(COPY_SANDBOX)) {

                SandboxViewRow sndFromRow = (SandboxViewRow) ViewUtils.getCurrentRow(SANDBOX_VIEW_IT);

                ViewUtils.getOperationBinding("SandboxCreateInsert").execute();

                SandboxViewRow sndNewRow = (SandboxViewRow) ViewUtils.getCurrentRow(SANDBOX_VIEW_IT);

                if (sndFromRow != null) {

                    sndNewRow.setCode(sndFromRow.getCode());
                    sndNewRow.setName(sndFromRow.getName());
                    sndNewRow.setTimelineId(sndFromRow.getTimelineId());

                    if (sndNewRow.getTimelineId() != null && !sndNewRow.getTimelineId().contains("SND")) {

                        sndNewRow.setSndId(null);
                    } else {
                        sndNewRow.setSndId(sndFromRow.getId());
                    }
                }
            } else if (sndaction.contains(COPY_PROJECT)) {

                ProjectViewRow prjFromRow = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);

                ViewUtils.getOperationBinding("SandboxCreateInsert").execute();

                SandboxViewRow sndProjNewRow = (SandboxViewRow) ViewUtils.getCurrentRow(SANDBOX_VIEW_IT);

                if (prjFromRow != null) {

                    sndProjNewRow.setCode(prjFromRow.getCode());
                    sndProjNewRow.setName(prjFromRow.getName());
                    sndProjNewRow.setTimelineId(prjFromRow.getTimelineRawId());
                    sndProjNewRow.setSndId(null);

                }
            } else if (sndaction.contains(MODIFY_SOURCE)) {
                onSandboxSourceModifyPopupFetch(popupFetchEvent);

            } else
                ViewUtils.getOperationBinding("SandboxCreateInsert").execute();
        }
    }

    public void refreshSandboxCurrRow() {
        // super.refresh(true);
        SandboxViewRow sndRow = (SandboxViewRow) ViewUtils.getCurrentRow(SANDBOX_VIEW_IT);

        if (sndRow != null) {
            sndRow.refresh();
            ViewUtils.reloadUiComponent("tblSand");
        }
    }

    @Override
    public void onPoll(PollEvent pollEvent) {
        super.onPoll(pollEvent);
        refreshSandboxCurrRow();
        refreshGoalCurrRow();
        TopBean top = new TopBean();
        top.refreshCurrent();
    }

    public void onSourceProjectChange(ValueChangeEvent valueChangeEvent) {

        String sndaction = getOnSandboxPopupOpen();

        if (!MODIFY_SOURCE.equals(sndaction)) {

            valueChangeEvent.getComponent().processUpdates(FacesContext.getCurrentInstance());
            SandboxViewRow sndRow = (SandboxViewRow) ViewUtils.getCurrentRow(SANDBOX_VIEW_IT);

            ProgramViewRow prgView =
                (ProgramViewRow) ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT).getViewObject().getCurrentRow();

            Key key = new Key(new Object[] { sndRow.getTimelineId() });

            ProjectTimelineViewRow prTimRow = (ProjectTimelineViewRow) prgView.getProjectTimelineView().getRow(key);


            if (prTimRow != null) {
                sndRow.setCode(prTimRow.getProjectCode());
                sndRow.setName(prTimRow.getName1());
                sndRow.setDescription(prTimRow.getProjectDescription());

                if (sndRow.getTimelineId() != null && !sndRow.getTimelineId().contains("SND")) {
                    sndRow.setSndId(null);
                }

            } else {
                sndRow.setCode(null);
                sndRow.setName(null);
                sndRow.setDescription(null);
                sndRow.setSndId(null);
            }

            ViewUtils.reloadUiComponent("prjscode", "prjsname2");
        }
    }

    public void onSourceModify(DialogEvent dialogEvent) {

        UtilitiesBean.setBaCode("SandboxPlanModify");
        onPopupSubmit(dialogEvent);
        UtilitiesBean.setBaCode(null);

        refreshSandboxCurrRow();

    }

    public void onSandboxSourceModifyPopupFetch(PopupFetchEvent popupFetchEvent) {
        SandboxViewRow sndRow = (SandboxViewRow) ViewUtils.getCurrentRow(SANDBOX_VIEW_IT);

        if (sndRow.getTimelineId() != null && !sndRow.getTimelineId().contains("SND")) {
            sndRow.setSndId(null);
        }
    }

    public void onSandboxImportActuals(DialogEvent dialogEvent) {
        UtilitiesBean.setBaCode("SandboxPlanImportActuals");

        ViewUtils.getOperationBinding("ImportCreateWithParams").execute();
        ViewUtils.getIteratorBinding(IMPORT_VIEW_IT).getDataControl().commitTransaction();

        ViewUtils.getOperationBinding("ImportLaunch").execute();
        ViewUtils.getIteratorBinding(IMPORT_VIEW_IT).getDataControl().commitTransaction();

        UtilitiesBean.setBaCode(null);
    }

    public void onSandboxCreatePopup(ActionEvent event) {
        String sndaction = getOnSandboxPopupOpen();

        if (sndaction.contains(MODIFY_SOURCE)) {

            SandboxViewRow sndView =
                (SandboxViewRow) ViewUtils.getIteratorBinding(SANDBOX_VIEW_IT).getViewObject().getCurrentRow();

            if (sndView != null) {

                RowSet rs = sndView.getProjectTimelineView();

                ViewObject voTableData = rs.getViewObject();

                ProjectTimelineView ptv = (ProjectTimelineView) voTableData;
                ptv.setTimeLineTypeCode("RAW");
                ptv.getViewCriteriaManager().setApplyViewCriteriaName("TimeLineTypeCR");
                ptv.executeQuery();
                refreshSandboxCurrRow();
            }
            RichPopup popSandboxModify = (RichPopup) ViewUtils.getUiComponent("popSandboxCreate");

            popSandboxModify.show(new RichPopup.PopupHints());
        } else {

            SandboxViewRow sndView =
                (SandboxViewRow) ViewUtils.getIteratorBinding(SANDBOX_VIEW_IT).getViewObject().getCurrentRow();

            if (sndView != null) {

                RowSet rs = sndView.getProjectTimelineView();

                ViewObject voTableData = rs.getViewObject();

                ProjectTimelineView ptv = (ProjectTimelineView) voTableData;

                ptv.setTimeLineTypeCode(null);
                ptv.getViewCriteriaManager().setApplyViewCriteriaName("TimeLineTypeCR");
                ptv.executeQuery();
                refreshSandboxCurrRow();
            }

            DCIteratorBinding it = ViewUtils.getIteratorBinding(SANDBOX_VIEW_IT);
            Long sandIterRows = it.getEstimatedRowCount();
            Long sandLimit =
                new Long((String) ViewUtils.runValueEl("#{bindings.ConfigViewIterator.viewObject.values['LMTSANDBOX']}"));
            if (sandIterRows < (Long) sandLimit) {
                if (sndaction.contains(COPY_PROJECT)) {
                    RichPopup popSandboxCp = (RichPopup) ViewUtils.getUiComponent("popSandboxCreate");
                    popSandboxCp.show(new RichPopup.PopupHints());
                } else {
                    RichPopup popSandboxCr = (RichPopup) ViewUtils.getUiComponent("popSandboxCreate");
                    popSandboxCr.show(new RichPopup.PopupHints());
                }
            } else {
                RichPopup popSandboxLimitsExc = (RichPopup) ViewUtils.getUiComponent("popSandboxLimitsExc");
                popSandboxLimitsExc.show(new RichPopup.PopupHints());
            }
        }
    }

    public void setOnSandboxPopupOpen(String onSandboxPopupOpen) {
        this.onSandboxPopupOpen = onSandboxPopupOpen;
    }

    public String getOnSandboxPopupOpen() {
        return onSandboxPopupOpen;
    }

    public String getSandboxDBId() {

        DCIteratorBinding it = ViewUtils.getIteratorBinding(SANDBOX_VIEW_IT);
        ViewObject voTableData = it.getViewObject();

        Row rowSelected = voTableData.getCurrentRow();

        return rowSelected.getAttribute("Id").toString();

    }

    public String getSandboxCode() {

        DCIteratorBinding it = ViewUtils.getIteratorBinding(SANDBOX_VIEW_IT);
        ViewObject voTableData = it.getViewObject();

        Row rowSelected = voTableData.getCurrentRow();

        return rowSelected.getAttribute("Code").toString();

    }

    public String getSandboxName() {

        DCIteratorBinding it = ViewUtils.getIteratorBinding(SANDBOX_VIEW_IT);
        ViewObject voTableData = it.getViewObject();

        Row rowSelected = voTableData.getCurrentRow();

        return rowSelected.getAttribute("Name").toString();

    }

    public void onGoalCreateFetch(ActionEvent event) {
        ViewUtils.getOperationBinding("GoalCreateInsert").execute();

        String target = (String) event.getComponent().getAttributes().get("target");
        this.insertable = target;

        super.onEdit(event);
    }

    public void refreshGoalCurrRow() {
        ProgramGoalsViewRow goalRow = (ProgramGoalsViewRow) ViewUtils.getCurrentRow(GOAL_VIEW_IT);

        if (goalRow != null) {
            goalRow.refresh();
            ViewUtils.reloadUiComponent("tblGoal");
        }
    }

    public void resetGoalFilter() {
        ProgramGoalsViewRow prgGl = (ProgramGoalsViewRow) ViewUtils.getIteratorBinding(GOAL_VIEW_IT).getCurrentRow();

        if (prgGl != null) {
            RowSet rs = prgGl.getProgramAppModule_ProgramGoalTargetYearView();
            ViewObject voTableData = rs.getViewObject();
            ProgramGoalTargetYearView pgtv = (ProgramGoalTargetYearView) voTableData;
            pgtv.getViewCriteriaManager().clearViewCriterias();
            pgtv.executeQuery();
        }
    }

    public void onGoalCreate(ActionEvent event) {
        if ("prjgoal".equals(insertable)) {
            UtilitiesBean.setBaCode("GoalsCreate");
        } else if ("prjgoal".equals(editable)) {
            UtilitiesBean.setBaCode("GoalsEdit");
        }
        ViewUtils.getIteratorBinding(GOAL_VIEW_IT).getDataControl().commitTransaction();
        UtilitiesBean.setBaCode(null);
        ViewUtils.getIteratorBinding(GOAL_VIEW_IT).executeQuery();
        ViewUtils.reloadUiComponent("tblGoal");

        this.insertable = null;

        super.onEdit(event);
        resetGoalFilter();
    }

    public void onGoalCreateCancel(ActionEvent event) {
        this.insertable = null;

        super.onRollback(event);
    }

    public RowKeySet getSandboxSelectedKeys() {

        SandboxViewRow sndView = (SandboxViewRow) ViewUtils.getIteratorBinding(SANDBOX_VIEW_IT).getCurrentRow();

        RowKeySet selectedRowKeys = new RowKeySetImpl();

        if (sndView != null) {
            ViewUtils.getIteratorBinding(SANDBOX_VIEW_IT).setCurrentRowWithKey(sndView.getKey().toStringFormat(true));
            selectedRowKeys.add(Arrays.asList(sndView.getKey()));
        }

        return selectedRowKeys;
    }

    public void onGoalDelete(DialogEvent event) {

        // Take target iterator
        UtilitiesBean.setBaCode("GoalsDelete");
        // Take target iterator
        ProgramGoalsViewImpl  programGoalVO = (ProgramGoalsViewImpl)ViewUtils.getIteratorBinding(GOAL_VIEW_IT).getViewObject();
        if(programGoalVO.getCurrentRow() != null) {
            programGoalVO.getCurrentRow().remove();
        }
        programGoalVO.getDBTransaction().commit();
        programGoalVO.executeQuery();

        UtilitiesBean.setBaCode(null);
        ViewUtils.reloadUiComponent("prggoalremoveid", "prggoalsedit", "tblGoal");
    }

    public void onProjectCreatePopup(ActionEvent event) {

        RichDynamicDeclarativeComponent popPrj =
            (RichDynamicDeclarativeComponent) ViewUtils.getUiComponent("popCompPrj");

        RichPopup popProjectCreate = (RichPopup) popPrj.findComponent("popCreateProject");

        popProjectCreate.show(new RichPopup.PopupHints());
    }

    public void onUnlock(ActionEvent actionEvent) {
        ProgramViewRow prg =
            (ProgramViewRow) ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT).getViewObject().getCurrentRow();
        UtilitiesBean.setBaCode("UnlockSendReceive");
        prg.unlock();
        UtilitiesBean.setBaCode(null);
    }

    public void onSend(ActionEvent actionEvent) {
        ProgramViewRow prg =
            (ProgramViewRow) ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT).getViewObject().getCurrentRow();
        UtilitiesBean.setBaCode("UnlockSendReceive");
        prg.send();
        UtilitiesBean.setBaCode(null);
    }

    public void onReceive(ActionEvent actionEvent) {
        ProgramViewRow prg =
            (ProgramViewRow) ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT).getViewObject().getCurrentRow();
        UtilitiesBean.setBaCode("UnlockSendReceive");
        prg.receive();
        UtilitiesBean.setBaCode(null);
    }

    public void tabDisclosure(DisclosureEvent event) {

        System.err.println("tabDisclosure start..." + event);
        RichShowDetailItem detItem = ((RichShowDetailItem) event.getComponent());
            
        if (detItem.isDisclosed()) {
            activeTab = detItem.getId();
        }
    }

    public String onRefresh() {

        super.refresh(true);
        
        if ("sdiProjects".equals(activeTab)) {
            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).executeQuery();
            ViewUtils.reloadUiComponent("tblProjects");
        } else if ("sdiGoals".equals(activeTab)) {
            ViewUtils.getIteratorBinding("GoalPhaseIterator").executeQuery();
            ViewUtils.getIteratorBinding(GOAL_VIEW_IT).executeQuery();
            ViewUtils.reloadUiComponent("tblGoal");
        } else if ("sdiSandbox".equals(activeTab)) {
            ViewUtils.getIteratorBinding(SANDBOX_VIEW_IT).executeQuery();
            ViewUtils.reloadUiComponent("tblSand");
        } else if ("sdiTop".equals(activeTab)) {
            ViewUtils.getIteratorBinding(TopBean.TOP_VERSION_CAT_VIEW_IT).executeQuery();
            ViewUtils.reloadUiComponent("toptab");
        } 
        
        return null;
    }

    public Integer getGoalSelectedKeys() {
        Integer selGoalRows = 0;

        RichTable table = (RichTable) ViewUtils.getUiComponent("tblGoal");
        RowKeySet keySet = table.getSelectedRowKeys();

        if (keySet != null) {
            // Take target iterator
            DCIteratorBinding iterator = ViewUtils.getIteratorBinding(GOAL_VIEW_IT);

            RowSetIterator rsIt = iterator.getRowSetIterator();

            for (Iterator it = keySet.iterator(); it.hasNext();) {
                List<Key> keys = (List<Key>) it.next();
                ViewRowImpl row = (ViewRowImpl) rsIt.getRow(keys.get(0));
                if (row != null) {
                    selGoalRows++;
                }
            }
        }

        return selGoalRows;
    }

    public void onGoalsTabClick(ClientEvent event) {
        if (!"prjgoal".equals(getEditable())) {
            ViewUtils.reloadUiComponent("prggoalremoveid");
        }
    }

    public void customButtonActionListener(ClientEvent clientEvent) {
         UIXCommand cb = (UIXCommand) clientEvent.getComponent();
         cb.broadcast(new ActionEvent(cb));
     }
    
    
    public void expandProgramTopTree(org.apache.myfaces.trinidad.event.PollEvent e) {
        ViewUtils.discloseAllTreeTableNodes("toptab");
        ViewUtils.discloseAllTreeTableNodes("topNonIndtab");
        ViewUtils.discloseAllTreeTableNodes("tblTopVersionValues");
        ViewUtils.discloseAllTreeTableNodes("topNonIndVersiontab");
        AdfFacesContext.getCurrentInstance().addPartialTarget(topNonIndtabTree);
        AdfFacesContext.getCurrentInstance().addPartialTarget(toptabTree);
    }
    
    public void programMenuChangedEventConsumer(String param) {
        System.err.println("programMenuChangedEventConsumer EVENT RECEIVED................");
        expandProgramTopTree(null);
        
       
    }


    public void setRootComponent(UIComponent rootComponent) {
        this.rootComponent = rootComponent;
    }

    public UIComponent getRootComponent() {
        return rootComponent;
    }

    public void setTopNonIndtabTree(RichTreeTable topNonIndtabTree) {
        this.topNonIndtabTree = topNonIndtabTree;
    }

    public RichTreeTable getTopNonIndtabTree() {
        return topNonIndtabTree;
    }

    public void setTblTopVersionValuesTree(RichTreeTable tblTopVersionValuesTree) {
        this.tblTopVersionValuesTree = tblTopVersionValuesTree;
    }

    public RichTreeTable getTblTopVersionValuesTree() {
        return tblTopVersionValuesTree;
    }

    public void setToptabTree(RichTreeTable toptabTree) {
        this.toptabTree = toptabTree;
    }

    public RichTreeTable getToptabTree() {
        return toptabTree;
    }

    public void setTopNonIndVersiontabTree(RichTreeTable topNonIndVersiontabTree) {
        this.topNonIndVersiontabTree = topNonIndVersiontabTree;
    }

    public RichTreeTable getTopNonIndVersiontabTree() {
        return topNonIndVersiontabTree;
    }
    
    
    public void initMaintainGoalsScreen() {
        System.err.println("initMaintainGoalsScreen: programId:" + AdfFacesContext.getCurrentInstance().getPageFlowScope().get("programId"));                                                                                   
        System.err.println("initMaintainGoalsScreen: programGoalId:" + AdfFacesContext.getCurrentInstance().getPageFlowScope().get("programGoalId"));                                                                                   
        ViewUtils.getOperationBinding("initMaintainGoals").execute();
        System.err.println("ends initMaintainGoalsScreen");
    }
    
    public void onMaintainGoalsReturn(ReturnEvent returnEvent) {
        ProjectGoalViewImpl vo = (ProjectGoalViewImpl)ViewUtils.getIteratorBinding("ProjectGoalViewIterator").getViewObject();
        //grab the internal instance used in af:query filter
        ViewObject vos00 = vo.getApplicationModule().findViewObject("ProgramGoalTargetYearView");
        if(vos00 != null)
            vos00.executeQuery();
        
        AdfFacesContext.getCurrentInstance().addPartialTarget(programGoalTable);
    }
    
    public String gotoEditGoals() {
       ProgramGoalsViewRowImpl row =  (ProgramGoalsViewRowImpl)ViewUtils.getIteratorBinding("ProgramGoalsIterator").getCurrentRow();
       setProgramGoalId(row.getId());
       setProgramId(row.getProgramId());
       return "maintain-goals";
    }
    
    public String gotoAddGoals() {
        ProgramViewRowImpl row =  (ProgramViewRowImpl)ViewUtils.getIteratorBinding("ProgramViewIterator").getCurrentRow();
       setProgramGoalId(null);
       setProgramId(row.getId());
       return "maintain-goals";
    }
    
    public String saveProgramGoal() {
        
       ViewUtils.getIteratorBinding("ProgramViewIterator").getDataControl().commitTransaction();
       return "back";
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


    public void setProgramGoalTable(UIComponent programGoalTable) {
        this.programGoalTable = programGoalTable;
    }

    public UIComponent getProgramGoalTable() {
        return programGoalTable;
    }
    
    public String getProgramIdForTeamMembers() {
        return (String)ViewUtils.runValueEl("#{bindings.Id.inputValue}");
    }


    public String getProjectTypeForTeamMembers() {
        return (String)ViewUtils.runValueEl("#{pageFlowScope.projectType}");
    }
    
    public List getUserList() {
        
        UserViewImpl vo = (UserViewImpl)ViewUtils.getIteratorBinding("UserViewIterator").getViewObject();
        
        return vo.getUserList();
        
    }
}
