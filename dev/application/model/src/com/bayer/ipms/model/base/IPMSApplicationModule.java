package com.bayer.ipms.model.base;

import java.util.ArrayList;
import java.util.Map;

import oracle.jbo.server.DBTransaction;

public interface IPMSApplicationModule {
   void runStatement(String stt, boolean commit, String... args);
   void runStatement(String stt, boolean commit, ArrayList<Map<String, Object>> pars);
    public DBTransaction getDBTransaction();
   
}
