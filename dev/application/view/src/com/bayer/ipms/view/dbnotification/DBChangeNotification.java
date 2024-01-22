package com.bayer.ipms.view.dbnotification;

import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.Properties;

import oracle.jdbc.OracleConnection;
import oracle.jdbc.OracleStatement;
import oracle.jdbc.dcn.DatabaseChangeRegistration;

public class DBChangeNotification {


    public DBChangeNotification() {
        super();
    }


    public void subscribeForDBChanges(CountDownLatchEx latch, String query) throws SQLException, Exception {

        OracleConnection conn = PromisDBResource.getConnection();
        Properties prop = new Properties();
        prop.setProperty(OracleConnection.DCN_NOTIFY_ROWIDS, "true");
        prop.setProperty(OracleConnection.DCN_QUERY_CHANGE_NOTIFICATION, "true");
        DatabaseChangeRegistration dcr = conn.registerDatabaseChangeNotification(prop);
        latch.setDcr(dcr);
        DBChangeNotificationListener listener = new DBChangeNotificationListener(this, latch);
        dcr.addListener(listener);

        OracleStatement stmt = (OracleStatement) conn.createStatement();
        stmt.setDatabaseChangeRegistration(dcr);

        ResultSet rs = stmt.executeQuery(query);

        rs.close();
        stmt.close();
        conn.close();
    }

}
