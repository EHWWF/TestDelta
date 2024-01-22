package com.redsam.audit;

import oracle.jbo.server.EntityImpl;
import oracle.jbo.server.TransactionEvent;

/**
 * Red Samurai Audit. Version 4.0
 */
public class RedsamAuditEOImpl extends EntityImpl {
    
    public RedsamAuditEOImpl() {
        super();
    }


    /**
     * Incrementing statistic counters
     * @param i
     * @param transactionEvent
     */
    protected void doDML(int i, TransactionEvent transactionEvent) {
        super.doDML(i, transactionEvent);
        
        if (!LogManager.isAuditDisabled) {
            String amName =
                transactionEvent.getDBTransaction().getRootApplicationModule().getFullName();
            if (i == DML_DELETE) {
                LogManager.incrementStats(amName, STATS.DELETES);
            } else if (i == DML_INSERT) {
                LogManager.incrementStats(amName, STATS.INSERTS);
            } else if (i == DML_UPDATE) {
                LogManager.incrementStats(amName, STATS.UPDATES);
            }
        }
    }
}
