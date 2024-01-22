package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.common.ProgramViewRow;
import com.bayer.ipms.model.views.imports.common.ImportStudyView;
import com.bayer.ipms.model.views.imports.common.ImportStudyViewRow;
import com.bayer.ipms.model.views.imports.common.ImportViewRow;
import com.bayer.ipms.view.base.IPMSBean;
import com.bayer.ipms.view.utils.U;
import com.bayer.ipms.view.utils.ViewUtils;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.Set;

import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.faces.validator.ValidatorException;

import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.share.ADFContext;
import oracle.adf.view.rich.component.rich.data.RichTable;
import oracle.adf.view.rich.component.rich.data.RichTreeTable;
import oracle.adf.view.rich.component.rich.input.RichInputText;
import oracle.adf.view.rich.component.rich.layout.RichPanelSplitter;
import oracle.adf.view.rich.component.rich.nav.RichButton;
import oracle.adf.view.rich.render.ClientEvent;

import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.ValidationException;
import oracle.jbo.uicli.binding.JUCtrlHierBinding;
import oracle.jbo.uicli.binding.JUCtrlHierNodeBinding;

import org.apache.myfaces.trinidad.event.PollEvent;
import org.apache.myfaces.trinidad.event.SelectionEvent;
import org.apache.myfaces.trinidad.model.RowKeySet;

public class ImportStudyBean extends IPMSBean {
    @SuppressWarnings("compatibility:-2674822035940523609")
    private static final long serialVersionUID = 6404063490470233592L;

    private static final String IMPORT_STUDY_DATA_ITERATOR =
        "ImportStudyDataViewIterator", IMPORT_PROJECT_STUDY_ITERATOR =
        "ImportProjectStudyViewIterator", IMPORT_ITERATOR = "ImportViewIterator";

    Map pageFlowScope;

    private transient RichTreeTable wbsTree;

    public void setImportProcessing(boolean importProcessing) {
        pageFlowScope.put("IsImportProcessing", importProcessing ? "true" : "false");
    }

    public boolean isImportProcessing() {
        return "true".equals(pageFlowScope.get("IsImportProcessing"));
    }

    public ImportStudyBean() {
        super();
        ADFContext adfCtx = ADFContext.getCurrent();
        pageFlowScope = adfCtx.getPageFlowScope();
    }

    /**
     * Handles the refresh button click.
     */
    public String onRefresh() {
        ImportViewRow imp = (ImportViewRow) ViewUtils.getCurrentRow(IMPORT_ITERATOR);
        imp.refresh();

        if (ViewUtils.getIteratorBinding(IMPORT_STUDY_DATA_ITERATOR) != null)
            ViewUtils.executeIterators(IMPORT_STUDY_DATA_ITERATOR);

        // Do not re-execute the import study view iterator after pressed on the Import button
        // in order not to loose the missing studies list in the current view
        if (ViewUtils.getIteratorBinding(IMPORT_PROJECT_STUDY_ITERATOR) != null && !this.isImportProcessing())
            ViewUtils.executeIterators(IMPORT_PROJECT_STUDY_ITERATOR);

        return null;
    }

    @SuppressWarnings("unused")
    public void onPoll(PollEvent pollEvent) {

        onRefresh();
    }

    /**
     * Handles submit action.
     */
    public String onSubmit() {
        UtilitiesBean.setBaCode("ImportStudy");
        ViewUtils.getIteratorBinding(IMPORT_ITERATOR).getDataControl().commitTransaction();

        ImportViewRow imp = (ImportViewRow) ViewUtils.getCurrentRow(IMPORT_ITERATOR);
        imp.finish();
        UtilitiesBean.setBaCode(null);

        return null;
    }

