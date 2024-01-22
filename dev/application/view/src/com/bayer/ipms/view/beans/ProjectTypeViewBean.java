package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.utils.ModelUtils;
import com.bayer.ipms.model.views.common.ProgramView;
import com.bayer.ipms.model.views.common.ProgramViewRow;
import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.model.views.common.RoleView;
import com.bayer.ipms.model.views.common.UserRoleView;
import com.bayer.ipms.model.views.common.UserRoleViewRow;
import com.bayer.ipms.view.utils.ViewUtils;
import com.bayer.ipms.view.base.IPMSBean;

import com.bayer.ipms.view.base.IPMSViewBean;
import com.bayer.ipms.view.events.ContextualEventHandler;

import javax.faces.event.ActionEvent;
import javax.faces.event.ActionListener;

import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.share.ADFContext;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;
import oracle.adf.view.rich.render.ClientEvent;

import oracle.adf.view.rich.util.ResetUtils;

import oracle.jbo.Row;
import oracle.jbo.RowSet;
import oracle.jbo.ViewCriteriaManager;
import oracle.jbo.domain.Date;
import oracle.jbo.uicli.binding.JUEventBinding;

import org.apache.myfaces.trinidad.event.PollEvent;
import org.apache.myfaces.trinidad.event.ReturnEvent;

public class ProjectTypeViewBean extends IPMSViewBean {
    public ProjectTypeViewBean() {
        super("ProgramViewIterator");
    }

    public void onProgramRolesPopupFetch(PopupFetchEvent event) {
        filterRoles();
    }
    
    
    public String getProgramIdForTeamMembers() {
        return (String)ViewUtils.runValueEl("#{bindings.Id.inputValue}");
    }


    public String getProjectTypeForTeamMembers() {
        return (String)ViewUtils.runValueEl("#{pageFlowScope.projectType}");
    }
}
