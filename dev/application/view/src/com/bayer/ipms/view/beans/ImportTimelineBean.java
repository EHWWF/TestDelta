package com.bayer.ipms.view.beans;


import com.bayer.ipms.model.views.common.ProgramView;
import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.model.views.imports.common.ImportTimelineView;
import com.bayer.ipms.model.views.imports.common.ImportTimelineViewRow;
import com.bayer.ipms.model.views.imports.common.ImportViewRow;
import com.bayer.ipms.view.utils.ViewUtils;
import com.bayer.ipms.view.base.IPMSBean;

import com.bayer.ipms.view.utils.U;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.component.UIComponent;
import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.component.rich.data.RichColumn;
import oracle.adf.view.rich.component.rich.data.RichTable;
import oracle.adf.view.rich.component.rich.data.RichTree;
import oracle.adf.view.rich.component.rich.data.RichTreeTable;
import oracle.adf.view.rich.component.rich.input.RichSelectItem;
import oracle.adf.view.rich.component.rich.input.RichSelectOneChoice;

import oracle.jbo.Row;
import oracle.jbo.VariableValueManager;
import oracle.jbo.ViewCriteriaManager;
import oracle.jbo.domain.Number;
import oracle.jbo.uicli.binding.JUCtrlHierBinding;
import oracle.jbo.uicli.binding.JUCtrlHierNodeBinding;

import org.apache.myfaces.trinidad.event.PollEvent;
import org.apache.myfaces.trinidad.model.CollectionModel;
import org.apache.myfaces.trinidad.model.RowKeySetImpl;


public class ImportTimelineBean extends IPMSBean {
    private RowKeySetImpl disclosedTreeKeys;
    private String searchStudy;
    private String searchImportStatus;
    private String searchFailed;
    private String searchStudyRelated;

    public ImportTimelineBean() {
        super();
    }

    private boolean isActivityIncluded(JUCtrlHierNodeBinding node) {
        if (node.hasChildren() && node.getChildren() != null) {
            for (JUCtrlHierNodeBinding chnode : (List<JUCtrlHierNodeBinding>)node.getChildren()) {
                ImportTimelineViewRow row = (ImportTimelineViewRow)chnode.getRow();
                if (row.getActivityId() != null && "READY".equals(row.getStatusCode())) {
                    return true;
                } else if (isActivityIncluded(chnode)) {
                    return true;
                }
            }
        }
        return false;
    }

    public Map<Object, Object> getElementType() {
        return new HashMap<Object, Object>() {
            @Override
            public Object get(Object object) {

                JUCtrlHierNodeBinding node = (JUCtrlHierNodeBinding)object;
                ImportTimelineViewRow row = (ImportTimelineViewRow)node.getRow();

                if (row != null) {
                    if (row.getWbsId() != null &&
                        (isActivityIncluded(node) && "READY".equals(ViewUtils.getAttributeValue("ImportStatusCode").toString()) ||
                         row.getActionCode() != null)) {
                        return "Wbs";
                    } else if (row.getActivityId() != null && !"OLD".equals(row.getStatusCode())) {
                        return "Activity";
                    }
                }

                return "Default";
            }
        };
    }

    /**
     * Sets the given action value to all study activities.
     * Is called as value change listener in the study action select box.
     * @param valueChangeEvent
     */
    public void onWbsAction(ValueChangeEvent valueChangeEvent) {
        JUCtrlHierNodeBinding node = (JUCtrlHierNodeBinding)getTreeTable().getRowData();

        setNodeImportAction(node, valueChangeEvent.getNewValue().toString());
    }

    public RichTreeTable getTreeTable() {
        return (RichTreeTable)ViewUtils.getUiComponent("tree");
    }

    /**
     * Used in the tree table to disclose all children per default.
     * @return set of disclosed node keys.
     */
    public RowKeySetImpl getDisclosedTreeKeys() {
        if (this.disclosedTreeKeys == null) {
            this.disclosedTreeKeys = new RowKeySetImpl();

            JUCtrlHierNodeBinding nodeBinding = getTimelineRootNode();

            ViewUtils.collectAllNodes(nodeBinding, this.disclosedTreeKeys);
        }

        return this.disclosedTreeKeys;
    }

    /**
     * Applies all timeline changes.
     * Is called as action listener in the "Apply All" button.
     */
    public String onApplyAll() {
        JUCtrlHierNodeBinding root = this.getTimelineRootNode();
        this.setNodeImportAction(root, "APPLY");

        return null;
    }

