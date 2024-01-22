package com.redsam.audit.dms;

/**
 * Red Samurai Audit. Version 4.0
 */
public enum DmsConstants {
    
//    BINDING_FILTER("oracle.dms:name=/oracle/adf/model/servlet/ADFBindingFilter,type=ADF", new String[]{"doFilter_avg", "doFilter_maxActive", "doFilter_completed" }, false),
//        JDBC_DATASOURCE("com.bea:*,Type=JDBCDataSourceRuntime", new String[] {"CurrCapacity", "CurrCapacityHighCount", "ConnectionDelayTime" }, true);    
//        String[] attributes = null;
        
    
    
    BINDING_FILTER("oracle.dms:name=/oracle/adf/model/servlet/ADFBindingFilter,type=ADF"),
    SPY("oracle.dms:name=AggreSpy,type=Spy"),
    TF("oracle.dms:type=ADFc_Taskflow,*"),
    JDBC_DATASOURCE("com.bea:*,Type=JDBCDataSourceRuntime");    
    
    private String mbean;

    DmsConstants(String mbean) {
        this.mbean = mbean;
        
    }
    public String getMbean() {
        return mbean;
    }
    
}
