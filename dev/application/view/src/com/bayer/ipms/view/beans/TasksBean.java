package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.TaskViewImpl;
import com.bayer.ipms.view.events.ContextualEventHandler;
import com.bayer.ipms.view.utils.ViewUtils;

import com.bayer.ipms.view.base.IPMSBean;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import javax.faces.event.ActionEvent;

import javax.faces.event.ValueChangeEvent;

import oracle.adf.controller.TaskFlowId;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCControlBinding;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.share.ADFContext;

import oracle.adf.view.faces.bi.component.pivotTable.SizingManager;

import oracle.adf.view.faces.bi.component.pivotTable.UIPivotTable;
import oracle.adf.view.faces.bi.model.DataCellIndex;
import oracle.adf.view.faces.bi.model.DataCellKey;
import oracle.adf.view.faces.bi.model.DataModel;

import oracle.adf.view.rich.component.rich.data.RichTable;

import oracle.dss.util.DataMap;
import oracle.dss.util.QDR;

import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.ViewObject;

import org.apache.myfaces.trinidad.event.DisclosureEvent;
import org.apache.myfaces.trinidad.event.ReturnEvent;
import org.apache.myfaces.trinidad.event.SelectionEvent;
import org.apache.myfaces.trinidad.model.RowKeySet;
import org.apache.myfaces.trinidad.model.RowKeySetImpl;


public class TasksBean extends IPMSBean {
    private String taskFlowId = TF_TASK;
    private static final String TF_TASK = "/WEB-INF/com.bayer.ipms.view/flows/task-view.xml";
    private static final String TF_LOG = "/WEB-INF/com.bayer.ipms.view/flows/task-log.xml";

    public TasksBean() {
        super();
    }

    public String onTasksRefresh() {
        ViewUtils.getIteratorBinding("TaskLocalViewIterator").executeQuery();
        ViewUtils.reloadUiComponent("trTasks");

        return null;
    }

    public String onTerminatedRefresh() {
        ViewUtils.getIteratorBinding("TerminatedViewIterator").executeQuery();
        ViewUtils.reloadUiComponent("trTerm");

        return null;
    }

    public TaskFlowId getContentFlowId() {
        return TaskFlowId.parse(taskFlowId);
    }

    public boolean getTasksDisclosed() {
        return TF_TASK.equalsIgnoreCase(this.taskFlowId);
    }

    public void onTerminatedDisclose(DisclosureEvent disclosureEvent) {
        this.taskFlowId = TF_TASK;
    }

    public void onTasksDisclose(DisclosureEvent disclosureEvent) {
        this.taskFlowId = TF_LOG;
    }

}