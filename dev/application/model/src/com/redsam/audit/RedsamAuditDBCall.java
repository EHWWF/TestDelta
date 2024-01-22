package com.redsam.audit;

import oracle.adf.share.ADFContext;

/**
 * Red Samurai Audit. Version 4.0
 */
public class RedsamAuditDBCall {
    
    public RedsamAuditDBCall() {
        super();
    }
    
    public static long startTime() {
        if (!LogManager.isAuditDisabled) {
            return System.currentTimeMillis();
        }
        return -1;
    }
    
    public static void endTime(long startTime, String plSqlName, String details) {
        if (!LogManager.isAuditDisabled) {
            long end = System.currentTimeMillis() - startTime;
            LogManager.log(MESSAGE.SLOW_PLSQL,
                           plSqlName, end, "PL/SQL call details: " + details,
                           ADFContext.getCurrent().getSecurityContext().getUserName());
        }
    }
}
