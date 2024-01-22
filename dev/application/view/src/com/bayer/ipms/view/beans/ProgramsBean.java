package com.bayer.ipms.view.beans;


import com.bayer.ipms.model.views.common.ProgramView;
import com.bayer.ipms.model.views.common.ProgramViewRow;
import com.bayer.ipms.model.views.common.ProjectView;
import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.model.views.common.SandboxViewRow;
import com.bayer.ipms.model.views.common.TargetProductProfileView;
import com.bayer.ipms.model.views.lookups.common.ProjectAreaView;
import com.bayer.ipms.model.views.lookups.common.ProjectAreaViewRow;
import com.bayer.ipms.view.base.IPMSBean;
import com.bayer.ipms.view.events.ContextualEventHandler;
import com.bayer.ipms.view.utils.ViewUtils;

import java.io.Serializable;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import javax.faces.application.FacesMessage;
import javax.faces.application.ViewHandler;
import javax.faces.component.UIComponent;
import javax.faces.component.UIViewRoot;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import javax.faces.validator.ValidatorException;

import oracle.adf.controller.TaskFlowId;
import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.share.ADFContext;
import oracle.adf.share.security.SecurityContext;
import oracle.adf.view.rich.component.rich.RichQuery;
import oracle.adf.view.rich.component.rich.data.RichTree;
import oracle.adf.view.rich.component.rich.input.RichSelectOneChoice;
import oracle.adf.view.rich.component.rich.layout.RichShowDetailItem;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;
import oracle.adf.view.rich.event.QueryEvent;
import oracle.adf.view.rich.event.QueryOperationEvent;
import oracle.adf.view.rich.model.AttributeCriterion;
import oracle.adf.view.rich.model.AttributeDescriptor;
import oracle.adf.view.rich.model.Criterion;
import oracle.adf.view.rich.model.FilterableQueryDescriptor;
import oracle.adf.view.rich.model.QueryDescriptor;

import oracle.binding.BindingContainer;

import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewCriteriaManager;
import oracle.jbo.server.ViewRowImpl;
import oracle.jbo.uicli.binding.JUCtrlActionBinding;
import oracle.jbo.uicli.binding.JUCtrlHierBinding;

import org.apache.commons.lang.StringUtils;
import org.apache.myfaces.trinidad.event.DisclosureEvent;
import org.apache.myfaces.trinidad.event.SelectionEvent;
import org.apache.myfaces.trinidad.model.CollectionModel;

/**
 * Provides in the programs.jspx page functionality for
 * tree navigation and region content management.
 */
public class ProgramsBean extends IPMSBean implements Serializable {
    private String taskFlowId = null;
    private String projectType = null;
    private static final String TF_PROGRAM = "/WEB-INF/com.bayer.ipms.view/flows/program-view.xml#program-view";
    private static final String TF_PROJECT = "/WEB-INF/com.bayer.ipms.view/flows/project-view.xml#project-view";
    private static final String TF_PROJECT_TYPE =
        "/WEB-INF/com.bayer.ipms.view/flows/project-type-view.xml#project-type-view";
    private static final String TF_PROJECT_TYPIFICATION =
        "/WEB-INF/com.bayer.ipms.view/flows/project-typification.xml#project-typification";
    private static final String TF_PROJECT_D1 = "/WEB-INF/com.bayer.ipms.view/flows/project-D1-view.xml#project-d1";
    private static final String PT_DEV = "Dev";
    private static final String PROGRAM_VIEW_IT = "ProgramViewIterator";
    private static final String PROJECT_VIEW_IT = "ProjectViewIterator";
    private static final String SANDBOX_VIEW_IT = "SandboxViewIterator";

    private Key currentProjectRowKey = null;

    private String lastQueryOperation = null;

    private Map<String, Boolean> projectAreaImporting = new HashMap<String, Boolean>();
    private Set<String> refreshableTabs = new HashSet<>();

    public ProgramsBean() {

        init();
    }

    private void init() {
        taskFlowId = TF_PROGRAM;
        projectType = "Dev";
        currentProjectRowKey = null;
        lastQueryOperation = null;

        projectAreaImporting = new HashMap<String, Boolean>();
        refreshableTabs = new HashSet<>();

    }

    private void saveCurrentProjectRowKey() {
        currentProjectRowKey = null;
        DCIteratorBinding it = ViewUtils.getIteratorBinding(PROJECT_VIEW_IT);
        ViewRowImpl currentRow = (ViewRowImpl) it.getCurrentRow();
        if (currentRow != null) {
            byte newRowState = currentRow.getNewRowState();
            if (newRowState != Row.STATUS_INITIALIZED && newRowState != Row.STATUS_NEW) {
                currentProjectRowKey = currentRow.getKey();
            }
        }
    }

