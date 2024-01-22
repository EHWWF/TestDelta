package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.estimates.common.LatestEstimatesTagViewRow;
import com.bayer.ipms.model.views.ltc.common.LtcProcessViewRow;
import com.bayer.ipms.view.base.IPMSBean;
import com.bayer.ipms.view.utils.ViewUtils;
import com.bayer.ipms.model.views.ltc.common.LtcTagViewRow;

import com.bayer.ipms.view.events.ContextualEventHandler;

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

public class LtcBean2 extends IPMSBean {
    @SuppressWarnings("compatibility:-3339026274302442090")
    private static final long serialVersionUID = 1L;
    
    private static final String LTC_TAG_IT = "LtcTagViewIterator"; 
    private static final String LTC_PROC_IT = "LtcProcessViewIterator";
    private static final String TF_LTC_TAG_VIEW =
       "/WEB-INF/com.bayer.ipms.view/flows/ltc-tag-view.xml#ltc-tag-view";   
    private static final String TF_LTC_PROC_VIEW =
       "/WEB-INF/com.bayer.ipms.view/flows/ltc-view.xml#ltc-view";     
    private String ltcViewTaskFlowId = TF_LTC_TAG_VIEW;
    
    public LtcBean2() {
    }

    public String onEstimatesRefresh() {       
        LtcTagViewRow tagRow = (LtcTagViewRow ) ViewUtils.getIteratorBinding(LTC_TAG_IT).getViewObject().getCurrentRow();
        LtcProcessViewRow procRow = (LtcProcessViewRow ) ViewUtils.getIteratorBinding(LTC_PROC_IT).getViewObject().getCurrentRow();
        ViewUtils.getIteratorBinding(LTC_TAG_IT).executeQuery();

        if (tagRow != null) {
            ViewUtils.getIteratorBinding(LTC_TAG_IT).setCurrentRowWithKey(tagRow.getKey().toStringFormat(true));
        }       
        
        if (procRow != null) {
            ViewUtils.getIteratorBinding(LTC_PROC_IT).setCurrentRowWithKey(procRow.getKey().toStringFormat(true));
        } 
        
        ViewUtils.reloadUiComponent("toolbar", "ltcPlTree");

        return null;
    }

    public ContextualEventHandler getEstimatesEventHandler() {
        return new ContextualEventHandler() {
            public void handleEvent(Object payload) {
                ((LtcTagViewRow) ViewUtils.getIteratorBinding(LTC_TAG_IT).getCurrentRow()).refresh();
                ViewUtils.reloadUiComponent("ltcPlTree");
            }
        };
    }

    public void onCreateTagPopupFetch(PopupFetchEvent popupFetchEvent) {
        LtcTagViewRow tagRow =
            (LtcTagViewRow) ViewUtils.getIteratorBinding(LTC_TAG_IT).getViewObject().first();        
        ViewUtils.getOperationBinding("TagCreateInsert").execute();
        LtcTagViewRow newTagRow = (LtcTagViewRow) ViewUtils.getCurrentRow(LTC_TAG_IT);
        if (newTagRow != null && tagRow != null) {
            newTagRow.setParentId(tagRow.getId());
        }
    }

    public void onCreateTagPopupCancel(PopupCanceledEvent popupCanceledEvent) {
        ViewUtils.getIteratorBinding(LTC_TAG_IT).getDataControl().rollbackTransaction();
    }
    
    public void onTagCreate(DialogEvent dialogEvent) {
        UtilitiesBean.setBaCode("EstimatesTagCreateLTC");
        ViewUtils.getIteratorBinding(LTC_TAG_IT).getDataControl().commitTransaction();
        UtilitiesBean.setBaCode(null);
        LtcTagViewRow tagRow = (LtcTagViewRow ) ViewUtils.getIteratorBinding(LTC_TAG_IT).getViewObject().getCurrentRow();
        ViewUtils.getIteratorBinding(LTC_TAG_IT).executeQuery();

        ViewUtils.reloadUiComponent("toolbar", "ltcPlTree");   
    }   
    
    public TaskFlowId getLtcViewTaskFlowId() {
        return TaskFlowId.parse(ltcViewTaskFlowId);
    }

    public void setLtcViewTaskFlowId(String taskFlowId) {
        this.ltcViewTaskFlowId = taskFlowId;
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

        if ("LtcTagView".equals(treeBinding.getName()) && keys.size() == 1) {
            ltcViewTaskFlowId = TF_LTC_TAG_VIEW;
        } else {
            ViewUtils.getIteratorBinding("LtcProcessViewIterator").setCurrentRowWithKey(processKey.toStringFormat(true));
            ltcViewTaskFlowId = TF_LTC_PROC_VIEW;
        }
    }    
}
