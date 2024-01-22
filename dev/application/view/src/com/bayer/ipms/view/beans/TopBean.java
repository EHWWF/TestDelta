package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.services.ProgramAppModuleImpl;
import com.bayer.ipms.model.views.ProgramTopVersionViewImpl;
import com.bayer.ipms.model.views.ProgramTopVersionViewRowImpl;
import com.bayer.ipms.model.views.common.ProgramTopValuesViewRow;
import com.bayer.ipms.model.views.common.ProgramTopVersionSubCategoryViewRow;
import com.bayer.ipms.model.views.common.ProgramTopVersionViewRow;
import com.bayer.ipms.view.utils.ViewUtils;

import java.sql.Date;

import java.util.HashMap;
import java.util.Map;

import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.component.rich.data.RichTreeTable;
import oracle.adf.view.rich.component.rich.nav.RichButton;
import oracle.adf.view.rich.context.AdfFacesContext;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;

import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.RowIterator;
import oracle.jbo.RowSet;
import oracle.jbo.server.AttributeListImpl;
import oracle.jbo.uicli.binding.JUCtrlHierBinding;
import oracle.jbo.uicli.binding.JUCtrlHierNodeBinding;

import org.apache.myfaces.trinidad.event.SelectionEvent;
import org.apache.myfaces.trinidad.event.SortEvent;
import org.apache.myfaces.trinidad.model.CollectionModel;
import org.apache.myfaces.trinidad.render.ExtendedRenderKitService;
import org.apache.myfaces.trinidad.util.Service;


public class TopBean extends ProgramViewBean {

    private static final String TOP_CURRENT_VIEW_IT = "ProgramTopCurrentViewIterator";
    private static final String TOP_VERSION_VIEW_IT = "ProgramTopVersionViewIterator";
    public static final String TOP_VERSION_CAT_VIEW_IT = "ProgramTopVersionCategoryViewIterator";
    protected String topVersionName;
    protected Date topVersionAppDate;
    protected String topVersionDescription;


    public TopBean() {
        super();
    }


    public void onCommit(ActionEvent actionEvent) {
        
        getDataControl(TOP_CURRENT_VIEW_IT).commitTransaction();
        
        if(AdfFacesContext.getCurrentInstance().getPageFlowScope().get("mode") != null) {
               return ;
        }
        
        this.editable = null;

        refreshCurrent();
        
        ProgramTopVersionViewRow currTopVersionRow =
            (ProgramTopVersionViewRow) ViewUtils.getCurrentRow(TOP_CURRENT_VIEW_IT);
        currTopVersionRow.addMissingSub();
        
        ViewUtils.reloadUiComponent("content", "tools");
        
        //ProgramViewBean programViewBean = (ProgramViewBean)AdfFacesContext.getCurrentInstance().getPageFlowScope().get("programViewBean");
        //if(programViewBean != null)
        //    programViewBean.expandProgramTopTree(null);
    }

    public void onPopupSubmit(DialogEvent event) {
        getDataControl(TOP_CURRENT_VIEW_IT).commitTransaction();
    }


    public void onPopupCancel(PopupCanceledEvent event) {
        getDataControl(TOP_CURRENT_VIEW_IT).rollbackTransaction();
    }

    public void onRollback(ActionEvent actionEvent) {

        getDataControl(TOP_CURRENT_VIEW_IT).rollbackTransaction();
        this.editable = null;
        if(AdfFacesContext.getCurrentInstance().getPageFlowScope().get("mode") != null) {
               return ;
        }
        ViewUtils.reloadUiComponent("content", "tools");
        

    }

    public void setTopVersionName(String topVersionName) {
        this.topVersionName = topVersionName;
    }

    public String getTopVersionName() {
        return topVersionName;
    }

    public void setTopVersionAppDate(Date topVersionAppDate) {
        this.topVersionAppDate = topVersionAppDate;
    }

    public Date getTopVersionAppDate() {
        return topVersionAppDate;
    }

    public void setTopVersionDescription(String topVersionDescription) {
        this.topVersionDescription = topVersionDescription;
    }

    public String getTopVersionDescription() {
        return topVersionDescription;
    }

    public void refreshVersions() {
        ViewUtils.getIteratorBinding(TOP_VERSION_VIEW_IT).executeQuery();
    }

    public void refreshCurrent() {
        DCIteratorBinding dcItBinding = ViewUtils.getIteratorBinding(TOP_VERSION_CAT_VIEW_IT);
        if (dcItBinding != null) {
            dcItBinding.executeQuery();
            ViewUtils.reloadUiComponent("toptab");
        }
    }