    private void restoreProjectSelection() {
        DCIteratorBinding it = ViewUtils.getIteratorBinding(PROJECT_VIEW_IT);
        if (currentProjectRowKey != null) {
            Row[] found = it.getViewObject().findByKey(new Key(currentProjectRowKey.getAttributeValues()), 1);
            if (found != null && found.length == 1) {
                it.setCurrentRowWithKey(currentProjectRowKey.toStringFormat(true));
            } else {
                currentProjectRowKey = null;
            }
        }
    }

    private void setD2PrjProgramCurrRow(DCIteratorBinding it) {

        if (!"RESERVED-PT-D2-PRJ".equals(((ProgramViewRow) it.getCurrentRow()).getCode())) {

            it.setCurrentRowWithKey(it.findRowsByAttributeValue("Code", true, "RESERVED-PT-D2-PRJ")
                                      .getRowAtRangeIndex(0)
                                      .getKey()
                                      .toStringFormat(true));
        }


    }

    private void setSAMDProgramCurrRow(DCIteratorBinding it) {
        if (null != it && null != it.getCurrentRow()) {
            if (!"RESERVED-PT-SAMD".equals(((ProgramViewRow) it.getCurrentRow()).getCode())) {

                it.setCurrentRowWithKey(it.findRowsByAttributeValue("Code", true, "RESERVED-PT-SAMD")
                                          .getRowAtRangeIndex(0)
                                          .getKey()
                                          .toStringFormat(true));
            }

        }
    }

    private void manageRefreshableTabs() {
        for (Map.Entry<String, Boolean> entry : projectAreaImporting.entrySet()) {
            if (entry.getValue()) {
                refreshableTabs.add(UtilitiesBean.projectAreaCodeId.get(entry.getKey()));
                break;
            }
        }
    }

    private void refreshProjectAreaTabNotifiers() {

        refreshableTabs.clear();
        manageRefreshableTabs();
        setProjectAreaImporting();
        manageRefreshableTabs();

        for (String tab : refreshableTabs) {
            ViewUtils.reloadUiComponent(tab);
        }

    }

    public void onProjectTabClick(ActionEvent actionEvent) {

        init();

        SecurityContext sctx = ADFContext.getCurrent().getSecurityContext();

        if (sctx.isUserInRole("ProgramViewDev") || sctx.isUserInRole("ProgramViewAssignedDev")) {
            setVc("Dev");
            taskFlowId = TF_PROJECT_TYPE;
        } else if (sctx.isUserInRole("ProjectViewD1")) {
            setVc("D1");
            taskFlowId = TF_PROJECT_D1;
        } else if (sctx.isUserInRole("ProjectViewD2Prj")) {
            setVc("D2Prj");
            taskFlowId = TF_PROJECT_TYPE;
        } else if (sctx.isUserInRole("ProjectViewSAMD")) {
            setVc("SAMD");
            taskFlowId = TF_PROJECT_TYPE;
        } else
            taskFlowId = TF_PROJECT_TYPE;

        projectAreaImporting.clear();
    }

    private void setVc(String vcName) {


        DCIteratorBinding prgIt =
            (DCIteratorBinding) ViewUtils.runValueEl("#{data.com_bayer_ipms_view_programsPageDef.ProgramViewIterator}");
        //       DCIteratorBinding prgIt = ViewUtils.getIteratorBinding("ProgramViewIterator");
        ProgramView prgVo = (ProgramView) prgIt.getViewObject();
        ProjectView prjVo =
            (ProjectView) ((DCIteratorBinding) ViewUtils.runValueEl("#{data.com_bayer_ipms_view_programsPageDef.ProjectViewIterator}"))
            .getViewObject();
        // ProjectView prjVo =  (ProjectView)ViewUtils.getIteratorBinding("ProjectViewIterator").getViewObject();

        prgVo.getViewCriteriaManager().clearViewCriterias();
        prgVo.setSearchVcName(vcName);
        prgVo.getViewCriteriaManager().setApplyViewCriteriaName(vcName);
        prgVo.executeQuery();

        if ("D2Prj".equals(vcName)) {
            setD2PrjProgramCurrRow(prgIt);
        } else if ("SAMD".equals(vcName)) {
            setSAMDProgramCurrRow(prgIt);
        }

        prjVo.getViewCriteriaManager().clearViewCriterias();
        prjVo.setSearchStatusVar(prgVo.getSearchStatusVar());
        prjVo.getViewCriteriaManager().setApplyViewCriteriaName(vcName);
        prjVo.executeQuery();
    }


