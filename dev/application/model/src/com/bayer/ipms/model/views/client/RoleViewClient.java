package com.bayer.ipms.model.views.client;

import com.bayer.ipms.model.views.common.RoleView;

import java.util.Set;

import oracle.jbo.client.remote.ViewUsageImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Sep 05 18:32:40 EEST 2014
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class RoleViewClient extends ViewUsageImpl implements RoleView {
    /**
     * This is the default constructor (do not remove).
     */
    public RoleViewClient() {
    }

    public Set getRoles(String right) {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this,"getRoles",new String [] {"java.lang.String"},new Object[] {right});
        return (Set)_ret;
    }
}