    /**
     * Applies with restrictions all timeline changes.
     * Is called as action listener in the "Apply All With Restrictions" button.
     */
    public String onApplyAllRestrictions() {
        JUCtrlHierNodeBinding root = this.getTimelineRootNode();
        this.setNodeImportAction(root, "RESTR");

        return null;
    }

    /**
     * Skips all timeline changes.
     * Is called as action listener in the "Skip All" button.
     */
    public String onSkipAll() {
        JUCtrlHierNodeBinding root = this.getTimelineRootNode();
        this.setNodeImportAction(root, "SKIP");

        return null;
    }

    /**
     * Handles the refresh button click. Removes information about disclosed treetable nodes.
     */
    public String onRefresh() {
        this.disclosedTreeKeys = null;
        ImportViewRow imp = (ImportViewRow)ViewUtils.getCurrentRow("ImportViewIterator");
        imp.refresh();

        onSearch(null);

        return null;
    }

    public void onPoll(PollEvent pollEvent) {
        onRefresh();
    }

    /**
     * Handles submit action.
     */
    public String onSubmit() {
        ViewUtils.getIteratorBinding("ImportViewIterator").getDataControl().commitTransaction();

        ImportViewRow imp = (ImportViewRow)ViewUtils.getCurrentRow("ImportViewIterator");
        imp.finish();

        return null;
    }

    private JUCtrlHierNodeBinding getTimelineRootNode() {
        CollectionModel model = (CollectionModel)getTreeTable().getValue();

        JUCtrlHierBinding treeBinding = (JUCtrlHierBinding)model.getWrappedData();
        JUCtrlHierNodeBinding nodeBinding = treeBinding.getRootNodeBinding();
        return nodeBinding;
    }

    private void setNodeImportAction(JUCtrlHierNodeBinding nodeBinding, String importActionValue) {
        List<JUCtrlHierNodeBinding> childNodes = nodeBinding.getChildren();

        // iterate through children
        if (childNodes != null) {
      
            for (JUCtrlHierNodeBinding _node : childNodes) {
              if (!"Default".equals(getElementType().get(_node))) {
                this.setNodeImportAction(_node, importActionValue);
                 }
                  }
            }
      

        if (!"Default".equals(getElementType().get(nodeBinding))) {
            nodeBinding.setAttribute("ActionCode", importActionValue);
        }
    }

    public String getSearchStudy() {
        return searchStudy;
    }

    public void setSearchStudy(String study) {
        searchStudy = study;
    }

    public String getSearchImportStatus() {
        return searchImportStatus;
    }

    public void setSearchImportStatus(String Importstatus) {
        searchImportStatus = Importstatus;
    }

    public String getSearchFailed() {

        if (searchFailed == null) {
            setSearchFailed("false");
        }

        return searchFailed;
    }

    public void setSearchFailed(String failed) {
        searchFailed = failed;
    }

    public String getSearchStudyRelated() {
        if (searchStudyRelated == null) {
            setSearchStudyRelated("FPS".equals(ViewUtils.runValueEl("#{pageFlowScope.importSource}"))||
                                  "RAPT".equals(ViewUtils.runValueEl("#{pageFlowScope.importSource}")) ? "false" :
                                  "true");
        }
        return searchStudyRelated;

    }

    public void setSearchStudyRelated(String StudyRelated) {
        searchStudyRelated = StudyRelated;
    }

    public void onSearch(ActionEvent actionEvent) {

        DCIteratorBinding it = ViewUtils.getIteratorBinding("ImportTimelineViewIterator");
        ImportTimelineView vo = (ImportTimelineView)it.getViewObject();
        VariableValueManager vm = vo.getVariableManager();

        vm.setVariableValue("StudyVar", getSearchStudy());
        vm.setVariableValue("StatusVar", getSearchImportStatus());
        vm.setVariableValue("StudyRelatedVar", getSearchStudyRelated());
        vm.setVariableValue("FailedVar", getSearchFailed());

        vo.executeQuery();           
        ViewUtils.reloadUiComponent("content");
    }

    public void onReset(ActionEvent actionEvent) {

        setSearchStudy(null);
        setSearchImportStatus(null);
        setSearchStudyRelated(null);
        setSearchFailed(null);
    }

}
