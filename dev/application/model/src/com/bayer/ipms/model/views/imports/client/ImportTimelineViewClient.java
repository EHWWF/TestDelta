package com.bayer.ipms.model.views.imports.client;

import com.bayer.ipms.model.views.imports.common.ImportTimelineView;

import oracle.jbo.client.remote.ViewUsageImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue Mar 04 18:06:27 EET 2014
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ImportTimelineViewClient extends ViewUsageImpl implements ImportTimelineView {
    /**
     * This is the default constructor (do not remove).
     */
    public ImportTimelineViewClient() {
    }


    public void setFailedVar(String value) {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this,"setFailedVar",new String [] {"java.lang.String"},new Object[] {value});
        return;
    }

    public void setStatusVar(String value) {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this,"setStatusVar",new String [] {"java.lang.String"},new Object[] {value});
        return;
    }

    public void setStudyRelatedVar(String value) {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this,"setStudyRelatedVar",new String [] {"java.lang.String"},new Object[] {value});
        return;
    }

    public void setStudyVar(String value) {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this,"setStudyVar",new String [] {"java.lang.String"},new Object[] {value});
        return;
    }
}