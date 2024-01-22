package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.model.views.common.TargetProductProfileViewRow;
import com.bayer.ipms.model.views.common.TppProfileSubcategoryViewRow;
import com.bayer.ipms.model.views.common.TppValuesViewRow;
import com.bayer.ipms.view.utils.U;
import com.bayer.ipms.view.utils.ViewUtils;

import java.sql.Date;

import java.util.HashMap;
import java.util.Map;

import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import oracle.adf.view.rich.component.rich.data.RichTable;
import oracle.adf.view.rich.component.rich.data.RichTreeTable;
import oracle.adf.view.rich.component.rich.nav.RichButton;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;

import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.RowIterator;
import oracle.jbo.RowSet;
import oracle.jbo.uicli.binding.JUCtrlHierBinding;
import oracle.jbo.uicli.binding.JUCtrlHierNodeBinding;

import org.apache.myfaces.trinidad.event.SelectionEvent;
import org.apache.myfaces.trinidad.event.SortEvent;
import org.apache.myfaces.trinidad.model.CollectionModel;
import org.apache.myfaces.trinidad.model.RowKeySetImpl;
import org.apache.myfaces.trinidad.render.ExtendedRenderKitService;
import org.apache.myfaces.trinidad.util.Service;


public class TppBean extends ProjectViewBean {

    private static final String TPP_CURRENT_VIEW_IT = "TargetProductProfileCurrentViewIterator";
    private static final String TPP_VERSIONS_VIEW_IT = "TargetProductProfileVersionsViewIterator";
    private static final String TPP_PCAT_VIEW_IT = "TppProfileCategoryViewIterator";
    protected String tppVersionName;
    protected Date tppVersionAppDate;
    protected String tppVersionDescription;


    public TppBean() {
        super();
    }


    public void onCommit(ActionEvent actionEvent) {
        getDataControl(TPP_CURRENT_VIEW_IT).commitTransaction();
        this.editable = null;

        ViewUtils.reloadUiComponent("content", "tools");
    }

    public void onPopupSubmit(DialogEvent event) {
        getDataControl(TPP_CURRENT_VIEW_IT).commitTransaction();
    }


    public void onPopupCancel(PopupCanceledEvent event) {
        getDataControl(TPP_CURRENT_VIEW_IT).rollbackTransaction();
    }

    public void onRollback(ActionEvent actionEvent) {

        getDataControl(TPP_CURRENT_VIEW_IT).rollbackTransaction();
        this.editable = null;
        ViewUtils.reloadUiComponent("content", "tools");
    }

    public void setTppVersionName(String tppVersionName) {
        this.tppVersionName = tppVersionName;
    }

    public String getTppVersionName() {
        return tppVersionName;
    }

    public void setTppVersionAppDate(Date tppVersionAppDate) {
        this.tppVersionAppDate = tppVersionAppDate;
    }

    public Date getTppVersionAppDate() {
        return tppVersionAppDate;
    }

    public void setTppVersionDescription(String tppVersionDescription) {
        this.tppVersionDescription = tppVersionDescription;
    }

    public String getTppVersionDescription() {
        return tppVersionDescription;
    }

    public void refreshVersions() {
        ViewUtils.getIteratorBinding(TPP_VERSIONS_VIEW_IT).executeQuery();
    }

    public void refreshCurrent() {
        ViewUtils.getIteratorBinding(TPP_PCAT_VIEW_IT).executeQuery();
        ViewUtils.reloadUiComponent("tpptab");
    }


    public void onTppvAdd(ActionEvent actionEvent) {

        Map<String, Object> tppRowCont = getTppvRowCont();

        TppProfileSubcategoryViewRow parentRow =
            (TppProfileSubcategoryViewRow) ((RowIterator) tppRowCont.get("ri")).findByKey((Key) tppRowCont.get("key"),
                                                                                          1)[0];
        RowSet children = (RowSet) parentRow.getTppValuesView();
        TppValuesViewRow lastRow = (TppValuesViewRow) children.last();
        int lastRowInd = children.getRangeIndexOf(lastRow);
        TppValuesViewRow tppvRow = (TppValuesViewRow) children.createRow();
        children.insertRowAtRangeIndex(lastRowInd + 1, tppvRow);

    }