    public void onTopvAdd(ActionEvent actionEvent) {

        Map<String, Object> topRowCont = getTopvRowCont();

        ProgramTopVersionSubCategoryViewRow parentRow =
            (ProgramTopVersionSubCategoryViewRow) ((RowIterator) topRowCont.get("ri")).findByKey((Key) topRowCont.get("key"),
                                                                                          1)[0];
        RowSet children = (RowSet) parentRow.getProgramTopValuesView();
        ProgramTopValuesViewRow lastRow = (ProgramTopValuesViewRow) children.last();
        int lastRowInd = children.getRangeIndexOf(lastRow);
        ProgramTopValuesViewRow topvRow = (ProgramTopValuesViewRow) children.createRow();
        children.insertRowAtRangeIndex(lastRowInd + 1, topvRow);

    }

    private Map<String, Object> getTopvRowCont() {
        RichTreeTable topTab = (RichTreeTable) ViewUtils.getUiComponent("toptab");

        if (topTab.getSelectedRowKeys() != null) {
            for (Object key : topTab.getSelectedRowKeys()) {
                topTab.setRowKey(key);

                break;
            }

            if (topTab.getRowData() == null) {
                return null;
            }

            RowIterator topRI = ((JUCtrlHierNodeBinding) topTab.getRowData()).getRowIterator();
            Key selectedKey = ((JUCtrlHierNodeBinding) topTab.getRowData()).getRowKey();

            Map<String, Object> res = new HashMap<String, Object>();
            res.put("ri", topRI);
            res.put("key", selectedKey);
            return res;
        }
        return null;
    }

    public void onTopvRemove(ActionEvent actionEvent) {

        Map<String, Object> topRowCont = getTopvRowCont();

        Row[] rows = ((RowIterator) topRowCont.get("ri")).findByKey((Key) topRowCont.get("key"), 1);
        rows[0].remove();

        toggleTopvBtnEnablement();

    }


    public void onTopVersionRemove(DialogEvent event) {

        ViewUtils.runMethodEl("#{bindings.DeleteTopVersion.execute}");
        getDataControl(TOP_VERSION_VIEW_IT).commitTransaction();
        ViewUtils.reloadUiComponent("pbTopVersionData");

    }

    public void onTopVersionCopy(DialogEvent event) {

        ProgramTopVersionViewRow topRow =
            (ProgramTopVersionViewRow) ViewUtils.getCurrentRow(TOP_VERSION_VIEW_IT);

        topRow.copyTopVersionToCurrent();
        ViewUtils.getIteratorBinding(TOP_CURRENT_VIEW_IT).executeQuery();
        refreshCurrent();
    }


    /**
     * Highlights the selected table row and expands tree nodes fro selected TOP version
     * selectionListener="#{bindings.ProgramTopPreviousView.collectionModel.makeCurrent}"
     */
    public void onTopVersionSelect(SelectionEvent selectionEvent) {

        ViewUtils.runMethodEl("#{bindings.ProgramTopVersionView.collectionModel.makeCurrent}",
                              new Class[] { SelectionEvent.class }, new Object[] { selectionEvent });

        ViewUtils.getIteratorBinding("ProgramTopNonIndPreviousCategoryViewIterator").executeQuery();
        ViewUtils.getIteratorBinding("ProgramTopPreviousCategoryViewIterator").executeQuery();
        ViewUtils.discloseAllTreeTableNodes("toptab");
        ViewUtils.discloseAllTreeTableNodes("tblTopVersionValues");
        ViewUtils.discloseAllTreeTableNodes("topNonIndVersiontab");
    }


    public void onTopVersionSort(SortEvent sortEvent) {
        ViewUtils.discloseAllTreeTableNodes("toptab");
        ViewUtils.discloseAllTreeTableNodes("topNonIndtab");
        ViewUtils.discloseAllTreeTableNodes("tblTopVersionValues");
        ViewUtils.discloseAllTreeTableNodes("topNonIndVersiontab");
    }


