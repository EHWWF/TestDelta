package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSViewObjectImpl;

import com.bayer.ipms.model.views.common.QplanMilestonesView;

import java.sql.PreparedStatement;
import java.sql.ResultSet;

import java.sql.SQLException;

import oracle.jbo.JboException;
import oracle.jbo.server.ViewRowImpl;
import oracle.jbo.server.ViewRowSetImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Mon Sep 22 12:51:08 CEST 2014
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class QplanMilestonesViewImpl extends IPMSViewObjectImpl implements QplanMilestonesView {
    /**
     * This is the default constructor (do not remove).
     */
    public QplanMilestonesViewImpl() {
    }

    public Boolean isMilestonesInSequence(String projectId) {
        PreparedStatement st = null;
        ResultSet results = null;

        try {
            st = getDBTransaction().createPreparedStatement("select GENERIC_TIMELINES_PKG.IS_MILESTONES_IN_SEQUENCE(?) from dual", 0);
            st.setString(1, projectId);
            results = st.executeQuery();

            if (results != null && results.next())
                // Check integer value of the 1st result column in the first row
                return results.getInt(1) == 1;
        } catch (SQLException e) {
            throw new JboException(e);
        } finally {
            try {
                st.close();
            } catch (Exception exc) {
                // nothing to do
            }
        }

        return false;
    }

    /**
     * Returns the bind variable value for ProjectIdVar.
     * @return bind variable value for ProjectIdVar
     */
    public String getProjectIdVar() {
        return (String)getNamedWhereClauseParam("ProjectIdVar");
    }

    /**
     * Sets <code>value</code> for bind variable ProjectIdVar.
     * @param value value to bind as ProjectIdVar
     */
    public void setProjectIdVar(String value) {
        setNamedWhereClauseParam("ProjectIdVar", value);
    }
}