    private Map<String, Object> getTppvRowCont() {
        RichTreeTable tppTab = (RichTreeTable) ViewUtils.getUiComponent("tpptab");

        if (tppTab.getSelectedRowKeys() != null) {
            for (Object key : tppTab.getSelectedRowKeys()) {
                tppTab.setRowKey(key);

                break;
            }

            if (tppTab.getRowData() == null) {
                return null;
            }

            RowIterator tppRI = ((JUCtrlHierNodeBinding) tppTab.getRowData()).getRowIterator();
            Key selectedKey = ((JUCtrlHierNodeBinding) tppTab.getRowData()).getRowKey();

            Map<String, Object> res = new HashMap<String, Object>();
            res.put("ri", tppRI);
            res.put("key", selectedKey);
            return res;
        }
        return null;
    }

    public void onTppvRemove(ActionEvent actionEvent) {

        Map<String, Object> tppRowCont = getTppvRowCont();

        Row[] rows = ((RowIterator) tppRowCont.get("ri")).findByKey((Key) tppRowCont.get("key"), 1);
        rows[0].remove();

        toggleTppvBtnEnablement();

    }


    public void onTppVersionRemove(DialogEvent event) {

        ViewUtils.runMethodEl("#{bindings.DeleteTppVersion.execute}");
        getDataControl(TPP_CURRENT_VIEW_IT).commitTransaction();
        ViewUtils.reloadUiComponent("pbTppVersionData");

    }

    public void onTppVersionCopy(DialogEvent event) {

        TargetProductProfileViewRow tppRow =
            (TargetProductProfileViewRow) ViewUtils.getCurrentRow(TPP_VERSIONS_VIEW_IT);

        tppRow.copyTppVersionToCurrent();
        ViewUtils.getIteratorBinding(TPP_CURRENT_VIEW_IT).executeQuery();
    }


    /**
     * Highlights the selected table row and expands tree nodes fro selected TPP version
     * selectionListener="#{bindings.TargetProductProfileVersionsView.collectionModel.makeCurrent}"
     */
    public void onTppVersionSelect(SelectionEvent selectionEvent) {

        ViewUtils.runMethodEl("#{bindings.TargetProductProfileVersionsView.collectionModel.makeCurrent}",
                              new Class[] { SelectionEvent.class }, new Object[] { selectionEvent });

        ViewUtils.discloseAllTreeTableNodes("tblTppVersionValues");
    }


    public void onTppVersionSort(SortEvent sortEvent) {
        ViewUtils.discloseAllTreeTableNodes("tblTppVersionValues");
    }


    private void toggleTppvBtnEnablement() {

        Map<String, Object> tppRowCont = getTppvRowCont();

        RichButton tppvAddBtn = (RichButton) ViewUtils.getUiComponent("tppvadd");
        RichButton tppvRemoveBtn = (RichButton) ViewUtils.getUiComponent("tppvremove");

        if (tppRowCont != null) {
            Row[] rows = ((RowIterator) tppRowCont.get("ri")).findByKey((Key) tppRowCont.get("key"), 1);


            if (rows[0].getStructureDef().getDefFullName().equals("com.bayer.ipms.model.views.TppProfileSubcategoryView")) {

                TppProfileSubcategoryViewRow tppSubcRow = (TppProfileSubcategoryViewRow) rows[0];

                if (tppSubcRow.getIsActive()) {
                    tppvAddBtn.setDisabled(false);
                } else {
                    tppvAddBtn.setDisabled(true);
                }


            } else {
                tppvAddBtn.setDisabled(true);

            }

            if (rows[0].getStructureDef().getDefFullName().equals("com.bayer.ipms.model.views.TppValuesView")) {
                tppvRemoveBtn.setDisabled(false);
            } else {
                tppvRemoveBtn.setDisabled(true);
            }

        } else {
            tppvAddBtn.setDisabled(true);
            tppvRemoveBtn.setDisabled(true);
        }

        ViewUtils.reloadUiComponent("tppvadd", "tppvremove");
    }


