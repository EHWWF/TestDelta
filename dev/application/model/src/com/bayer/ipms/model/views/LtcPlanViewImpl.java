package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSViewObjectImpl;


import com.bayer.ipms.model.views.common.LtcPlanView;

import oracle.jbo.Row;
import oracle.jbo.server.AssociationDefImpl;
import oracle.jbo.server.ViewObjectImpl;
import oracle.jbo.server.ViewRowSetImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue May 05 10:23:42 EEST 2015
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class LtcPlanViewImpl extends IPMSViewObjectImpl implements LtcPlanView {
    /**
     * This is the default constructor (do not remove).
     */
    public LtcPlanViewImpl() {
    }

    @Override
    protected ViewRowSetImpl createViewLinkAccessorRS(AssociationDefImpl assocDef, ViewObjectImpl accessorVO,
                                                      Row masterRow, Object[] values) {

        if ("LtcValueView".equals(assocDef.getName())) {
            accessorVO.clearCache();
        } else if ("LtciIdLtcPlanView".equals(assocDef.getName())) {
            LtcPlanView LtcPlanVo = (LtcPlanView) accessorVO;
            LtcPlanVo.setSearchStudyRelatedVar(getSearchStudyRelatedVar());
            LtcPlanVo.setSearchLtcvExistsVar(getSearchLtcvExistsVar());
            LtcPlanVo.setSearchFcExistsVar(getSearchFcExistsVar());
        }


        return super.createViewLinkAccessorRS(assocDef, accessorVO, masterRow, values);

    }

    /**
     * Returns the bind variable value for SearchLtcvExistsVar.
     * @return bind variable value for SearchLtcvExistsVar
     */
    public String getSearchLtcvExistsVar() {
        return (String) getNamedWhereClauseParam("SearchLtcvExistsVar");
    }

    /**
     * Sets <code>value</code> for bind variable SearchLtcvExistsVar.
     * @param value value to bind as SearchLtcvExistsVar
     */
    public void setSearchLtcvExistsVar(String value) {
        ensureVariableManager().setVariableValue("SearchLtcvExistsVar", value);
    }

    /**
     * Returns the bind variable value for SearchFcExistsVar.
     * @return bind variable value for SearchFcExistsVar
     */
    public String getSearchFcExistsVar() {
        return (String) getNamedWhereClauseParam("SearchFcExistsVar");
    }

    /**
     * Sets <code>value</code> for bind variable SearchFcExistsVar.
     * @param value value to bind as SearchFcExistsVar
     */
    public void setSearchFcExistsVar(String value) {
        ensureVariableManager().setVariableValue("SearchFcExistsVar", value);
    }

    /**
     * Returns the bind variable value for SearchStudyRelatedVar.
     * @return bind variable value for SearchStudyRelatedVar
     */
    public String getSearchStudyRelatedVar() {
        return (String) getNamedWhereClauseParam("SearchStudyRelatedVar");
    }

    /**
     * Sets <code>value</code> for bind variable SearchStudyRelatedVar.
     * @param value value to bind as SearchStudyRelatedVar
     */
    public void setSearchStudyRelatedVar(String value) {

        ensureVariableManager().setVariableValue("SearchStudyRelatedVar", value);
    }
}
