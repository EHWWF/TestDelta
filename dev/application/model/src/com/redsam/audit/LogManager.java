package com.redsam.audit;

import com.redsam.audit.dms.DMSHarvester;
import com.redsam.audit.dms.domain.TaskFlowStats;

import java.sql.Clob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Timestamp;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;

import javax.management.AttributeNotFoundException;
import javax.management.InstanceNotFoundException;
import javax.management.MBeanException;
import javax.management.MBeanServer;
import javax.management.MalformedObjectNameException;
import javax.management.ObjectName;
import javax.management.ReflectionException;

import javax.naming.InitialContext;
import javax.naming.NamingException;

import javax.sql.DataSource;

import oracle.adf.share.logging.ADFLogger;

/**
 * Red Samurai Audit. Version 4.0
 */
public class LogManager {

    public static boolean isAuditDisabled = "OFF".equals(System.getProperty("redsamurai.audit"));

    public static int DEFAULT_TOLLERATED_EXEC_TIME = 5000;
    public static int DEFAULT_TOLLERATED_ACTIVATION_TIME = 500;
    public static int DEFAULT_TOLLERATED_FETCH_SIZE = 300;
    public static int DEFAULT_WAIT_ACTIVATION_TIME = 10000;
    public static int DEFAULT_WAIT_FETCH_TIME = 5000;
    public static int SAVE_INTERVAL = 20; //in seconds
    public static String SERVER_NAME;
    public static int SERVER_PORT;


    private static String diagnosticLevel;


    public static void setDiagnosticLevel(String diagnosticLevel)
    {
        if("OFF".equals(diagnosticLevel)) {
            isAuditDisabled = true;

        }
        LogManager.diagnosticLevel = diagnosticLevel;

        if (LOGGER.isWarning()) {
            LOGGER.warning("Redsamurai audit runs with diagnose level: " + diagnosticLevel);
        }

    }

    public static boolean isLowDiagnosticLevel()
    {

        if(isAuditDisabled)
            return false;

        if("VERBOSE".equals(LogManager.diagnosticLevel))
        {
            return true;
        }
        else if("MEDIUM".equals(LogManager.diagnosticLevel))
        {
            return true;
        }
        else if("LOW".equals(LogManager.diagnosticLevel))
        {
            return true;
        }

        return false;

    }

    public static boolean isMediumDiagnosticLevel()
    {

        if(isAuditDisabled)
            return false;

        if(!dbMode)
            return false;


        if("VERBOSE".equals(LogManager.diagnosticLevel))
        {
            return true;
        }
        else if("MEDIUM".equals(LogManager.diagnosticLevel))
        {
            return true;
        }
        else if("LOW".equals(LogManager.diagnosticLevel))
        {
            return false;
        }

        return false;
    }

    public static boolean isVerboseDiagnosticLevel()
    {
        if(isAuditDisabled)
            return false;

        if(!dbMode)
            return false;


        if("VERBOSE".equals(LogManager.diagnosticLevel))
        {
            return true;
        }
        else if("MEDIUM".equals(LogManager.diagnosticLevel))
        {
            return false;
        }
        else if("LOW".equals(LogManager.diagnosticLevel))
        {
            return false;
        }

        return false;
    }


    private static Timer saveStatsTimer;

    static boolean dbMode = true;

    static Collection<Map> userSessions = Collections.synchronizedList(new ArrayList());
    static Collection<Object[]> clientRequests = Collections.synchronizedList(new ArrayList());
    //each element arrays is of form:  voInstance, bindParams, ECID, sessionId
    private static Collection<Object[]> queries = Collections.synchronizedList(new ArrayList());

    private static ConcurrentHashMap<String, Map> stats = new ConcurrentHashMap<String, Map>();
    private static AtomicBoolean statsModified = new AtomicBoolean(false);


    public static ADFLogger LOGGER = ADFLogger.createADFLogger("com.redsam.audit.RedsamAuditVOImpl");
    private static final int MESSAGE_DETAIL_COLUMN_SIZE = 3500; //size of the message column in database. We will trim any message longer than max size


    public static final void logSession(Map<String, Object> sessionInfo) {
        userSessions.add(sessionInfo);
    }