    public void onTppCatTreeSelect(SelectionEvent selectionEvent) {

        if (!selectionEvent.getAddedSet().iterator().hasNext()) {
            return;
        }

        RichTreeTable tree = (RichTreeTable) selectionEvent.getSource();
        JUCtrlHierBinding treeBinding = (JUCtrlHierBinding) ((CollectionModel) tree.getValue()).getWrappedData();

        ViewUtils.runMethodEl("#{bindings." + treeBinding.getName() + ".treeModel.makeCurrent}",
                              new Class[] { SelectionEvent.class }, new Object[] { selectionEvent });

        toggleTppvBtnEnablement();

    }

    public void onCreateTppVersionPopupFetch(PopupFetchEvent event) {
        TargetProductProfileViewRow tppCurrentRow =
            (TargetProductProfileViewRow) ViewUtils.getCurrentRow(TPP_CURRENT_VIEW_IT);

        this.setTppVersionName(tppCurrentRow.getName());
        this.setTppVersionAppDate(tppCurrentRow.getApprovalDate());
        this.setTppVersionDescription(tppCurrentRow.getDescription());

    }

    public void onCreateTppVersionPopupCancel(PopupCanceledEvent event) {
        onPopupCancel(event);
    }

    public void onCreateTppVersion(DialogEvent event) {
        TargetProductProfileViewRow currTppVersionRow =
            (TargetProductProfileViewRow) ViewUtils.getCurrentRow(TPP_CURRENT_VIEW_IT);
        UtilitiesBean.setBaCode("TPPEdit");
        currTppVersionRow.createTppVersion(this.getTppVersionName(), this.getTppVersionAppDate(),
                                           this.getTppVersionDescription());
        UtilitiesBean.setBaCode(null);
        refreshVersions();
    }

    private CollectionModel getTppValuesCollectionModel(String ttName) {
        RichTreeTable richTreeTable = (RichTreeTable) ViewUtils.getUiComponent(ttName);
        return (CollectionModel) richTreeTable.getValue();
    }

    public void onCurrentExportToPDF(ActionEvent action) {

        TargetProductProfileViewRow tppCurrentRow =
            (TargetProductProfileViewRow) ViewUtils.getCurrentRow(TPP_CURRENT_VIEW_IT);

        ProjectViewRow prjtRow = (ProjectViewRow) ViewUtils.getCurrentRow("ProjectViewIterator");

        String url =  tppCurrentRow.retrieveExportURL(prjtRow.getCode(), tppCurrentRow.getVersion());
        
        //String confLink =
        //    (String) ViewUtils.runValueEl("#{bindings.ConfigurationViewIterator.viewObject.values['TPP-EXPURL']}");

        //String newLink =
        //    confLink.replace("#ProjectId#", prjtRow.getCode()).replace("#Version#", tppCurrentRow.getVersion());
        onWindowOpen(url);
    }

    public void onVersionExportToPDF(ActionEvent action) {

        TargetProductProfileViewRow tppVersionRow =
            (TargetProductProfileViewRow) ViewUtils.getCurrentRow(TPP_VERSIONS_VIEW_IT);

        ProjectViewRow prjtRow = (ProjectViewRow) ViewUtils.getCurrentRow("ProjectViewIterator");
        
        String url =  tppVersionRow.retrieveExportURL(prjtRow.getCode(), tppVersionRow.getVersion());
        
        //String confLink =
        //    (String) ViewUtils.runValueEl("#{bindings.ConfigurationViewIterator.viewObject.values['TPP-EXPURL']}");

        //String newLink =
        //    confLink.replace("#ProjectId#", prjtRow.getCode()).replace("#Version#", tppVersionRow.getVersion());
        onWindowOpen(url);
    }


    public void onWindowOpen(String url) {
        FacesContext faces = FacesContext.getCurrentInstance();

        String script = "window.open('" + url + "')";
        ExtendedRenderKitService service =
            Service.getRenderKitService(FacesContext.getCurrentInstance(), ExtendedRenderKitService.class);
        service.addScript(FacesContext.getCurrentInstance(), script);
    }

    public void onTppAdd() {

        ViewUtils.runMethodEl("#{bindings.TppCurrentCreateInsert.execute}");
        TargetProductProfileViewRow tppRow =
            (TargetProductProfileViewRow) ViewUtils.getIteratorBinding(TPP_CURRENT_VIEW_IT).getViewObject().getCurrentRow();
        tppRow.setProjectId((String) ViewUtils.runValueEl("#{bindings.Id.inputValue}"));
    }
}

