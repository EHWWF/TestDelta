package com.bayer.ipms.view.base;


import com.bayer.ipms.model.base.IPMSViewRowImpl;
import com.bayer.ipms.model.views.common.ProgramViewRow;
import com.bayer.ipms.model.views.common.UserRoleView;
import com.bayer.ipms.view.beans.UtilitiesBean;
import com.bayer.ipms.view.utils.ViewUtils;

import javax.faces.application.FacesMessage;
import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import oracle.adf.model.binding.DCDataControl;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.util.ResetUtils;

import oracle.jbo.JboException;

import org.apache.myfaces.trinidad.event.PollEvent;


public abstract class IPMSViewBean extends IPMSBean {
    protected String editable = null;
    protected String iterator = null;

    protected IPMSViewBean(String iterator) {
        super();

        this.iterator = iterator;
    }

    public String getEditable() {
        return editable;
    }


    public DCIteratorBinding getIterator(String it) {
        return ViewUtils.getIteratorBinding(it);
    }

    public DCIteratorBinding getIterator() {
        return ViewUtils.getIteratorBinding(this.iterator);
    }

    public DCDataControl getDataControl(String it) {
        return getIterator(it).getDataControl();
    }

    public DCDataControl getDataControl() {
        return getIterator(this.iterator).getDataControl();
    }


    public void setEditArea(String editableArea) {
        this.editable = editableArea;
        ViewUtils.reloadUiComponent("content", "tools");
    }

    public void onEdit(ActionEvent actionEvent) {
        String target = (String) actionEvent.getComponent().getAttributes().get("target");
        this.setEditArea(target);
    }

    public void onCommit(ActionEvent actionEvent) {
        getDataControl(this.iterator).commitTransaction();
        this.editable = null;

        ViewUtils.reloadUiComponent("content", "tools");
    }

    public void onRollback(ActionEvent actionEvent) {
        rollback(this.iterator);
    }

    public void onRollback(String it) {
        rollback(it);
    }

    protected void rollback() {
        rollback(this.iterator);
    }

    protected void rollback(String it) {
        getDataControl(it).rollbackTransaction();
        /*Row row = ViewUtils.getIteratorBinding(iterator).getCurrentRow();
        row.refresh(Row.REFRESH_UNDO_CHANGES|Row.REFRESH_REMOVE_NEW_ROWS|Row.REFRESH_CONTAINEES);*/

        if (this.editable != null) {
            UIComponent root = ViewUtils.getUiComponent(this.editable);
            ResetUtils.reset(root);
        }

        this.editable = null;
        if (ViewUtils.getUiComponent("content") != null && ViewUtils.getUiComponent("tools") != null) {
            ViewUtils.reloadUiComponent("content", "tools");
        }
    }

    public void onPoll(PollEvent pollEvent) {
        refresh(false);
    }

    protected void refresh(boolean forced) {
        IPMSViewRowImpl row = (IPMSViewRowImpl) ViewUtils.getIteratorBinding(iterator).getCurrentRow();
        if (row == null || editable != null) {
            return;
        }

        row.refresh();

        ViewUtils.reloadUiComponent("tools", "syncmsg");
    }

    public String onRefresh() {
        refresh(true);

        return null;
    }

    public void onPopupSubmit(DialogEvent event) {
        getDataControl().commitTransaction();
    }

    public void onPopupCancel(PopupCanceledEvent event) {
        rollback();
    }

    public void onRoles(DialogEvent event) {
        UtilitiesBean.setBaCode("ProgramRoles");
        onPopupSubmit(event);
        ((ProgramViewRow) getIterator().getCurrentRow()).sendRoles((String) ViewUtils.runValueEl("#{pageFlowScope.projectType}"));
        UtilitiesBean.setBaCode(null);
    }

    public void onRoleAdd(ActionEvent event) {
        ViewUtils.runMethodEl("#{bindings.UserRoleCreateInsert.execute}");
    }

    
    public void onCommitRoles (ActionEvent actionEvent) {
        UtilitiesBean.setBaCode("ProgramRoles");
        getDataControl().commitTransaction();
        try {
            ((ProgramViewRow) getIterator().getCurrentRow())
                .sendRoles((String) ViewUtils.runValueEl("#{pageFlowScope.projectType}"));
        } catch (JboException e) {
            FacesMessage fm = new FacesMessage(e.getMessage());
            FacesContext.getCurrentInstance().addMessage(null, fm);
        }
        UtilitiesBean.setBaCode(null);   
    }
    
    public void onRollbackRoles (ActionEvent actionEvent) {
        rollback();
    }
    
    public void filterRoles() {
          String projectType = (String) ViewUtils.runValueEl("#{pageFlowScope.projectType}");

          UserRoleView urVO = (UserRoleView) ViewUtils.getIteratorBinding("UserRoleViewIterator").getViewObject();
          if ("D3Tr".equals(projectType)) {
              urVO.setRoleNameVar2("ProjectViewAssignedD3Tr");
          } else {
              urVO.setRoleNameVar2("ProgramViewAssigned" + ViewUtils.runValueEl("#{pageFlowScope.projectType}"));
          }

}


}