    public static final void logQueries(String voInstance,
                                        Map<String, Object> bindParams,
                                        String username, String sessionId) {
        queries.add(new Object[] { voInstance, bindParams,
                oracle.adf.share.logging.internal.LoggingUtils.getECID(),
                username, sessionId });

        //debug only
        //saveQueries();
    }

    public static final void logClientRequest(String data, String username) {

        clientRequests.add(new Object[] { data, username, oracle.adf.share.logging.internal.LoggingUtils.getECID() });

        // saveClientRequestStats();
    }


    public static final void log(MESSAGE message, String component,
                                 long execTime, String messageDetail,
                                 String user) {
        messageDetail +=
                ", ECID:" + oracle.adf.share.logging.internal.LoggingUtils.getECID();
        PreparedStatement prepStmt = null;
        Connection con = null;
        try {
            con = getConnection();
            StackTraceElement[] stack = Thread.currentThread().getStackTrace();
            StringBuilder sb = new StringBuilder();
            for (StackTraceElement stackTraceElement : stack) {
                sb.append(stackTraceElement.getClassName() + "." +
                        stackTraceElement.getMethodName() + " at line " +
                        stackTraceElement.getLineNumber() + " <br>");
            }
            String stackTrace = sb.toString();

            if (!dbMode) {
                LOGGER.warning(message + " on " + component +
                        ", Time Elapsed(ms):" + execTime + "\n" +
                        "Server Name: " + LogManager.SERVER_NAME +
                        ", Server Port: " + LogManager.SERVER_PORT + "\n" +
                        messageDetail + "\n\n Stack: " + stackTrace);
            } else {

                String sql =
                        "INSERT INTO REDSAM_AUDIT_MSG (MSG_TYPE, TIME_ELAPSED, MSG_DETAIL, MSG_DATE, COMPONENT, USERNAME, STACK_TRACE, SERVER_NAME, SERVER_PORT) VALUES ( ?, ?, ?, SYSDATE, ?, ?, ?, ?, ?)";

                prepStmt = con.prepareStatement(sql);
                prepStmt.setString(1, message.toString());
                prepStmt.setLong(2, execTime);
                String msgDetail = cropMessageIfNeeded(messageDetail);
                prepStmt.setString(3, msgDetail);
                prepStmt.setString(4, component);
                prepStmt.setString(5, user);

                Clob clob = con.createClob();
                clob.setString(1, stackTrace);
                prepStmt.setClob(6, clob);
                prepStmt.setString(7, LogManager.SERVER_NAME);
                prepStmt.setInt(8, LogManager.SERVER_PORT);

                prepStmt.execute();
            }
        } catch (SQLException e) {
            LOGGER.severe(" unexpected error when logging: " + message +
                    " on " + component + ", Time Elapsed(ms):" +
                    execTime + "\n" +
                    messageDetail);
            LOGGER.severe(e);
        } finally {
            try {
                if (prepStmt != null)
                    prepStmt.close();

                if (con != null)
                    con.close();
            } catch (SQLException ex) { //ignore exception

            }
        }

    }

    /**
     * In case the message is too long, we crop the first part of it.
     * The reason we crop the first part and not the last is because
     * WHERE clause is more important than SELECT clause
     * @param messageDetail
     * @return
     */
    private static String cropMessageIfNeeded(String messageDetail) {

        if (messageDetail != null &&
                messageDetail.length() > MESSAGE_DETAIL_COLUMN_SIZE) {
            return messageDetail.substring(messageDetail.length() -
                            MESSAGE_DETAIL_COLUMN_SIZE,
                    messageDetail.length());
        }
        return messageDetail;

    }

    static final Timestamp getSysdate() {
        Connection con = getConnection();
        Timestamp returnVal = null;
        if (!dbMode) {
            LOGGER.warning("Failed to read log parameters from DB" + "\n");
        } else {
            PreparedStatement prepStmt = null;

            String sql = "SELECT SYSDATE FROM DUAL";

            try {
                prepStmt = con.prepareStatement(sql);
                ResultSet rs = prepStmt.executeQuery();
                rs.next();
                returnVal = rs.getTimestamp(1);
                rs.close();
                prepStmt.close();

            } catch (SQLException e) {
                LOGGER.severe(e);
            } finally {
                try {
                    if (con != null)
                        con.close();
                } catch (SQLException ex) {
                }
            }
        }

        return returnVal;
    }

