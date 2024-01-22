package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSViewObjectImpl;
import com.bayer.ipms.model.views.common.TargetProductProfileView;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Oct 21 12:04:28 EEST 2016
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class TargetProductProfileViewImpl extends IPMSViewObjectImpl implements TargetProductProfileView {
    /**
     * This is the default constructor (do not remove).
     */
    public TargetProductProfileViewImpl() {
    }

    /**
     * Returns the variable value for ProjectIdVar.
     * @return variable value for ProjectIdVar
     */
    public String getProjectIdVar() {
        return (String) ensureVariableManager().getVariableValue("ProjectIdVar");
    }

    /**
     * Sets <code>value</code> for variable ProjectIdVar.
     * @param value value to bind as ProjectIdVar
     */
    public void setProjectIdVar(String value) {
        ensureVariableManager().setVariableValue("ProjectIdVar", value);
    }
}

