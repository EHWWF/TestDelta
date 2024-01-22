package com.bayer.ipms.model.services;

import com.bayer.ipms.model.base.IPMSApplicationModuleImpl;
import com.bayer.ipms.model.services.common.PrivateAppModule;

import java.sql.PreparedStatement;
import java.sql.SQLException;

import oracle.adf.share.ADFContext;
import oracle.adf.share.security.SecurityContext;

import oracle.jbo.JboException;
import oracle.jbo.Session;
import oracle.jbo.server.ApplicationModuleImpl;
import oracle.jbo.server.DBTransaction;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed Oct 16 16:10:53 EEST 2013
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class PrivateAppModuleImpl extends IPMSApplicationModuleImpl implements PrivateAppModule {
    /**
     * This is the default constructor (do not remove).
     */
    public PrivateAppModuleImpl() {
    }

    @Override
    protected void prepareSession(Session session) {
        super.prepareSession(session);

        ADFContext adfContext = ADFContext.getCurrent();
        SecurityContext securityContext = adfContext.getSecurityContext();
        String userName = securityContext.getUserName();

        PreparedStatement st = null;
        try {
            st =
                getDBTransaction().createPreparedStatement("begin user_pkg.set_current_user(?); end;",
                                                           DBTransaction.LOCK_NONE);
            st.setString(1, userName);
            st.executeUpdate();
            getDBTransaction().commit();
        } catch (SQLException e) {
            throw new JboException(e);
        } finally {
            try {
                st.close();
            } catch (Exception exc) {
                // nothing to do
            }
        }
    }

    /**
     * Container's getter for ImportAppModule.
     * @return ImportAppModule
     */
    public ApplicationModuleImpl getImportAppModule() {
        return (ApplicationModuleImpl) findApplicationModule("ImportAppModule");
    }

    /**
     * Container's getter for ProgramAppModule.
     * @return ProgramAppModule
     */
    public ApplicationModuleImpl getProgramAppModule() {
        return (ApplicationModuleImpl) findApplicationModule("ProgramAppModule");
    }

    /**
     * Container's getter for WorkspaceAppModule.
     * @return WorkspaceAppModule
     */
    public ApplicationModuleImpl getWorkspaceAppModule() {
        return (ApplicationModuleImpl) findApplicationModule("WorkspaceAppModule");
    }

    /**
     * Container's getter for ManagementAppModule.
     * @return ManagementAppModule
     */
    public ApplicationModuleImpl getManagementAppModule() {
        return (ApplicationModuleImpl) findApplicationModule("ManagementAppModule");
    }

    /**
     * Container's getter for EstimatesAppModule.
     * @return EstimatesAppModule
     */
    public ApplicationModuleImpl getEstimatesAppModule() {
        return (ApplicationModuleImpl) findApplicationModule("EstimatesAppModule");
    }

    /**
     * Container's getter for ReportAppModule.
     * @return ReportAppModule
     */
    public ApplicationModuleImpl getReportAppModule() {
        return (ApplicationModuleImpl) findApplicationModule("ReportAppModule");
    }


    public String getName() {
        return super.getName();
    }
}