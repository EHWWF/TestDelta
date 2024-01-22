package com.bayer.ipms.model.base;

import com.redsam.audit.RedsamAuditEOImpl;

import oracle.adf.share.logging.ADFLogger;

import oracle.jbo.server.TransactionEvent;

public class IPMSEntityImpl extends RedsamAuditEOImpl {
    protected final ADFLogger logger = ADFLogger.createADFLogger(getClass()); 
    
    public IPMSEntityImpl() {
        super();
    }

    @Override
    protected void doDML(int i, TransactionEvent transactionEvent) {
        super.doDML(i, transactionEvent);
    }
    
    @Override
    public void lock() {
        try {
            super.lock();
        } catch (oracle.jbo.RowInconsistentException e) {
            if (e.getErrorCode().equals("25014")) {
                super.lock();
            } else
                throw e;
        }
    }


    @Override
    public void setNewRowState(byte b) {
     logger.warning("setNewRowState called, state: " + b + " +, EO: " + this.getEntityDef().getName() + ", key:" + this.getKey());
        super.setNewRowState(b);
    }
}