    @SuppressWarnings("unused")
    public void onImport(ActionEvent actionEvent) {
        DCIteratorBinding iterBind = ViewUtils.getIteratorBinding(IMPORT_PROJECT_STUDY_ITERATOR);
        ImportStudyView importStudyView = (ImportStudyView) iterBind.getViewObject();

        try {
            // 1. Validate studies selected for import
            importStudyView.validateStudies();

            // 2. Execute import studies
            this.setImportProcessing(true);
            importStudyView.doImport();

        } catch (ValidationException err) {
            this.setImportProcessing(false);

            // 1.1. Show an error dialog in case validation failed
            RichTable studiesTable = (RichTable) ViewUtils.getUiComponent("studiesTbl");
            FacesContext ctx = FacesContext.getCurrentInstance();

            err.setAppendCodes(false);

            FacesMessage errorMessage =
                new FacesMessage(FacesMessage.SEVERITY_ERROR,
                                 ResourceBundle.getBundle("com.bayer.ipms.view.bundles.viewBundle").getString("importStudyValidationErrorMessage"),
                                 err.getMessage());

            ctx.addMessage(studiesTable.getClientId(ctx), errorMessage);

            throw new ValidatorException(errorMessage);
        }
    }

    @SuppressWarnings("unused")
    public void selectAll(ActionEvent actionEvent) {
        DCIteratorBinding iterBind = ViewUtils.getIteratorBinding(IMPORT_PROJECT_STUDY_ITERATOR);
        ImportStudyView importStudyView = (ImportStudyView) iterBind.getViewObject();

        importStudyView.selectAllInRange();
    }

    @SuppressWarnings("unused")
    public void unselectAll(ActionEvent actionEvent) {
        DCIteratorBinding iterBind = ViewUtils.getIteratorBinding(IMPORT_PROJECT_STUDY_ITERATOR);
        ImportStudyView importStudyView = (ImportStudyView) iterBind.getViewObject();

        importStudyView.unselectAllInRange();
    }

    @SuppressWarnings("unused")
    public void onSelectWbs(ActionEvent actionEvent) {
        RichButton setWbsBtn = (RichButton) ViewUtils.getUiComponent("setWbsBtn");

        // 1. Get selected study name
        DCIteratorBinding studyIter = ViewUtils.getIteratorBinding(IMPORT_PROJECT_STUDY_ITERATOR);
        ImportStudyViewRow currentStudy = (ImportStudyViewRow) studyIter.getCurrentRow();
        String selectedStudyName = currentStudy.getName();

        // 2. Set selected study name input text
        RichInputText selectedStudy = (RichInputText) ViewUtils.getUiComponent("selectedStudy");
        selectedStudy.setValue(selectedStudyName);

        // 3. Show project WBS tree panel
        RichPanelSplitter splitter = (RichPanelSplitter) ViewUtils.getUiComponent("contentSplitter");
        splitter.setCollapsed(false);
        splitter.setDisabled(false);

        if (wbsTree == null)
            return;

        RowKeySet selectedRowKeys = (RowKeySet) currentStudy.getParentWbsSelectedKeys();
        RowKeySet disclosedRowKeys = (RowKeySet) currentStudy.getParentWbsDisclosedKeys();

        // 4. Reset project BWBS treetable
        wbsTree.getSelectedRowKeys().clear();
        if (selectedRowKeys != null && !selectedRowKeys.isEmpty()) {
            wbsTree.setDisplayRow("selected");
            wbsTree.setSelectedRowKeys(selectedRowKeys);
            setWbsBtn.setDisabled(false);
        } else {
            wbsTree.setDisplayRow("first");
            setWbsBtn.setDisabled(true);
        }

        if (disclosedRowKeys != null && !disclosedRowKeys.isEmpty())
            wbsTree.setDisclosedRowKeys(disclosedRowKeys);
    }