    static final void readLogParams() {
        try {
            InitialContext ctx = new InitialContext();
            LogManager.SERVER_NAME = System.getProperty("weblogic.Name");
            MBeanServer server =
                    (MBeanServer)ctx.lookup("java:comp/env/jmx/runtime");
            ObjectName objName =
                    new ObjectName("com.bea:Name=" + LogManager.SERVER_NAME +
                            ",Type=Server");
            LogManager.SERVER_PORT =
                    (Integer)server.getAttribute(objName, "ListenPort");
        } catch (NamingException e) {
            e.printStackTrace();
        } catch (MalformedObjectNameException e) {
            e.printStackTrace();
        } catch (MBeanException e) {
            e.printStackTrace();
        } catch (AttributeNotFoundException e) {
            e.printStackTrace();
        } catch (InstanceNotFoundException e) {
            e.printStackTrace();
        } catch (ReflectionException e) {
            e.printStackTrace();
        }

        HashMap<String, String> logParams = new HashMap<String, String>(3);
        Connection con = getConnection();
        if (!dbMode) {
            LOGGER.warning("Failed to read log parameters from DB" + "\n");
        } else {
            PreparedStatement prepStmt = null;

            String sql = "SELECT * FROM REDSAM_AUDIT_PARAMS";

            try {
                prepStmt = con.prepareStatement(sql);
                ResultSet rs = prepStmt.executeQuery();
                rs.next();

                ResultSetMetaData rsmeta = rs.getMetaData();
                int columnCount = rsmeta.getColumnCount();
                for (int i = 1; i <= columnCount; i++) {
                    String columnName = rsmeta.getColumnName(i);
                    logParams.put(columnName.toLowerCase(),
                            rs.getString(columnName));
                }

                LOGGER.warning("DATABASE AUDIT LOG ENABLED! Using threshold configuration: " + logParams + "\n");
                rs.close();
                prepStmt.close();

                sql = "SELECT SERVER_NAME, SERVER_PORT FROM REDSAM_AUDIT_SERVERS WHERE SERVER_NAME = ? AND SERVER_PORT = ?";
                prepStmt = con.prepareStatement(sql);
                prepStmt.setString(1, LogManager.SERVER_NAME);
                prepStmt.setInt(2, LogManager.SERVER_PORT);
                rs = prepStmt.executeQuery();
                boolean serverLogged = rs.next();
                rs.close();
                prepStmt.close();

                if (serverLogged == false) {
                    sql = "INSERT INTO REDSAM_AUDIT_SERVERS (SERVER_NAME, SERVER_PORT) VALUES (?, ?)";
                    con.setAutoCommit(false);
                    prepStmt = con.prepareStatement(sql);
                    prepStmt.setString(1, LogManager.SERVER_NAME);
                    prepStmt.setInt(2, LogManager.SERVER_PORT);
                    prepStmt.executeUpdate();

                    con.commit();
                    prepStmt.close();
                }
            } catch (Exception e) {
                LOGGER.severe(e);
                //dbMode = false;

            } finally {
                try {
                    if (con != null)
                        con.close();
                } catch (SQLException ex) {
                }

            }
        }

        if (logParams.get("tet") != null) {
            try {
                LogManager.DEFAULT_TOLLERATED_EXEC_TIME =
                        Integer.parseInt(logParams.get("tet"));
            } catch (NumberFormatException nfe) {
                nfe.printStackTrace();
            }
        }
        if (logParams.get("tat") != null) {
            try {
                LogManager.DEFAULT_TOLLERATED_ACTIVATION_TIME =
                        Integer.parseInt(logParams.get("tat"));
            } catch (NumberFormatException nfe) {
                nfe.printStackTrace();
            }
        }
        if (logParams.get("tfs") != null) {
            try {
                LogManager.DEFAULT_TOLLERATED_FETCH_SIZE =
                        Integer.parseInt(logParams.get("tfs"));
            } catch (NumberFormatException nfe) {
                nfe.printStackTrace();
            }
        }
        if (logParams.get("si") != null) {
            try {
                LogManager.SAVE_INTERVAL =
                        Integer.parseInt(logParams.get("si"));
            } catch (NumberFormatException nfe) {
                nfe.printStackTrace();
            }
        }
        if (logParams.get("wat") != null) {
            try {
                LogManager.DEFAULT_WAIT_ACTIVATION_TIME =
                        Integer.parseInt(logParams.get("wat"));
            } catch (NumberFormatException nfe) {
                nfe.printStackTrace();
            }
        }
        if (logParams.get("wft") != null) {
            try {
                LogManager.DEFAULT_WAIT_FETCH_TIME =
                        Integer.parseInt(logParams.get("wft"));
            } catch (NumberFormatException nfe) {
                nfe.printStackTrace();
            }
        }
    }

