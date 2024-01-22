package com.bayer.ipms.view.dbnotification;

import java.sql.SQLException;

import javax.naming.InitialContext;
import javax.naming.NamingException;

import javax.sql.DataSource;

import oracle.adf.share.logging.ADFLogger;

import oracle.jdbc.OracleConnection;
import oracle.jdbc.dcn.DatabaseChangeRegistration;

public class PromisDBResource {
    public PromisDBResource() {
        super();
    }

    public static OracleConnection getConnection() {

        ADFLogger logger = ADFLogger.createADFLogger(PromisDBResource.class);

        OracleConnection conn = null;
        try {
            conn =
                (OracleConnection) ((DataSource) (new InitialContext()).lookup("jdbc/IPMSDataSource")).getConnection();
            logger.finest("****** Connected to DB");
        } catch (NamingException e) {
            logger.severe("***** Datasource jdbc/IPMSDataSource was not found");
        } catch (SQLException e) {
            logger.severe("***** Unexpected error: " + e);
        }
        return conn;
    }
    
    public static void unregisterDCN(DatabaseChangeRegistration dcr){
        
            ADFLogger logger = ADFLogger.createADFLogger(PromisDBResource.class);
            
            OracleConnection conn = getConnection();

            try {
                conn.unregisterDatabaseChangeNotification(dcr);
                logger.finest("***** Database Change Registration unregistered");
            } catch (SQLException ex) {
                logger.severe("***** Unable to unregister DB Change Notification:");
                ex.printStackTrace();
            }
            try {
                conn.close();
            } catch (SQLException ex) {
                logger.severe("***** Unable to close DB connection: "+ex.getStackTrace());
            }
        }


}
