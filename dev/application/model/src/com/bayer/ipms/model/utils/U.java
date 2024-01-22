package com.bayer.ipms.model.utils;

import com.bayer.ipms.model.base.IPMSApplicationModule;

import oracle.jbo.server.DBTransaction;


public class U {
    
    public static void o(Object param){
        
        System.out.println("******************************** Debug Output: "+param.toString());
        };
    
    public static void o(Object param,IPMSApplicationModule appModule,String subject){
        
        o(param);
        appModule.runStatement("begin log_pkg.catch(?,?,?); end;", false, subject,param.toString(),null);
        
        };
    
}