    public static final void log(MESSAGE message, String location,
                                 String messageDetail, String user) {
        log(message, location, -1, messageDetail, user);
    }


    public static final Connection getConnection() {
        if (!dbMode)
            return null;
        InitialContext ic;
        Connection con = null;
        try {
            ic = new InitialContext();
            DataSource ds = (DataSource)ic.lookup("jdbc/RedsamAuditDS");
            con = ds.getConnection();
        } catch (NamingException e) {
            LOGGER.warning("Unable to find 'jdbc/RedsamAuditDS' datasource. Audit will use log the issue with standard ADF logging.");
            dbMode = false;
        } catch (SQLException e) {
            LOGGER.severe("Audit logging unexpected error: ", e);
        }
        return con;
    }

    static final void saveStats() {
        Connection con = getConnection();
        if (con != null) {
            String insertSql =
                    "INSERT INTO REDSAM_AUDIT_STATS (UPDATES_NO, INSERTS_NO, DELETES_NO, ACTIVATIONS_NO, APPMODULES_NO, SELECTS_NO, STATS_DATE, APPMODULE_NAME, SERVER_NAME, SERVER_PORT) VALUES ( ?, ?, ?, ?, ?, ?, SYSDATE, ?, ?, ?)";
            PreparedStatement prepInsertStmt = null;
            try {
                con.setAutoCommit(false);
                prepInsertStmt = con.prepareStatement(insertSql);
                //blocking the stats collection, until emptying it
                if (!statsModified.get()) {
                    if (LOGGER.isInfo())
                        LOGGER.info("application not used since last save, statistics not saved...");
                    return;
                }
                synchronized (stats) {
                    for (String appModuleName : stats.keySet()) {
                        HashMap<STATS, AtomicLong> statsPerModule =
                                (HashMap<STATS, AtomicLong>)stats.get(appModuleName);
                        prepInsertStmt.setLong(1,
                                statsPerModule.get(STATS.UPDATES).longValue());
                        prepInsertStmt.setLong(2,
                                statsPerModule.get(STATS.INSERTS).longValue());
                        prepInsertStmt.setLong(3,
                                statsPerModule.get(STATS.DELETES).longValue());
                        prepInsertStmt.setLong(4,
                                statsPerModule.get(STATS.ACTIVATIONS).longValue());
                        prepInsertStmt.setLong(5,
                                statsPerModule.get(STATS.AMINSTANCES).longValue());
                        prepInsertStmt.setLong(6,
                                statsPerModule.get(STATS.SELECTS).longValue());
                        prepInsertStmt.setString(7, appModuleName);
                        prepInsertStmt.setString(8, LogManager.SERVER_NAME);
                        prepInsertStmt.setInt(9, LogManager.SERVER_PORT);
                        prepInsertStmt.executeUpdate();
                        statsPerModule.get(STATS.UPDATES).set(0);
                        statsPerModule.get(STATS.INSERTS).set(0);
                        statsPerModule.get(STATS.DELETES).set(0);
                        statsPerModule.get(STATS.ACTIVATIONS).set(0);
                        statsPerModule.get(STATS.AMINSTANCES).set(0);
                        statsPerModule.get(STATS.SELECTS).set(0);
                    }
                    prepInsertStmt.close();
                    con.commit();
                }
                statsModified.getAndSet(false);

            } catch (SQLException e) {
                LOGGER.severe(e);
            } finally {
                try {
                    if (con != null)
                        con.close();
                } catch (SQLException ex) { //ignore exception
                }
            }
        }
    }