    @SuppressWarnings("unused")
    public void onSetWbs(ActionEvent actionEvent) {
        // 1. Hide Project WBS treetable
        RichPanelSplitter splitter = (RichPanelSplitter) ViewUtils.getUiComponent("contentSplitter");
        splitter.setCollapsed(true);
        splitter.setDisabled(true);

        // 2. Get current selected treetable node

        RichTable studyTable = (RichTable) ViewUtils.getUiComponent("studiesTbl");
        RowKeySet selectedStudyKeys = studyTable.getSelectedRowKeys();
        List selectedStudyKey = (List) selectedStudyKeys.iterator().next();
        ImportStudyViewRow currentStudy =
            (ImportStudyViewRow) ViewUtils.getIteratorBinding(IMPORT_PROJECT_STUDY_ITERATOR).getRowSetIterator().findByKey((Key) selectedStudyKey.get(0),
                                                                                                                           1)[0];

        RowKeySet selectedRowKeys = wbsTree.getSelectedRowKeys().clone();
        RowKeySet disclosedRowKeys = wbsTree.getDisclosedRowKeys().clone();
        JUCtrlHierBinding treeTableBinding =
            (JUCtrlHierBinding) ViewUtils.runValueEl("#{bindings.ImportStudyTargetWbsView}");
        JUCtrlHierNodeBinding node = null;

        if (selectedRowKeys.iterator().hasNext())
            node = treeTableBinding.findNodeByKeyPath((List) selectedRowKeys.iterator().next());

        // 3. Set the Selected WBS column value with currently selected node value.
        if (node != null) {
            String selectedWbsName = (String) node.getAttribute("WbsName");
            if (selectedWbsName != null) {
                currentStudy.setParentWbsName(selectedWbsName);
                currentStudy.setParentWbsId((String) node.getAttribute("WbsId"));
                currentStudy.setParentWbsSelectedKeys(selectedRowKeys);
                currentStudy.setParentWbsDisclosedKeys(disclosedRowKeys);
            }
        }
    }

    public void setWbsTree(RichTreeTable wbsTree) {
        this.wbsTree = wbsTree;
    }

    public RichTreeTable getWbsTree() {
        return wbsTree;
    }

    /**
     * Invoke a click action on a "Set WBS" button when a Project WBS tree-table row is double clicked...
     * @param clientEvent double click on a wbs treetable row
     */
    @SuppressWarnings("unused")
    public void onWbsTreeDoubleClick(ClientEvent clientEvent) {
        RichButton setWbsBtn = (RichButton) ViewUtils.getUiComponent("setWbsBtn");
        ActionEvent click = new ActionEvent(setWbsBtn);
        click.queue();
    }

    /**
     * This is a concept to call a bean method with parameter. It is called from the EL like: #{bean.rowParentWbsIsRootNode[row]}
     * @return true for the given treetable row, if its parent WBS attribute is a root node. Otherwise, false
     */
    public Map<Object, Object> getRowParentWbsIsRootNode() {
        return new HashMap<Object, Object>() {
            @SuppressWarnings("compatibility:-6555924099566514694")
            private static final long serialVersionUID = -8263874860529351220L;

            @Override
            public Object get(Object object) {

                // 1. Get current row
                JUCtrlHierNodeBinding node = (JUCtrlHierNodeBinding) object;
                ImportStudyViewRow study = (ImportStudyViewRow) node.getRow();

                if (study != null) {
                    // 2. Get the parent's WBS selected keys
                    Set selectedRowKeys = study.getParentWbsSelectedKeys();
                    if (selectedRowKeys != null && !selectedRowKeys.isEmpty()) {
                        List selectedRowKeysList = (List) selectedRowKeys.iterator().next();
                        // 3. If the selected row keys list consits only of one key, then it is a root key
                        if (selectedRowKeysList != null && selectedRowKeysList.size() == 1)
                            return true;
                    }
                }

                return false;
            }
        };
    }

    public void onFinish() {
        ImportViewRow imp = (ImportViewRow) ViewUtils.getCurrentRow(IMPORT_ITERATOR);
        imp.finish();
    }

    public void onParentWbsSelection(SelectionEvent selectionEvent) {
        RichButton setWbsBtn = (RichButton) ViewUtils.getUiComponent("setWbsBtn");

        // enable the Set Wbs button
        if (selectionEvent.getAddedSet().getSize() > 0) {
            setWbsBtn.setDisabled(false);
            ViewUtils.reloadUiComponent(setWbsBtn.getId());
        }


        // make the selected row current in the view iterator
        ViewUtils.runMethodEl("#{bindings.ImportStudyTargetWbsView.treeModel.makeCurrent}",
                              new Class[] { SelectionEvent.class }, new Object[] { selectionEvent });
    }
}
