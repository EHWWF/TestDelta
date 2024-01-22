package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.estimates.common.LatestEstimatesTagViewRow;
import com.bayer.ipms.view.base.IPMSBean;
import com.bayer.ipms.view.events.ContextualEventHandler;
import com.bayer.ipms.view.utils.ViewUtils;

import java.util.List;

import oracle.adf.controller.TaskFlowId;
import oracle.adf.view.rich.component.rich.data.RichTree;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;

import oracle.jbo.Key;
import oracle.jbo.uicli.binding.JUCtrlHierBinding;

import org.apache.myfaces.trinidad.event.SelectionEvent;
import org.apache.myfaces.trinidad.model.CollectionModel;


/**
 * Provides in the estimates.jspx page functionality for
 * tree navigation and region content management.
 */
public class EstimatesBean extends IPMSBean {

    @SuppressWarnings("compatibility:-3339026274302442090")
    private static final long serialVersionUID = 1L;
    private static final String LET_IT = "LatestEstimatesTagViewIterator";
    private static final String TF_TAG_VIEW =
        "/WEB-INF/com.bayer.ipms.view/flows/estimates-tag-view.xml#estimates-tag-view";
    private static final String TF_PROCESS_VIEW =
        "/WEB-INF/com.bayer.ipms.view/flows/estimates-view.xml#estimates-view";
    private String estimatesViewTaskFlowId = TF_TAG_VIEW;

    public EstimatesBean() {
    }

    public String onEstimatesRefresh() {
        ViewUtils.getIteratorBinding(LET_IT).executeQuery();

        ViewUtils.reloadUiComponent("toolbar", "prcTree");

        return null;
    }


    public ContextualEventHandler getEstimatesEventHandler() {
        return new ContextualEventHandler() {
            public void handleEvent(Object payload) {
                ((LatestEstimatesTagViewRow) ViewUtils.getIteratorBinding(LET_IT).getCurrentRow()).refresh();
                ViewUtils.reloadUiComponent("prcTree");
            }
        };
    }

    public void onTagCreate(DialogEvent dialogEvent) {

        UtilitiesBean.setBaCode("EstimatesTagCreate");
        ViewUtils.getIteratorBinding(LET_IT).getDataControl().commitTransaction();
        UtilitiesBean.setBaCode(null);
        ViewUtils.reloadUiComponent("prcTree");
       // ViewUtils.reloadUiComponent("pgTagView");
    }

    public void onCreateTagPopupFetch(PopupFetchEvent popupFetchEvent) {

        LatestEstimatesTagViewRow letRow =
            (LatestEstimatesTagViewRow) ViewUtils.getIteratorBinding(LET_IT).getViewObject().first();
        ViewUtils.getOperationBinding("LetCreateInsert").execute();
        LatestEstimatesTagViewRow newLetRow = (LatestEstimatesTagViewRow) ViewUtils.getCurrentRow(LET_IT);
        newLetRow.setPreviousLetId(letRow.getId());
    }

    public void onCreateTagPopupCancel(PopupCanceledEvent popupCanceledEvent) {
        ViewUtils.getIteratorBinding(LET_IT).getDataControl().rollbackTransaction();
    }

    public TaskFlowId getEstimatesViewTaskFlowId() {
        return TaskFlowId.parse(estimatesViewTaskFlowId);
    }

    public void setEstimatesViewTaskFlowId(String taskFlowId) {
        this.estimatesViewTaskFlowId = taskFlowId;
    }

    public void onProcessTreeSelect(SelectionEvent selectionEvent) {

        if (!selectionEvent.getAddedSet().iterator().hasNext()) {
            return;
        }

        RichTree tree = (RichTree) selectionEvent.getSource();
        JUCtrlHierBinding treeBinding = (JUCtrlHierBinding) ((CollectionModel) tree.getValue()).getWrappedData();

        ViewUtils.runMethodEl("#{bindings." + treeBinding.getName() + ".treeModel.makeCurrent}", new Class[] {
                              SelectionEvent.class }, new Object[] { selectionEvent });


        List<?> keys = (List<?>) selectionEvent.getAddedSet().iterator().next();
        Key processKey = (Key) keys.get(keys.size() - 1);

        if ("LatestEstimatesTagView".equals(treeBinding.getName()) && keys.size() == 1) {
            estimatesViewTaskFlowId = TF_TAG_VIEW;
        } else {
            ViewUtils.getIteratorBinding("LatestEstimatesProcessViewIterator").setCurrentRowWithKey(processKey.toStringFormat(true));
            estimatesViewTaskFlowId = TF_PROCESS_VIEW;
        }
    }
}