    static final void shutdown() {
        if (saveStatsTimer != null)
            saveStatsTimer.cancel();
        if (LOGGER.isInfo())
            LOGGER.info(" redsamurai audit harvester  stopped");
    }

    static final void startup() {
        readLogParams();
        if (dbMode) {
            if (LOGGER.isInfo())
                LOGGER.info("starting redsamurai audit  harvester.");
            saveStatsTimer = new Timer();
            TimerTask timerTask = new TimerTask() {
                @Override
                public void run() {
                    if (LOGGER.isInfo())
                        ;
                    long init = System.currentTimeMillis();
                    LOGGER.info("saving stats to database!!");
                    LogManager.saveStats();
                    LogManager.saveUserSessionsStats();
                    LogManager.saveDMSStats();
                    LogManager.saveClientRequestStats();
                    LogManager.saveQueries();
                    LOGGER.info("save stats to database completed in " +
                            (System.currentTimeMillis() - init) +
                            " miliseconds.");

                }
            };
            saveStatsTimer.scheduleAtFixedRate(timerTask, 5000,
                    SAVE_INTERVAL * 1000);
        }
    }


    private static final void saveUserSessionsStats() {
        if (userSessions.isEmpty()) {
            if (LOGGER.isInfo())
                LOGGER.info("no login events since last update");
            return;
        }

        if (LOGGER.isInfo())
            LOGGER.info("saveUserSessionsStats starts");
        Connection con = getConnection();
        PreparedStatement prepInsertStmt = null;
        PreparedStatement prepUpdateStmt = null;
        String insertSql =
                "INSERT INTO REDSAM_AUDIT_SESSIONS (SESSION_ID, USERNAME, LOGIN_AT, LOGOUT_AT, SERVER_NAME, SERVER_PORT) VALUES ( ?, ?, ?, ?, ?, ?)";
        String updateSql =
                "UPDATE REDSAM_AUDIT_SESSIONS SET LOGOUT_AT = ? WHERE SESSION_ID = ? ";
        if (con != null) {
            try {
                prepInsertStmt = con.prepareStatement(insertSql);
                prepUpdateStmt = con.prepareStatement(updateSql);
                synchronized (userSessions) {
                    con.setAutoCommit(false);
                    Iterator it = userSessions.iterator();
                    while (it.hasNext()) {
                        Map<String, Object> sessionInfo = (Map)it.next();

                        if (Boolean.TRUE.equals(sessionInfo.get("loginEvent"))) {

                            prepInsertStmt.setString(1,
                                    (String)sessionInfo.get("sessionId"));
                            prepInsertStmt.setString(2,
                                    (String)sessionInfo.get("username"));
                            prepInsertStmt.setTimestamp(3,
                                    (java.sql.Timestamp)sessionInfo.get("loggedOn"));
                            prepInsertStmt.setTimestamp(4,
                                    (java.sql.Timestamp)sessionInfo.get("loggedOff"));
                            prepInsertStmt.setString(5,
                                    LogManager.SERVER_NAME);
                            prepInsertStmt.setInt(6, LogManager.SERVER_PORT);
                            prepInsertStmt.executeUpdate();

                        } else {
                            prepUpdateStmt.setTimestamp(1,
                                    (java.sql.Timestamp)sessionInfo.get("loggedOff"));
                            prepUpdateStmt.setString(2,
                                    (String)sessionInfo.get("sessionId"));
                            prepUpdateStmt.executeUpdate();
                        }
                    }
                    prepInsertStmt.close();
                }
                con.commit();
                userSessions.clear();
            } catch (SQLException e) {
                LOGGER.severe(e);
            } finally {
                try {
                    if (con != null)
                        con.close();
                } catch (SQLException ex) { //ignore exception
                }
            }
        }


        if (LOGGER.isInfo())
            LOGGER.info("saveUserSessionsStats completed succesfully");
    }