    public void tabDisclosure(DisclosureEvent event) {

        this.setModalModeOff(false);

        RichShowDetailItem detItem = ((RichShowDetailItem) event.getComponent());
        ProgramView prgVo = (ProgramView) ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT).getViewObject();
        ProjectView prjVo = (ProjectView) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getViewObject();

        if (detItem.isDisclosed()) {

            refreshProjectAreaTabNotifiers();

            projectType = detItem.getId();

            prgVo.setSearchVcName(projectType);

            prgVo.getViewCriteriaManager().setApplyViewCriteriaName(projectType);
            prgVo.executeQuery();

            if ("D2Prj".equals(projectType)) {
                DCIteratorBinding prgIt = ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT);
                setD2PrjProgramCurrRow(prgIt);

                Map session = ADFContext.getCurrent().getSessionScope();
                session.put("programId", "");
            } else if (projectType.equals("SAMD")) {
                DCIteratorBinding prgIt = ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT);
                setSAMDProgramCurrRow(prgIt);

                Map session = ADFContext.getCurrent().getSessionScope();
                session.put("programId", "");
            } else {
                prgVo.setCurrentRowAtRangeIndex(0);
            }

            prjVo.setSearchStatusVar(prgVo.getSearchStatusVar());
            prjVo.setSearchStatusMnt(prgVo.getSearchStatusMnt());
            prjVo.getViewCriteriaManager().setApplyViewCriteriaName(projectType);
            if ("Unt".equals(projectType)) {
                prjVo.setOrderByClause("code");
            } else {
                prjVo.setOrderByClause("upper(name)");
            }
            prjVo.executeQuery();


        } else {
            if (!"Unt".equals(detItem.getId()) && !"D1".equals(detItem.getId())) {
                ((RichTree) ViewUtils.getUiComponent("tree" + detItem.getId())).getSelectedRowKeys().clear();
            }
        }

        if (prgVo.getCurrentRow() != null &&
            "RESERVED-PT-UNT".equals(((ProgramViewRow) prgVo.getCurrentRow()).getCode())) {
            taskFlowId = TF_PROJECT_TYPIFICATION;
        } else if ("D1".equals(projectType)) {
            taskFlowId = TF_PROJECT_D1;
        } else {
            taskFlowId = TF_PROJECT_TYPE;
        }

    }


    /**
     * Highlights the selected tree nodes and
     * shows the correct task flow in the region,
     * depending on the node type.
     */
    @SuppressWarnings("unchecked")
    public void onTreeSelect(SelectionEvent selectionEvent) {

        if (this.getModalMode()) {
            return;
        }


        if (!selectionEvent.getAddedSet()
                           .iterator()
                           .hasNext()) {
            return;
        }

        Map session = ADFContext.getCurrent().getSessionScope();

        RichTree tree = (RichTree) selectionEvent.getSource();
        JUCtrlHierBinding treeBinding = (JUCtrlHierBinding) ((CollectionModel) tree.getValue()).getWrappedData();

        ViewUtils.runMethodEl("#{bindings." + treeBinding.getName() + ".treeModel.makeCurrent}",
                              new Class[] { SelectionEvent.class }, new Object[] { selectionEvent });

        List<?> keys = (List<?>) selectionEvent.getAddedSet()
                                               .iterator()
                                               .next();
        Key projectKey = (Key) keys.get(keys.size() - 1);

        if ("ProgramView".equals(treeBinding.getName()) && keys.size() == 1) {
            ProgramViewRow prgRow = null;
            for (Row row : ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT)
                                    .getRowSetIterator()
                                    .findByKey(projectKey, 1)) {
                prgRow = (ProgramViewRow) row;
                session.put("programId", prgRow.getId());
                session.put("projectId", "");
            }
            taskFlowId = TF_PROGRAM;
        } else {

            try {
                if (ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                             .getRowSetIterator()
                             .findByKey(projectKey, 1)
                             .length == 0) {
                    logger.warning("promis:programsBean:onTreeSelect:Could not find project row by key. Forcing logout (invalidating session and redirecting to welcome page).");
                    return;
                }

                ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).setCurrentRowWithKey(projectKey.toStringFormat(true));

                ProjectView prjVo = (ProjectView) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getViewObject();
                ProjectViewRow prjRow = (ProjectViewRow) prjVo.findByKey(projectKey, 1)[0];

                session.put("projectId", prjRow.getId());
                session.put("programId", "");

                manageProjectTabRefresh(prjRow.getId());

            } catch (RuntimeException e) {
                //Temporary logging for CUC-396
                ProjectView prjVoDebug = (ProjectView) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getViewObject();
                logger.severe("ProjectViewIterator debug: Row count - " + prjVoDebug.getRowCount() +
                              " SearchStatusVar:" +
                              prjVoDebug.getVariableManager().getVariableValue("SearchStatusVar"));
                throw e;
            }


            saveCurrentProjectRowKey();
            taskFlowId = TF_PROJECT;
        }


        BindingContainer bc = BindingContext.getCurrent().getCurrentBindingsEntry();
        JUCtrlActionBinding actionBnd = (JUCtrlActionBinding) bc.getControlBinding("changeProgramOrProjectProducer");
        ((DCBindingContainer) bc).getEventDispatcher().queueEvent(actionBnd.getEventProducer(), null);


    }


    public TaskFlowId getContentFlowId() {
        return TaskFlowId.parse(taskFlowId);
    }

    public String onRefresh() {

        ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT).executeQuery();
        RichTree treeDev = (RichTree) ViewUtils.getUiComponent("treeDev");
        treeDev.getSelectedRowKeys().clear();
        treeDev.getDisclosedRowKeys().clear();
        ViewUtils.reloadUiComponent("treeDev");
        taskFlowId = TF_PROJECT_TYPE;


        return null;
    }

    public ContextualEventHandler getProjectEventHandler() {
        return new ContextualEventHandler() {
            public void handleEvent(Object payload) {
                ProgramViewRow prg = (ProgramViewRow) ViewUtils.getCurrentRow(PROGRAM_VIEW_IT);
                ProjectViewRow prj = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);
                SandboxViewRow snd = (SandboxViewRow) ViewUtils.getCurrentRow(SANDBOX_VIEW_IT);

                if (prj == null) {
                    taskFlowId = TF_PROGRAM;
                } else {
                    taskFlowId = TF_PROJECT;

                    String action = null;
                    if (payload instanceof Properties) {
                        action = ((Properties) payload).getProperty("action");
                    }

                    if ("D2-PRJ".equals(prj.getAreaCode())) {
                        if ("deleteProject".equals(action) || "moveProject".equals(action)) {
                            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).executeQuery();
                            taskFlowId = TF_PROJECT_TYPE;
                        } else {
                            prj.refresh();
                        }
                        ViewUtils.reloadUiComponent("treeD2Prj");
                    } else if ("SAMD".equals(prj.getAreaCode())) {
                        if ("deleteProject".equals(action) || "moveProject".equals(action)) {
                            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).executeQuery();
                            taskFlowId = TF_PROJECT_TYPE;
                        } else {
                            prj.refresh();
                        }
                        ViewUtils.reloadUiComponent("treeSAMD");
                    }

                    else {
                        if ("deleteProject".equals(action) || "moveProject".equals(action)) {
                            ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT).executeQuery();
                            RichTree treeDev = (RichTree) ViewUtils.getUiComponent("treeDev");
                            treeDev.getSelectedRowKeys().clear();

                            taskFlowId = TF_PROJECT_TYPE;
                        } else if ("deleteSandbox".equals(action)) {
                            ViewUtils.getIteratorBinding(SANDBOX_VIEW_IT).executeQuery();
                            RichTree treeDev = (RichTree) ViewUtils.getUiComponent("treeDev");
                            treeDev.getSelectedRowKeys().clear();
                            snd.refresh();

                        } else {
                            prg.refresh();
                        }
                        ViewUtils.reloadUiComponent("treeDev");
                    }
                }

                refreshProjectAreaTabNotifiers();

            }
        };
    }

    public ContextualEventHandler getProgramEventHandler() {
        return new ContextualEventHandler() {
            public void handleEvent(Object payload) {

                String action = null;
                if (payload instanceof Properties) {
                    action = ((Properties) payload).getProperty("action");
                }

                if ("createProject".equals(action)) {

                    ProgramView prgVo = ((ProgramView) ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT).getViewObject());
                    ProjectView prjVo = ((ProjectView) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getViewObject());

                    ProjectViewRow prjRow = (ProjectViewRow) prjVo.getCurrentRow();
                    ProgramViewRow prgRow = (ProgramViewRow) prgVo.getCurrentRow();


                    prgVo.setSearchStatusVar("inactive");
                    prgVo.setSearchProjectNameVar(null);
                    prgVo.setSearchProjectCodeVar(null);
                    prgVo.setSearchAreaCodeVar(null);
                    prgVo.setSearchIsHprVar(null);
                    prgVo.setSearchIsPortfolioVar(null);
                    prgVo.setSearchSbeCodeVar(null);
                    prgVo.setSearchStudyCodeVar(null);

                    prgVo.executeQuery();

                    ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT)
                        .setCurrentRowWithKey(prgRow.getKey().toStringFormat(true));

                    prjVo.setSearchStatusVar(prgVo.getSearchStatusVar());
                    prjVo.executeQuery();

                    ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                        .setCurrentRowWithKey(prjRow.getKey().toStringFormat(true));

                    if ("PRE-POT".equals(prjRow.getAreaCode()) || "POST-POT".equals(prjRow.getAreaCode())) {
                        RichTree tree = (RichTree) ViewUtils.getUiComponent("treeDev");
                        tree.setSelectedRowKeys(null);
                    }

                    ViewUtils.reloadUiComponent("qDev");
                    ViewUtils.reloadUiComponent("treeDev");


                    taskFlowId = TF_PROJECT;
                } else {
                    if ("deleteProgram".equals(action)) {
                        ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT).executeQuery();
                        taskFlowId = TF_PROJECT_TYPE;
                    } else {
                        ProgramViewRow prg = (ProgramViewRow) ViewUtils.getCurrentRow(PROGRAM_VIEW_IT);
                        prg.refresh();
                    }
                    ViewUtils.reloadUiComponent("treeDev");
                }
            }
        };
    }

    public ContextualEventHandler getProjectTypifyEventHandler() {
        return new ContextualEventHandler() {
            public void handleEvent(Object payload) {
                //  ViewUtils.reloadUiComponent("treeUnt");
            }
        };
    }


    private void filterProjects(String vcName) {

        ProgramView voPrg = (ProgramView) ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT).getViewObject();
        ProjectView voPrj = (ProjectView) ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).getViewObject();

        ViewCriteriaManager vcmPrj = voPrj.getViewCriteriaManager();
        voPrj.setSearchStatusVar(voPrg.getSearchStatusVar());
        voPrj.setSearchStatusMnt(voPrg.getSearchStatusMnt());
        vcmPrj.applyViewCriteria(vcmPrj.getViewCriteria(vcName), false);
        voPrj.executeQuery();
    }

    public void customQueryListener(QueryEvent queryEvent) {

        String vcName = queryEvent.getDescriptor().getName();
        ProgramView prgVo = (ProgramView) ViewUtils.getIteratorBinding("ProgramViewIterator").getViewObject();
        if ("Dev".equals(vcName)) {

            FilterableQueryDescriptor qd = (FilterableQueryDescriptor) queryEvent.getDescriptor();
            List<Criterion> criterionList = qd.getConjunctionCriterion().getCriterionList();

            for (Criterion criterion : criterionList) {

                AttributeCriterion acr = (AttributeCriterion) criterion;
                List<? extends Object> list = acr.getValues();
                StringBuilder strList = null;

                AttributeDescriptor attrDescriptor = ((AttributeCriterion) acr).getAttribute();

                switch (acr.getAttribute().getName()) {

                case "SearchProjectSbeCode":

                    strList = new StringBuilder();
                    for (int i : (int[]) list.get(0)) {
                        if (i != 0) {
                            strList.append(ViewUtils.getLookupIndexCode("StrategicBusinessEntityView", i - 1))
                                .append("|");
                        }
                    }
                    if (strList.length() > 0) {
                        prgVo.setSearchSbeCodeVar(StringUtils.stripEnd(strList.toString(), "|"));
                    } else {
                        prgVo.setSearchSbeCodeVar(null);
                    }
                    break;

                case "SearchProjectTaCode":

                    strList = new StringBuilder();
                    for (int i : (int[]) list.get(0)) {
                        if (i != 0) {
                            strList.append(ViewUtils.getManagementLookupIndexCode("TherapeuticAreaView", i - 1))
                                .append("|");
                        }
                    }
                    if (strList.length() > 0) {
                        prgVo.setSearchProjectTaCodeVar(StringUtils.stripEnd(strList.toString(), "|"));
                    } else {
                        prgVo.setSearchProjectTaCodeVar(null);
                    }
                    break;
                }
            }

            if (!"RESET".equals(lastQueryOperation)) {
                RichQuery qc = (RichQuery) queryEvent.getComponent();
                qc.setDisclosed(false);
                ViewUtils.reloadUiComponent("qDev");
            }
        }

        if ("D2Prj".equals(vcName)) {

            QueryDescriptor qd = (QueryDescriptor) ViewUtils.runValueEl("#{bindings.D2PrjQuery.queryDescriptor}");
            List<Criterion> criterionList = qd.getConjunctionCriterion().getCriterionList();

            for (Criterion criterion : criterionList) {
                AttributeCriterion acr = (AttributeCriterion) criterion;

                List<? extends Object> list = acr.getValues();
                StringBuilder strList = null;

                switch (acr.getAttribute().getName()) {

                case "SearchProjectSbeCode":

                    strList = new StringBuilder();
                    for (int i : (int[]) list.get(0)) {
                        if (i != 0) {
                            strList.append(ViewUtils.getLookupIndexCode("StrategicBusinessEntityView", i - 1))
                                .append("|");
                        }
                    }
                    if (strList.length() > 0) {
                        prgVo.setSearchSbeCodeVar(StringUtils.stripEnd(strList.toString(), "|"));
                    } else {
                        prgVo.setSearchSbeCodeVar(null);
                    }
                    break;

                case "SearchProjectTaCode":

                    strList = new StringBuilder();
                    for (int i : (int[]) list.get(0)) {
                        if (i != 0) {
                            strList.append(ViewUtils.getLookupIndexCode("TherapeuticAreaView", i - 1)).append("|");
                        }
                    }
                    if (strList.length() > 0) {
                        prgVo.setSearchProjectTaCodeVar(StringUtils.stripEnd(strList.toString(), "|"));
                    } else {
                        prgVo.setSearchProjectTaCodeVar(null);
                    }
                    break;
                }

                if ("SearchStatus2".equalsIgnoreCase(acr.getAttribute().getName())) {
                    DCIteratorBinding prgIt = ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT);
                    if (acr.getValues().get(0) != "" &&
                        "deleted"
                        .equals(ViewUtils.getLookupIndexCode("ProjectSearchStatus",
                                                             new Integer(acr.getValues()
                                                                                                            .get(0)
                                                                                                            .toString()) -
                                      1))) {

                        prgIt.setCurrentRowWithKey(new Key(new Object[] { "RBIN" }).toStringFormat(true));
                    } else {
                        setD2PrjProgramCurrRow(prgIt);
                    }
                }
            }
        }
        if ("SAMD".equals(vcName)) {

            QueryDescriptor qd = (QueryDescriptor) ViewUtils.runValueEl("#{bindings.SAMDQuery.queryDescriptor}");
            List<Criterion> criterionList = qd.getConjunctionCriterion().getCriterionList();

            for (Criterion criterion : criterionList) {
                AttributeCriterion acr = (AttributeCriterion) criterion;

                List<? extends Object> list = acr.getValues();
                StringBuilder strList = null;

                if ("SearchStatus2".equalsIgnoreCase(acr.getAttribute().getName())) {
                    DCIteratorBinding prgIt = ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT);
                    if (acr.getValues().get(0) != "" &&
                        "deleted"
                        .equals(ViewUtils.getLookupIndexCode("ProjectSearchStatus",
                                                             new Integer(acr.getValues()
                                                                                                            .get(0)
                                                                                                            .toString()) -
                                      1))) {

                        prgIt.setCurrentRowWithKey(new Key(new Object[] { "RBIN" }).toStringFormat(true));
                    } else {
                        setSAMDProgramCurrRow(prgIt);
                    }
                }
            }
        }
        filterProjects(vcName);

        ViewUtils.runMethodEl("#{bindings." + vcName + "Query.processQuery}", new Class[] { QueryEvent.class },
                              new Object[] { queryEvent });
        ((RichTree) ViewUtils.getUiComponent("tree" + vcName)).getSelectedRowKeys().clear();

        lastQueryOperation = null;

        taskFlowId = TF_PROJECT_TYPE;
    }


    public void customQueryOperation(QueryOperationEvent qoe) {

        lastQueryOperation = qoe.getOperation().name();
        ViewUtils.runMethodEl("#{bindings." + qoe.getDescriptor().getName() + "Query.processQueryOperation}",
                              new Class[] { QueryOperationEvent.class }, new Object[] { qoe });
    }


    public void onPopupCancel(PopupCanceledEvent event) {
        ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT)
                 .getDataControl()
                 .rollbackTransaction();
    }

    public void onProjectCreatePopupCancel(PopupCanceledEvent event) {
        ViewUtils.getIteratorBinding(PROJECT_VIEW_IT)
                 .getDataControl()
                 .rollbackTransaction();
        restoreProjectSelection();
    }

    public void onPopupSubmit(DialogEvent event) {
        ViewUtils.getIteratorBinding(PROGRAM_VIEW_IT)
                 .getDataControl()
                 .commitTransaction();
    }

    public void onPopupFetch(PopupFetchEvent event) {
        ViewUtils.getOperationBinding("ProgramCreate").execute();
    }

    public void onCreate(DialogEvent event) {

        UtilitiesBean.setBaCode("ProgramCreate");

        onPopupSubmit(event);

        UtilitiesBean.setBaCode("UnlockSendReceive");
        ((ProgramViewRow) ViewUtils.getCurrentRow(PROGRAM_VIEW_IT)).send();

        UtilitiesBean.setBaCode(null);

        ViewUtils.reloadUiComponent("treeDev");

        taskFlowId = TF_PROGRAM;
    }

    public String getProjectType() {
        return projectType;
    }

    public void onProjectCreate(DialogEvent event) {

        ProgramViewRow proRow = (ProgramViewRow) ViewUtils.getCurrentRow(PROGRAM_VIEW_IT);
        ProjectViewRow prjRow = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);

        if (proRow.getCode().equals("RESERVED-PT-D2-PRJ")) {
            prjRow.setPhaseCode("14"); // Lead Generation PROMIS-531
            prjRow.setCategoryCode("LO");
            UtilitiesBean.setBaCode("ProjectCreate");
            onPopupSubmit(event);
            UtilitiesBean.setBaCode(null);
            UtilitiesBean.setBaCode("UnlockSendReceive");
            prjRow.send();
            UtilitiesBean.setBaCode(null);

            QueryDescriptor qd = (QueryDescriptor) ViewUtils.runValueEl("#{bindings.D2PrjQuery.queryDescriptor}");
            //access the list of all search fields
            List<Criterion> criterionList = qd.getConjunctionCriterion().getCriterionList();

            for (Criterion criterion : criterionList) {
                AttributeCriterion acr = (AttributeCriterion) criterion;
                List values = acr.getValues();
                if ("SearchStatus".equalsIgnoreCase(acr.getAttribute().getName())) {
                    values.set(0, new Integer(ViewUtils.getLookupCodeIndex("ProjectSearchStatus", "inactive") + 1));

                } else {
                    values.set(0, null);
                }
            }

            ViewUtils.reloadUiComponent("qD2Prj");
            ViewUtils.runMethodEl("#{bindings.D2PrjQuery.processQuery}", new Class[] { QueryEvent.class },
                                  new Object[] { new QueryEvent((RichQuery) ViewUtils.getUiComponent("qD2Prj"), qd) });
            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).setCurrentRowWithKey(prjRow.getKey().toStringFormat(true));
            ViewUtils.reloadUiComponent("treeD2Prj");
            saveCurrentProjectRowKey();
            ((RichTree) ViewUtils.getUiComponent("treeD2Prj")).getSelectedRowKeys().clear();
            taskFlowId = TF_PROJECT;
        } else if (proRow.getCode().equals("RESERVED-PT-SAMD")) {
            prjRow.setPhaseCode("SAMD.1");
            prjRow.setAreaCode("SAMD");
            prjRow.setIsActive(true);
            //prjRow.setAttribute("ProjectCode", "SAMD-");
            UtilitiesBean.setBaCode("ProjectCreate");
            onPopupSubmit(event);
            UtilitiesBean.setBaCode(null);
            UtilitiesBean.setBaCode("UnlockSendReceive");
            prjRow.send();
            UtilitiesBean.setBaCode(null);
            QueryDescriptor qdSAMD = (QueryDescriptor) ViewUtils.runValueEl("#{bindings.SAMDQuery.queryDescriptor}");
            List<Criterion> criterionListSAMD = qdSAMD.getConjunctionCriterion().getCriterionList();

            for (Criterion criterion : criterionListSAMD) {
                AttributeCriterion acr = (AttributeCriterion) criterion;
                List values = acr.getValues();
                if ("SearchStatus".equalsIgnoreCase(acr.getAttribute().getName())) {
                    values.set(0, new Integer(ViewUtils.getLookupCodeIndex("ProjectSearchStatus", "active") + 1));

                } else {
                    values.set(0, null);
                }
            }

            ViewUtils.reloadUiComponent("qSAMD");
            ViewUtils.runMethodEl("#{bindings.SAMDQuery.processQuery}", new Class[] { QueryEvent.class },
                                  new Object[] { new QueryEvent((RichQuery) ViewUtils.getUiComponent("qSAMD"),
                                                                qdSAMD) });
            ViewUtils.getIteratorBinding(PROJECT_VIEW_IT).setCurrentRowWithKey(prjRow.getKey().toStringFormat(true));
            ViewUtils.reloadUiComponent("treeSAMD");
            saveCurrentProjectRowKey();
            ((RichTree) ViewUtils.getUiComponent("treeSAMD")).getSelectedRowKeys().clear();
            taskFlowId = TF_PROJECT;
        }
    }

    public void onProjectCreatePopupFetch(PopupFetchEvent event) {

        ViewUtils.getOperationBinding("ProjectCreate").execute();

        RichSelectOneChoice socArea = (RichSelectOneChoice) ViewUtils.getUiComponent("socArea");
        if (socArea != null && socArea.getValue() == null) {
            socArea.setValue(new Integer(0));
        }
        ProjectViewRow prjRow = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_VIEW_IT);

        prjRow.setStateCode("0");
       // prjRow.setPriorityCode("2"); //PROMIS-569
        prjRow.setPriorityCode("n.a."); //PROMIS-602
        
    }

    private void manageProjectTabRefresh(String prjId) {

        Map session = ADFContext.getCurrent().getSessionScope();
        String activeTabId = (String) session.get("activeTabId");

        if ("sdiTpp".equals(activeTabId) || "sdiTppCurrent".equals(activeTabId)) {
            DCIteratorBinding tppCIt =
                (DCIteratorBinding) ViewUtils.runValueEl("#{data.com_bayer_ipms_view_project_viewPageDef.TargetProductProfileCurrentViewIterator}");
            TargetProductProfileView tppVo = (TargetProductProfileView) tppCIt.getViewObject();
            tppVo.setProjectIdVar(prjId);
            tppVo.getViewCriteriaManager().setApplyViewCriteriaName("ParticularProject", true);
            tppCIt.executeQuery();
        }

        if ("sdiTppVersions".equals(activeTabId)) {
            DCIteratorBinding tppVIt =
                (DCIteratorBinding) ViewUtils.runValueEl("#{data.com_bayer_ipms_view_project_viewPageDef.TargetProductProfileVersionsViewIterator}");
            TargetProductProfileView tppVo = (TargetProductProfileView) tppVIt.getViewObject();
            tppVo.setProjectIdVar(prjId);
            tppVo.getViewCriteriaManager().setApplyViewCriteriaName("ParticularProject", true);
            tppVIt.executeQuery();
        }
    }

    private void setProjectAreaImporting() {

        projectAreaImporting.clear();
        ProjectAreaView paVo =
            (ProjectAreaView) ViewUtils.getIteratorBinding("ProjectAreaViewIterator").getViewObject();

        paVo.executeQuery();
        RowSetIterator rsi = paVo.createRowSetIterator(null);
        while (rsi.hasNext()) {
            ProjectAreaViewRow paRow = (ProjectAreaViewRow) rsi.next();
            projectAreaImporting.put(paRow.getCode(), "YES".equals(paRow.getIsRunningImport()) ? true : false);
        }
        rsi.closeRowSetIterator();
    }

    public Map<String, Boolean> getAreaCodeImporting() {
        if (projectAreaImporting.size() == 0) {
            setProjectAreaImporting();
        }
        return projectAreaImporting;
    }

    public void validateSamdProjectID(FacesContext facesContext, UIComponent uIComponent, Object object) {
        if (object.toString().startsWith("SAMD-")) {

        } else {
            throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                                                          "Project Id must start with SAMD- prefix!", null));
        }

    }

    /*
     * Method that displays left Dev programs tab for Dev projects created from Samd tab
     */
    public void openDisclosureRuntime(String prjtype) {
        if (prjtype == "Dev") {
            refreshPage();
        }
    }

    protected void refreshPage() {
        FacesContext fctx = FacesContext.getCurrentInstance();
        String page = fctx.getViewRoot().getViewId();
        ViewHandler viewH = fctx.getApplication().getViewHandler();
        UIViewRoot UIV = viewH.createView(fctx, page);
        UIV.setViewId(page);
        fctx.setViewRoot(UIV);
    }
}
