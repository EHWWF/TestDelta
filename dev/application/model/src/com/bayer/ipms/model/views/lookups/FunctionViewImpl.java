package com.bayer.ipms.model.views.lookups;

import com.bayer.ipms.model.base.IPMSViewObjectImpl;
import com.bayer.ipms.model.views.lookups.common.FunctionView;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue Mar 25 14:36:58 EET 2014
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class FunctionViewImpl extends IPMSViewObjectImpl implements FunctionView {
    /**
     * This is the default constructor (do not remove).
     */
    public FunctionViewImpl() {
    }

    public void send() {
        runStatement("begin lookup_pkg.send(); end;", true);
    }
}
