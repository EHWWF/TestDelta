package com.bayer.ipms.view.beans;



import com.bayer.ipms.model.views.common.ProjectView;
import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.model.views.common.TaskLocalViewRow;
import com.bayer.ipms.model.views.common.TaskViewRow;
import com.bayer.ipms.model.views.ltc.common.LtcProjectViewRow;
import com.bayer.ipms.model.views.ltc.common.LtcTagViewRow;
import com.bayer.ipms.view.base.IPMSViewBean;
import com.bayer.ipms.view.utils.ViewUtils;

import java.math.BigDecimal;

import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;

import oracle.binding.BindingContainer;
import oracle.adf.model.BindingContext;

import oracle.binding.OperationBinding;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;

import oracle.jbo.Key;


public class TaskViewBean extends IPMSViewBean {
    
    private static final String LET_IT = "LtcTagViewIterator"; 
    private static final String TSK_IT = "TaskLocalViewIterator"; 
    
    public TaskViewBean() {
        super("TaskLocalViewIterator");
    }

    public void onReject(DialogEvent event) {
        TaskLocalViewRow task = (TaskLocalViewRow)ViewUtils.getCurrentRow(TSK_IT);
        task.setState("COMPLETED"); // Local task case
        task.setOutcome("REJECT"); // Local task case
        getDataControl().commitTransaction(); // Local task case
        //task.reject(); // Real BPM process case
        ViewUtils.getIteratorBinding(TSK_IT).executeQuery();
        ViewUtils.reloadUiComponent("tools", "content", "trTasks");
    }

    /* Method for updating project data. Misleading names because of popup reusage. */

    public void onProjectCreate(DialogEvent event) {
        UtilitiesBean.setBaCode("ProjectEditID");        
        onPopupSubmit(event);
        UtilitiesBean.setBaCode(null);
        
        ProjectViewRow prjRow = (ProjectViewRow)ViewUtils.getCurrentRow("ProjectViewIterator");
        prjRow.setRelation(prjRow.getPredecessorProjectId(),null);
        prjRow.send();

        TaskLocalViewRow task = (TaskLocalViewRow)ViewUtils.getCurrentRow(TSK_IT);
        task.setState("COMPLETED"); // Local task case
        task.setOutcome("APPROVE"); // Local task case
        getDataControl().commitTransaction(); // Local task case
        
        
        //task.approve(); // Real BPM process case
        prjRow.notifyProjectCreated();
        
        ViewUtils.reloadUiComponent("tools", "content");
    }

    public void onProjectCreatePopupCancel(PopupCanceledEvent event) {
        super.onPopupCancel(event);
    }

    public void onProjectCreatePopupFetch(PopupFetchEvent event) {
    }

    public void onPredecessorChange(ValueChangeEvent event) {

        event.getComponent().processUpdates(FacesContext.getCurrentInstance());
        ProjectViewRow prjRow = (ProjectViewRow)ViewUtils.getCurrentRow("ProjectViewIterator");
        
      
        
        if (prjRow.getPredecessorProjectId() != null) {
            ProjectView predPrjVo = (ProjectView)ViewUtils.getIteratorBinding("D2ProjectsViewIterator").getViewObject();
            Key key = new Key(new Object[] { prjRow.getPredecessorProjectId() });
            ProjectViewRow prjPredRow = (ProjectViewRow)predPrjVo.findByKey(key, 1)[0];
            UtilitiesBean.prefillProjectPredecessor(prjPredRow, prjRow);}

    }

    public void onProjectPrefillProfit(DialogEvent dialogEvent) {
        UtilitiesBean.setBaCode("EstimatesTagPrefillLTC");

        LtcProjectViewRow prjRow = (LtcProjectViewRow) ViewUtils.getCurrentRow("TaskLtcProjectViewIterator");
        String prjId = null;

        if (prjRow != null) {
            prjId = prjRow.getProjectId();
        }

        LtcTagViewRow tagRow = (LtcTagViewRow) ViewUtils.getCurrentRow("LtcTagViewIterator");
        BigDecimal tagId = null;

        if (tagRow != null) {
            tagId = tagRow.getId();
        }

        BindingContainer bc = BindingContext.getCurrent().getCurrentBindingsEntry();
        OperationBinding ob = bc.getOperationBinding("prjPrefill");

        ob.getParamsMap().put("tagId", String.valueOf(tagId));
        ob.getParamsMap().put("processId", null);
        ob.getParamsMap().put("programId", null);
        ob.getParamsMap().put("projectId", prjId);
        ob.execute();

        UtilitiesBean.setBaCode(null);
    }

}
