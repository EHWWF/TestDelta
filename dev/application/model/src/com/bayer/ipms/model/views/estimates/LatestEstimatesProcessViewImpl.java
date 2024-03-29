package com.bayer.ipms.model.views.estimates;

import com.bayer.ipms.model.base.IPMSViewObjectImpl;
import com.bayer.ipms.model.views.estimates.common.LatestEstimatesProcessView;
import com.bayer.ipms.model.views.estimates.common.LatestEstimatesProcessViewRow;

import oracle.jbo.NameValuePairs;
import oracle.jbo.RowIterator;
import oracle.jbo.server.RowFinder;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed Oct 07 11:17:42 EEST 2015
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class LatestEstimatesProcessViewImpl extends IPMSViewObjectImpl implements LatestEstimatesProcessView {
    /**
     * This is the default constructor (do not remove).
     */
    public LatestEstimatesProcessViewImpl() {
    }

    /**
     * Returns the variable value for ProcessId.
     * @return variable value for ProcessId
     */
    public String getProcessId() {
        return (String) ensureVariableManager().getVariableValue("ProcessId");
    }

    /**
     * Sets <code>value</code> for variable ProcessId.
     * @param value value to bind as ProcessId
     */
    public void setProcessId(String value) {
        ensureVariableManager().setVariableValue("ProcessId", value);
    }

    public LatestEstimatesProcessViewRow getRowById(String id) {

        RowFinder rf = this.lookupRowFinder("RowById");
        NameValuePairs nvp = new NameValuePairs();
        nvp.setAttribute("Id", id);
        RowIterator ri = rf.execute(nvp, this);

        return (LatestEstimatesProcessViewRow) ri.next();
    }

    public Boolean isNextYearProcessAvailable(String letId) {

        RowFinder rf = this.lookupRowFinder("NextYearProcesses");
        NameValuePairs nvp = new NameValuePairs();
        nvp.setAttribute("LetId", letId);
        nvp.setAttribute("IsNextYear", true);
        RowIterator ri = rf.execute(nvp, this);

        return (Boolean) ri.hasNext();
    }


    /**
     * Returns the variable value for LetIdVar.
     * @return variable value for LetIdVar
     */
    public String getLetIdVar() {
        return (String) ensureVariableManager().getVariableValue("LetIdVar");
    }

    /**
     * Sets <code>value</code> for variable LetIdVar.
     * @param value value to bind as LetIdVar
     */
    public void setLetIdVar(String value) {
        ensureVariableManager().setVariableValue("LetIdVar", value);
    }

    /**
     * Returns the variable value for IsNextYearVar.
     * @return variable value for IsNextYearVar
     */
    public Boolean getIsNextYearVar() {
        return (Boolean) ensureVariableManager().getVariableValue("IsNextYearVar");
    }

    /**
     * Sets <code>value</code> for variable IsNextYearVar.
     * @param value value to bind as IsNextYearVar
     */
    public void setIsNextYearVar(Boolean value) {
        ensureVariableManager().setVariableValue("IsNextYearVar", value);
    }
}