    private void toggleTopvBtnEnablement() {

        Map<String, Object> topRowCont = getTopvRowCont();

        RichButton topvAddBtn = (RichButton) ViewUtils.getUiComponent("topvadd");
        RichButton topvRemoveBtn = (RichButton) ViewUtils.getUiComponent("topvremove");

        if (topRowCont != null) {
            Row[] rows = ((RowIterator) topRowCont.get("ri")).findByKey((Key) topRowCont.get("key"), 1);


            if (rows[0].getStructureDef().getDefFullName().equals("com.bayer.ipms.model.views.ProgramTopVersionSubCategoryView")) {

                ProgramTopVersionSubCategoryViewRow topSubcRow = (ProgramTopVersionSubCategoryViewRow) rows[0];

                if (topSubcRow.getIsActive()) {
                    topvAddBtn.setDisabled(false);
                } else {
                    topvAddBtn.setDisabled(true);
                }

            } else {
                topvAddBtn.setDisabled(true);

            }

            if (rows[0].getStructureDef().getDefFullName().equals("com.bayer.ipms.model.views.ProgramTopValuesView")) {
                topvRemoveBtn.setDisabled(false);
            } else {
                topvRemoveBtn.setDisabled(true);
            }

        } else {
            topvAddBtn.setDisabled(true);
            topvRemoveBtn.setDisabled(true);
        }

        ViewUtils.reloadUiComponent("topvadd", "topvremove");
    }


    private void toggleTopNonIndvBtnEnablement() {

        Map<String, Object> topRowCont = getTopvRowCont();

        RichButton topvAddBtn = (RichButton) ViewUtils.getUiComponent("topnonindvadd");
        RichButton topvRemoveBtn = (RichButton) ViewUtils.getUiComponent("topnonindvremove");

        if (topRowCont != null) {
            Row[] rows = ((RowIterator) topRowCont.get("ri")).findByKey((Key) topRowCont.get("key"), 1);


            if (rows[0].getStructureDef().getDefFullName().equals("com.bayer.ipms.model.views.ProgramTopVersionSubCategoryView")) {

                ProgramTopVersionSubCategoryViewRow topSubcRow = (ProgramTopVersionSubCategoryViewRow) rows[0];

                if (topSubcRow.getIsActive()) {
                    topvAddBtn.setDisabled(false);
                } else {
                    topvAddBtn.setDisabled(true);
                }

            } else {
                topvAddBtn.setDisabled(true);

            }

            if (rows[0].getStructureDef().getDefFullName().equals("com.bayer.ipms.model.views.ProgramTopValuesView")) {
                topvRemoveBtn.setDisabled(false);
            } else {
                topvRemoveBtn.setDisabled(true);
            }

        } else {
            topvAddBtn.setDisabled(true);
            topvRemoveBtn.setDisabled(true);
        }

        ViewUtils.reloadUiComponent("topnonindvadd", "topnonindvremove");
    }

    public void onTopCatTreeSelect(SelectionEvent selectionEvent) {

        if (!selectionEvent.getAddedSet().iterator().hasNext()) {
            return;
        }

        RichTreeTable tree = (RichTreeTable) selectionEvent.getSource();
        JUCtrlHierBinding treeBinding = (JUCtrlHierBinding) ((CollectionModel) tree.getValue()).getWrappedData();

        ViewUtils.runMethodEl("#{bindings." + treeBinding.getName() + ".treeModel.makeCurrent}",
                              new Class[] { SelectionEvent.class }, new Object[] { selectionEvent });

        //toggleTopvBtnEnablement();

    }

    public void onTopNonIndCatTreeSelect(SelectionEvent selectionEvent) {
        
        if (!selectionEvent.getAddedSet().iterator().hasNext()) {
            return;
        }

        RichTreeTable tree = (RichTreeTable) selectionEvent.getSource();
        JUCtrlHierBinding treeBinding = (JUCtrlHierBinding) ((CollectionModel) tree.getValue()).getWrappedData();

        ViewUtils.runMethodEl("#{bindings." + treeBinding.getName() + ".treeModel.makeCurrent}",
                              new Class[] { SelectionEvent.class }, new Object[] { selectionEvent });

        //toggleTopNonIndvBtnEnablement();
    }

    public void onCreateTopVersionPopupFetch(PopupFetchEvent event) {
        ProgramTopVersionViewRow topCurrentRow =
            (ProgramTopVersionViewRow) ViewUtils.getCurrentRow(TOP_CURRENT_VIEW_IT);

        this.setTopVersionName(topCurrentRow.getName());
        this.setTopVersionAppDate(topCurrentRow.getApprovalDate());
        this.setTopVersionDescription(topCurrentRow.getDescription());

    }

    public void onCreateTopVersionPopupCancel(PopupCanceledEvent event) {
        onPopupCancel(event);
    }

