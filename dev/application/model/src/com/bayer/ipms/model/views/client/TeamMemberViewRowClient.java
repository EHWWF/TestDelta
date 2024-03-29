package com.bayer.ipms.model.views.client;

import com.bayer.ipms.model.views.common.TeamMemberViewRow;

import oracle.jbo.RowIterator;
import oracle.jbo.RowSet;
import oracle.jbo.client.remote.RowImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed Feb 19 16:58:26 EET 2014
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class TeamMemberViewRowClient extends RowImpl implements TeamMemberViewRow {
    /**
     * This is the default constructor (do not remove).
     */
    public TeamMemberViewRowClient() {
    }


    public RowSet getTeamRoleView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getTeamRoleView", null, null);
        return (RowSet) _ret;
    }


    public void deleteAssignment() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "deleteAssignment", null, null);
        return;
    }

    public String[] getAssignedProjects() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getAssignedProjects", null, null);
        return (String[]) _ret;
    }

    public RowIterator getAssignmentView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getAssignmentView", null, null);
        return (RowIterator) _ret;
    }

    public RowSet getD2PrjTeamRoleView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getD2PrjTeamRoleView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getDevTeamRoleView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getDevTeamRoleView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getEmployeeView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getEmployeeView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getPrdMntTeamRoleView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getPrdMntTeamRoleView", null, null);
        return (RowSet) _ret;
    }

    public RowSet getSAMDTeamRoleView() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "getSAMDTeamRoleView", null, null);
        return (RowSet) _ret;
    }

    public void setAssignedProjects(String[] projectIds) {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "setAssignedProjects",
                                                               new String[] { "[Ljava.lang.String;" },
                                                               new Object[] { projectIds });
        return;
    }

    public void updateAssignedProjects() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "updateAssignedProjects", null, null);
        return;
    }

    public String getId() {
        return (String) getAttribute("Id");
    }
}
