package com.bayer.ipms.model.views.client;

import com.bayer.ipms.model.views.common.SandboxView;

import oracle.jbo.client.remote.ViewUsageImpl;
import oracle.jbo.server.TransactionEvent;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri May 08 13:52:34 EEST 2015
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class SandboxViewClient extends ViewUsageImpl implements SandboxView {
    /**
     * This is the default constructor (do not remove).
     */
    public SandboxViewClient() {
    }

    public void removeCriteria(String criteria) {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this,"removeCriteria",new String [] {"java.lang.String"},new Object[] {criteria});
        return;
    }

    public void beforeRollback(TransactionEvent TransactionEvent) {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this,"beforeRollback",new String [] {"oracle.jbo.server.TransactionEvent"},new Object[] {TransactionEvent});
        return;
    }

    public void applyCriteria(String criteria) {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this,"applyCriteria",new String [] {"java.lang.String"},new Object[] {criteria});
        return;
    }

    public void afterRollback(TransactionEvent TransactionEvent) {
        Object _ret =
            getApplicationModuleProxy().riInvokeExportedMethod(this,"afterRollback",new String [] {"oracle.jbo.server.TransactionEvent"},new Object[] {TransactionEvent});
        return;
    }
}
