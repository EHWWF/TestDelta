package com.bayer.ipms.model.base;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import java.sql.Types;

import oracle.adf.share.logging.ADFLogger;

import oracle.jbo.JboException;
import oracle.jbo.server.ViewRowImpl;

public class IPMSViewRowImpl extends ViewRowImpl {
    protected final ADFLogger logger = ADFLogger.createADFLogger(getClass()); 
    
    public IPMSViewRowImpl() {
        super();
    }
    
    /**
     * The method executes the given PLSQL statement with a function call.
     * Assumptions: It is assumed that the SQL statement has first '?' as result parameter
     * Example of the PLSQL statement: begin ? := import_pkg.launch(?, ?, ?); end;
     * @param <ResultType> represents Java type to which the PLSQL function result is casted
     * @param stt PLSQL statement with function call
     * @param commit 
     * @param args array of parameters for the PLSQL function
     * @return the result of the PLSQL function call casted to the ResultType java type
     */
    public <ResultType> ResultType executeFunction(String stt, boolean commit, String... args) {
        CallableStatement st = null;
        ResultType result = null;

        try {
            st = getDBTransaction().createCallableStatement(stt, 0);
            
            st.registerOutParameter(1, Types.NVARCHAR);
            
            for (int i = 0; i < args.length; i++) {
                st.setString(i + 2, args[i]);
            }
            st.execute();
            if (commit) {
                getDBTransaction().commit();
            }
            
            result = (ResultType) st.getObject(1);
        } catch (SQLException e) {
            throw new JboException(e);
        } finally {
            try {
                st.close();
            } catch (Exception exc) {
                // nothing to do
            }
        }
        
        return result;
    }

    protected void runStatement(String stt, boolean commit, String... args) {
        PreparedStatement st = null;

        try {
            st = getDBTransaction().createPreparedStatement(stt, 0);
            for (int i = 0; i < args.length; i++) {
                st.setString(i + 1, args[i]);
            }
            st.execute();
            if (commit) {
                getDBTransaction().commit();
            }
        } catch (SQLException e) {
            throw new JboException(e);
        } finally {
            try {
                st.close();
            } catch (Exception exc) {
                // nothing to do
            }
        }
    }

    public void refresh() {
        this.refresh(REFRESH_WITH_DB_FORGET_CHANGES);
    }
}