    public static void incrementStats(String amName, STATS statsType) {
        if (!stats.containsKey(amName)) {
            HashMap<STATS, AtomicLong> element =
                    new HashMap<STATS, AtomicLong>();
            for (STATS stats : STATS.values()) {
                element.put(stats, new AtomicLong(0));
            }
            stats.put(amName, element);
        }

        Map<STATS, AtomicLong> statsInstance =
                (Map<STATS, AtomicLong>)stats.get(amName);
        statsInstance.get(statsType).incrementAndGet();
        if (!statsModified.get())
            statsModified.getAndSet(true);
    }


    public static final void saveDMSStats() {
        Connection con = getConnection();
        if (con != null) {
            String insertSql =
                    "INSERT INTO REDSAM_AUDIT_TF (TF_NAME, APP_NAME, ACTIVE, ACCESSED, MAXACTIVE, AVGTIME, SERVER_NAME, SERVER_PORT, STATS_DATE) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, SYSDATE)";
            PreparedStatement prepInsertStmt = null;
            try {
                con.setAutoCommit(false);
                prepInsertStmt = con.prepareStatement(insertSql);
                DMSHarvester dmsHarvester = new DMSHarvester();
                Collection<TaskFlowStats> taskFlowStatsCollection =
                        dmsHarvester.harvestTFStats();
                for (TaskFlowStats taskFlowStats : taskFlowStatsCollection) {
                    prepInsertStmt.setString(1, taskFlowStats.getName());
                    prepInsertStmt.setString(2, taskFlowStats.getADFc());
                    prepInsertStmt.setDouble(3,
                            taskFlowStats.getActive_value());
                    prepInsertStmt.setDouble(4,
                            taskFlowStats.getEntered_value());
                    prepInsertStmt.setDouble(5,
                            taskFlowStats.getActive_maxValue());
                    prepInsertStmt.setDouble(6, taskFlowStats.getInvoke_avg());
                    prepInsertStmt.setString(7, LogManager.SERVER_NAME);
                    prepInsertStmt.setInt(8, LogManager.SERVER_PORT);
                    prepInsertStmt.executeUpdate();

                }
                prepInsertStmt.close();
                con.commit();


            } catch (SQLException e) {
                LOGGER.severe(e);
            } finally {
                try {
                    if (con != null)
                        con.close();
                } catch (SQLException ex) { //ignore exception
                }
            }
        }
    }

    private static final void saveClientRequestStats() {
        if (clientRequests == null || clientRequests.isEmpty()) {


            if (LOGGER.isInfo())
                LOGGER.info("no client requests since last update");
            return;
        }

        if (LOGGER.isInfo())
            LOGGER.info("saveClientRequestStats starts");
        Connection con = null;

        try {
            con = getConnection();
            PreparedStatement prepInsertStmt = null;
            String insertSql =
                    "INSERT INTO REDSAM_AUDIT_CLIENT_REQUESTS (COMPONENT_ID, COMPONENT_NAME, LOAD_TIME, USER_NAME, PAGE_LOAD_TIME, PAGE_NAME, SECTION, SUBSECTION, REQUEST_DATE, SERVER_NAME, ECID, SERVER_PORT) " +
                            "VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, SYSDATE, ?, ?, ?)";

            if (con != null) {
                prepInsertStmt = con.prepareStatement(insertSql);
                synchronized (clientRequests) {
                    con.setAutoCommit(false);
                    Iterator it = clientRequests.iterator();
                    while (it.hasNext()) {

                        Object[] clientRequest = (Object[])it.next();
                        String params = (String)clientRequest[0];
                        if (params == null || params.trim().isEmpty()) {
                            if (LOGGER.isInfo())
                                LOGGER.info("client request data is empty for user: " +
                                        clientRequest[0]);
                            continue;
                        }

                        String[] data = params.split("&&&&");


                        String username = (String)clientRequest[1];
                        String ecid = (String)clientRequest[2];
                        if (data.length < 5) {
                            LOGGER.warning("client request data is inconsistent: " +
                                    Arrays.asList(data));
                            continue;
                        }

                        //System.out.println("Arrays.asList(data): " + Arrays.asList(data)); 

                        Long time = new Long(new Long(data[0]));
                        String pageName = data[1];
                        Long pageLoadTime = 0l;
                        try {
                            pageLoadTime = new Long(data[data.length - 1]);
                        } catch (NumberFormatException nfe) {
                        }
                        String componentName = data[data.length - 3];
                        String componentId = data[data.length - 2];
                        String section = "";
                        if (data.length > 4)
                        {
                            section = data[2];
                        }

                        String subsection = "";
                        if (data.length > 6)
                        {
                            for (int k = 3; k < data.length - 2; k++)
                            {
                                subsection += "/";
                                subsection +=  data[k];
                            }
                        }

                        prepInsertStmt.setString(1, componentId);
                        prepInsertStmt.setString(2, componentName);
                        prepInsertStmt.setLong(3, time);
                        prepInsertStmt.setString(4, username);
                        prepInsertStmt.setLong(5, pageLoadTime);
                        prepInsertStmt.setString(6, pageName);
                        prepInsertStmt.setString(7, section);
                        prepInsertStmt.setString(8, subsection);
                        prepInsertStmt.setString(9, LogManager.SERVER_NAME);
                        prepInsertStmt.setString(10, ecid);
                        prepInsertStmt.setInt(11, LogManager.SERVER_PORT);
                        prepInsertStmt.executeUpdate();
                    }
                    prepInsertStmt.close();
                }
                con.commit();
                clientRequests.clear();
            }

        } catch (Exception e) {
            LOGGER.severe(e);
        } finally {
            try {
                if (con != null)
                    con.close();
            } catch (SQLException ex) { //ignore exception
            }
        }

        if (LOGGER.isInfo())
            LOGGER.info("saveClientRequestStats completed succesfully");
    }


