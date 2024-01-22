package com.bayer.ipms.model.views.client;

import com.bayer.ipms.model.views.common.ProgramViewRow;

import com.bayer.ipms.model.views.common.ProjectViewRow;

import java.util.Map;
import java.util.Set;

import oracle.jbo.RowIterator;
import oracle.jbo.RowSet;
import oracle.jbo.client.remote.RowImpl;
import oracle.jbo.domain.Date;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Mon Jan 21 16:47:32 EET 2013
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ProgramViewRowClient extends RowImpl implements ProgramViewRow {
    /**
     * This is the default constructor (do not remove).
     */
    public ProgramViewRowClient() {
    }


    public Map getProjects() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getProjects", null, null);
        return (Map)_ret;
    }


    public Set getRoles(String user) {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getRoles", new String[] { "java.lang.String" }, new Object[] { user });
        return (Set)_ret;
    }


    public void sendRoles() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "sendRoles", null, null);
        return;
    }


    public RowIterator getProjectTimelineView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getProjectTimelineView", null, null);
        return (RowIterator) _ret;
    }

    public RowIterator getProjectView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getProjectView", null, null);
        return (RowIterator) _ret;
    }

   

    public RowSet getRoleView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getRoleView", null, null);
        return (RowSet) _ret;
    }

   

    public RowIterator getSandboxView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getSandboxView", null, null);
        return (RowIterator) _ret;
    }

    public RowSet getUserView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getUserView", null, null);
        return (RowSet) _ret;
    }

    public Set<String> getUsers(String role) {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getUsers", new String[] {
                                                                         "java.lang.String" }, new Object[] { role });
        return (Set<String>) _ret;
    }

    public boolean isBusy() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "isBusy", null, null);
        return ((Boolean) _ret).booleanValue();
    }

    public boolean isRecycleBin() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "isRecycleBin", null, null);
        return ((Boolean) _ret).booleanValue();
    }

    public void receive() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "receive", null, null);
        return;
    }

    public void refresh() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "refresh", null, null);
        return;
    }

    public void remove() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "remove", null, null);
        return;
    }

    public void send() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "send", null, null);
        return;
    }

    public void sendRoles(String projectType) {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "sendRoles", new String[] {
                                                                         "java.lang.String" }, new Object[] {
                                                                         projectType });
        return;
    }

    public void unlock() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "unlock", null, null);
        return;
    }

    public String getCode() {
        return (String) getAttribute("Code");
    }

    public Integer getHasInactiveProjects() {
        return (Integer) getAttribute("HasInactiveProjects");
    }

    public String getId() {
        return (String) getAttribute("Id");
    }

    public String getName() {
        return (String) getAttribute("Name");
    }

    public String getQualifiedName() {
        return (String) getAttribute("QualifiedName");
    }

    public Date getSyncDate() {
        return (Date) getAttribute("SyncDate");
    }

    public Date getUpdateDate() {
        return (Date) getAttribute("UpdateDate");
    }

    public void setName(String value) {
        setAttribute("Name", value);
    }
}
