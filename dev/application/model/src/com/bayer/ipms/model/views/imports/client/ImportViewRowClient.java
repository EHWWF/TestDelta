package com.bayer.ipms.model.views.imports.client;

import com.bayer.ipms.model.views.imports.common.ImportViewRow;

import oracle.jbo.client.remote.RowImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Mon Sep 16 08:36:15 EEST 2013
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ImportViewRowClient extends RowImpl implements ImportViewRow {
    /**
     * This is the default constructor (do not remove).
     */
    public ImportViewRowClient() {
    }


    public void cancel() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "cancel", null, null);
        return;
    }

    public void finish() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "finish", null, null);
        return;
    }

    public Integer launch(String projectId, short importType, boolean isManual) {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this, "launch",
                                                               new String[] { "java.lang.String", "short", "boolean" },
                                                               new Object[] { projectId, new Short(importType),
                                                                              new Boolean(isManual) });
        return (Integer) _ret;
    }

    public void refresh() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "refresh", null, null);
        return;
    }

    public void start() {
        Object _ret = getApplicationModuleProxy().riInvokeExportedMethod(this, "start", null, null);
        return;
    }

    public String getId() {
        return (String) getAttribute("Id");
    }

    public String getStatusCode() {
        return (String) getAttribute("StatusCode");
    }
}