    /**
     *
     select * from (
     select distinct COUNT(*) OVER (PARTITION BY ECID, vo_name, bindvars) QUERIES_COUNT, vo_name, bindvars
     from redsam_audit_queries   order by QUERIES_COUNT DESC
     ) where QUERIES_COUNT > 1

     */
    private static void saveQueries() {
        //voInstance, bindParams, oracle.adf.share.logging.internal.LoggingUtils.getECID()
        if (queries == null || queries.isEmpty()) {


            if (LOGGER.isInfo())
                LOGGER.info("no queries logged since last update");
            return;
        }

        if (LOGGER.isInfo())
            LOGGER.info("saveQueries starts");
        Connection con = null;

        try {
            con = getConnection();
            PreparedStatement prepInsertStmt = null;
            String insertSql =
                    "INSERT INTO REDSAM_AUDIT_QUERIES (VO_NAME, BINDVARS, ECID, USER_NAME, SESSION_ID, REQUEST_DATE, SERVER_NAME, SERVER_PORT) " +
                            "VALUES (?, ?, ?, ?, ?, SYSDATE, ?, ?)";

            if (con != null) {
                prepInsertStmt = con.prepareStatement(insertSql);
                synchronized (queries) {
                    con.setAutoCommit(false);
                    Iterator it = queries.iterator();
                    while (it.hasNext()) {
                        Object[] queriesRow = (Object[])it.next();
                        if (queriesRow == null || queriesRow.length != 5) {
                            if (LOGGER.isInfo())
                                LOGGER.info("query log is inconsistent : " +
                                        (queriesRow != null ?
                                                Arrays.asList(queriesRow) :
                                                null));
                            continue;
                        }

                        String voName = (String)queriesRow[0];
                        String bindvar = queriesRow[1].toString();
                        String ecid = (String)queriesRow[2];
                        String username = (String)queriesRow[3];
                        String sessionId = (String)queriesRow[4];

                        prepInsertStmt.setString(1, voName);
                        prepInsertStmt.setString(2, bindvar);
                        prepInsertStmt.setString(3, ecid);
                        prepInsertStmt.setString(4, username);
                        prepInsertStmt.setString(5, sessionId);
                        prepInsertStmt.setString(6, LogManager.SERVER_NAME);
                        prepInsertStmt.setInt(7, LogManager.SERVER_PORT);
                        prepInsertStmt.executeUpdate();

                    }
                    prepInsertStmt.close();
                }
                con.commit();
                queries.clear();
            }

        } catch (Exception e) {
            LOGGER.severe(e);
        } finally {
            try {
                if (con != null)
                    con.close();
            } catch (SQLException ex) { //ignore exception
            }
        }

        if (LOGGER.isInfo())
            LOGGER.info("saveQueries completed succesfully");

    }
}