    public void onCreateTopVersion(DialogEvent event) {
        ProgramTopVersionViewRow currTopVersionRow =
            (ProgramTopVersionViewRow) ViewUtils.getCurrentRow(TOP_CURRENT_VIEW_IT);
        UtilitiesBean.setBaCode("TOPEdit");
        currTopVersionRow.createTopVersion(this.getTopVersionName(), this.getTopVersionAppDate(),
                                           this.getTopVersionDescription());
        UtilitiesBean.setBaCode(null);
        refreshVersions();
    }

    private CollectionModel getTopValuesCollectionModel(String ttName) {
        RichTreeTable richTreeTable = (RichTreeTable) ViewUtils.getUiComponent(ttName);
        return (CollectionModel) richTreeTable.getValue();
    }

    public void onCurrentExportToPDF(ActionEvent action) {
        
        String projectId = (String) AdfFacesContext.getCurrentInstance().getPageFlowScope().get("projectId");
        String programId = (String) AdfFacesContext.getCurrentInstance().getPageFlowScope().get("programId");
        
        ProgramTopVersionViewImpl vo = (ProgramTopVersionViewImpl)ViewUtils.getIteratorBinding(TOP_CURRENT_VIEW_IT).getViewObject();
        String url =  vo.retrieveExportURL(projectId, programId, "");
        onWindowOpen(url);
    }

    public void onVersionExportToPDF(ActionEvent action) {
/*
        ProgramTopVersionViewRow topVersionRow =
            (ProgramTopVersionViewRow) ViewUtils.getCurrentRow(TOP_VERSIONS_VIEW_IT);

        ProjectViewRow prjtRow = (ProjectViewRow) ViewUtils.getCurrentRow("ProjectViewIterator");

        String confLink =
            (String) ViewUtils.runValueEl("#{bindings.ConfigurationViewIterator.viewObject.values['TPP-EXPURL']}");

        String newLink =
            confLink.replace("#ProjectId#", prjtRow.getCode()).replace("#Version#", topVersionRow.getVersion());
        onWindowOpen(newLink);*/
    }


    public void onWindowOpen(String url) {
        FacesContext faces = FacesContext.getCurrentInstance();

        String script = "window.open('" + url + "')";
        ExtendedRenderKitService service =
            Service.getRenderKitService(FacesContext.getCurrentInstance(), ExtendedRenderKitService.class);
        service.addScript(FacesContext.getCurrentInstance(), script);
    }

    public void onTopAdd() {

        System.err.println("onTopAdd start.....");
        
        ProgramTopVersionViewImpl vo = (ProgramTopVersionViewImpl)ViewUtils.getIteratorBinding(TOP_CURRENT_VIEW_IT).getViewObject();
        AttributeListImpl attributeList = new AttributeListImpl();
        //prevent PK from being null 
        attributeList.setAttribute("Id", new java.math.BigDecimal(- System.currentTimeMillis()));
        attributeList.setAttribute("ProgramId", (String) ViewUtils.runValueEl("#{bindings.Id.inputValue}"));
        
        String projectType = (String)AdfFacesContext.getCurrentInstance().getPageFlowScope().get("projectType");
        String projectId = null;
        if("D2Prj".equals(projectType)) {
            projectId = (String)AdfFacesContext.getCurrentInstance().getPageFlowScope().get("projectId");
            attributeList.setAttribute("ProjectId", projectId);
        }
        
        ProgramTopVersionViewRowImpl newRow = (ProgramTopVersionViewRowImpl) vo.createAndInitRow(attributeList);
        vo.insertRow(newRow);
        
        ProgramAppModuleImpl am = (ProgramAppModuleImpl) vo.getApplicationModule();
        Row programRow = am.getProgramView().getCurrentRow();
        System.err.println("onTopAdd end....." );
    }
    
    
    
    public void   initScreen() {
        String projectType = (String)AdfFacesContext.getCurrentInstance().getPageFlowScope().get("projectType");
        String projectId = null;
        if("D2Prj".equals(projectType)) {
            projectId = (String)AdfFacesContext.getCurrentInstance().getPageFlowScope().get("projectId");
        }
        
        ProgramTopVersionViewImpl vo = (ProgramTopVersionViewImpl)ViewUtils.getIteratorBinding("ProgramTopCurrentViewIterator").getViewObject();
        ProgramTopVersionViewImpl vo2 = (ProgramTopVersionViewImpl)ViewUtils.getIteratorBinding("ProgramTopPreviousViewIterator").getViewObject();
        vo.setProjectIdBindVar(projectId);
        vo2.setProjectIdBindVar(projectId); 
        vo.executeQuery();
        vo2.executeQuery();
        
    }
    
    public String afterCommit() {
        return null;
    }
    
  
                           
}