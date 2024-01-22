package com.redsam.audit;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;

import oracle.adf.share.ADFContext;
import java.lang.reflect.Method;

import oracle.jbo.Key;
import oracle.jbo.common.ampool.AMStatistics;
import oracle.jbo.server.QueryCollection;
import oracle.jbo.server.SQLBuilder;
import oracle.jbo.server.SessionImpl;
import oracle.jbo.server.ViewObjectImpl;
import oracle.jbo.server.ViewRowImpl;
import oracle.jbo.server.ViewRowSetImpl;
import oracle.jbo.server.ViewRowSetIteratorImpl;
import oracle.jbo.ViewCriteria;
import oracle.jbo.ViewObject;
import oracle.adf.share.ADFContext;
import oracle.adf.share.logging.ADFLogger;

/**
 * Red Samurai Audit. Version 4.0
 */
public class RedsamAuditVOImpl extends ViewObjectImpl {

    private static final String SUPRESS_AUDITING_PROPERTY = "SUPRESS_AUDITING";
    private long fetchedRows;
    private long fetchTime;
    private long fetchTimePeriod;
    
    
    private static final ADFLogger logger = ADFLogger.createADFLogger(RedsamAuditVOImpl.class);
       //flag used for printing the queries and records fetched to the console
       protected boolean showSql = true;

    /**
     * Override to control access to query as per meta-data.
     * Additonally is tracking/LOGGING sql server long running queries
     * @param qc
     * @param params
     * @param noUserParams
     */
    protected void executeQueryForCollection(Object qc, Object[] params,
                                             int noUserParams) {
        if (!LogManager.isAuditDisabled && !supressAuditing()) {
            long init = System.currentTimeMillis();
            this.setAmStatisticsTime("lastVoExecutionTime", init);
            
            fetchTimePeriod = 0; //resetting the counter
            
            super.executeQueryForCollection(qc, params, noUserParams);
            long end = System.currentTimeMillis() - init;

            if (end > LogManager.DEFAULT_TOLLERATED_EXEC_TIME) {
                StringBuilder sb = new StringBuilder();
                //time
                sb.append("Executed in ");
                sb.append(end);
                sb.append(" miliseconds, fetched ");
                try {
                    sb.append(this.getRowCountInRange());
                } catch (Exception e) {
                    sb.append(-1);
                }
                sb.append(" record(s).\n");

                //sql
                sb.append("QUERY: ");
                sb.append(this.getQuery());

                if (params != null &&
                    getBindingStyle() == SQLBuilder.BINDING_STYLE_ORACLE_NAME) {
                    Map<String, Object> bindsMap =
                        new HashMap<String, Object>(params.length);
                    for (Object param : params) {
                        Object[] nameValue = (Object[])param;
                        String name = (String)nameValue[0];
                        Object value = nameValue[1];
                        bindsMap.put(name, value);
                    }

                    //bind vars
                    sb.append("\n BIND VARS : {");
                    sb.append(bindsMap);
                }


                LogManager.log(MESSAGE.SLOW_QUERY,
                               this.getApplicationModule().getName() + "." +
                               this.getName(), end, sb.toString(),
                               ADFContext.getCurrent().getSecurityContext().getUserName());
            }

            LogManager.incrementStats(this.getApplicationModule().getFullName(),
                                      STATS.SELECTS);
        } else {
            super.executeQueryForCollection(qc, params, noUserParams);
        }
    }

  @Override
  protected void bindParametersForCollection(QueryCollection queryCollection, Object[] params,
                                             PreparedStatement preparedStatement)
    throws SQLException
  {
    
    if (getShowSql()) {
          logQueryStatementAndBindParameters(queryCollection, params);
    }
    
    
    if(LogManager.isMediumDiagnosticLevel()) {
      String vrsiName = null;
      if (queryCollection != null)
      {
        ViewRowSetImpl vrsi = queryCollection.getRowSetImpl();
        vrsiName = vrsi.isDefaultRS()? "<Default>": vrsi.getName();
      }
      String voName = this.getApplicationModule().getName() + "." + getName();


      Map<String, Object> bindsMap = new TreeMap<String, Object>(); //ordered map
      if (params != null)
      {
        if (getBindingStyle() == SQLBuilder.BINDING_STYLE_ORACLE_NAME)
        {
          for (Object param: params)
          {
            Object[] nameValue = (Object[]) param;
            String name = (String) nameValue[0];
            Object value = nameValue[1];
            bindsMap.put(name, value);
          }
        }
      }
      
      String sessionId = "";
      try {
        sessionId = SessionImpl.findOrCreateSessionContextManager().getCurrentSession().getId();
      }catch(Exception ex) {
        if(LogManager.LOGGER.isInfo())
          LogManager.LOGGER.severe(ex);
      }
      
      LogManager.logQueries(voName, bindsMap, ADFContext.getCurrent().getSecurityContext().getUserName(), sessionId);
    }
    
    super.bindParametersForCollection(queryCollection, params, preparedStatement);
  }


  @Override
    protected ViewRowImpl createRowFromResultSet(Object object,
                                                 ResultSet resultSet) {
        ViewRowImpl ret = null;
        if ((!LogManager.isAuditDisabled) && !supressAuditing()) {
            if (System.currentTimeMillis() - fetchTimePeriod > LogManager.DEFAULT_WAIT_FETCH_TIME) {
                fetchedRows = 0;
                fetchTime = System.currentTimeMillis();
            }
            
            ret = super.createRowFromResultSet(object, resultSet);
            if (ret != null) {
                fetchedRows++;
            }

            if (LogManager.DEFAULT_TOLLERATED_FETCH_SIZE == fetchedRows) {

                long end = System.currentTimeMillis() - fetchTime;

                StringBuilder sb = new StringBuilder();
                sb.append(". fetching over ").append(LogManager.DEFAULT_TOLLERATED_FETCH_SIZE).append(" records");

                LogManager.log(MESSAGE.LARGE_FETCH,
                               this.getApplicationModule().getName() + "." +
                               this.getName(), end, sb.toString(),
                               ADFContext.getCurrent().getSecurityContext().getUserName());
            } else if (LogManager.DEFAULT_TOLLERATED_FETCH_SIZE * 10 ==
                       fetchedRows) {

                long end = System.currentTimeMillis() - fetchTime;

                StringBuilder sb = new StringBuilder();
                sb.append(". fetching over ").append(LogManager.DEFAULT_TOLLERATED_FETCH_SIZE *
                                                     10).append(" records.");

                LogManager.log(MESSAGE.LARGE_FETCH,
                               this.getApplicationModule().getName() + "." +
                               this.getName(), end, sb.toString(),
                               ADFContext.getCurrent().getSecurityContext().getUserName());
            } else if (LogManager.DEFAULT_TOLLERATED_FETCH_SIZE * 100 ==
                       fetchedRows) {
                
                long end = System.currentTimeMillis() - fetchTime;

                StringBuilder sb = new StringBuilder();
                sb.append(". fetching over ").append(LogManager.DEFAULT_TOLLERATED_FETCH_SIZE *
                                                     100).append(" records.");

                LogManager.log(MESSAGE.LARGE_FETCH,
                               this.getApplicationModule().getName() + "." +
                               this.getName(), end, sb.toString(),
                               ADFContext.getCurrent().getSecurityContext().getUserName());
            }

            fetchTimePeriod = System.currentTimeMillis();
        } else {
            ret = super.createRowFromResultSet(object, resultSet);
        }

        return ret;
    }

    /**
     *Tracking slow COUNT statements.
     */
    public long getEstimatedRowCount() {
        long counter = 0;
        if ((!LogManager.isAuditDisabled) && !supressAuditing()) {
            long init = System.currentTimeMillis();
            counter = super.getEstimatedRowCount();
            long end = System.currentTimeMillis() - init;

            if (end > LogManager.DEFAULT_TOLLERATED_EXEC_TIME) {
                LogManager.log(MESSAGE.SLOW_COUNT_QUERY,
                               this.getApplicationModule().getName() + "." +
                               this.getName(), end, null,
                               ADFContext.getCurrent().getSecurityContext().getUserName());
            }
        } else {
            counter = super.getEstimatedRowCount();
        }

        return counter;
    }

    /**
     * If the view object has the property SUPRESS_AUDITING=true,
     * the large fetches or slow queries violations won't be reported anymore (BY Design cases).
     * @return true, if performance violations are to be ignored.
     */
    public boolean supressAuditing() {
        String ignore =
            (String)this.getViewDef().getProperty(SUPRESS_AUDITING_PROPERTY);
        if ("true".equalsIgnoreCase(ignore)) {
            return true;
        }
        return false;
    }
    
    /**
     * Tracking slow activation events.
     * @param viewRowSetIteratorImpl
     * @param viewRowSetImpl
     * @param key
     */
    @Override
    protected ViewRowImpl activateCurrentRow(ViewRowSetIteratorImpl viewRowSetIteratorImpl,
                                             ViewRowSetImpl viewRowSetImpl,
                                             Key key) {
        int fetchedRows = viewRowSetIteratorImpl.getRowCountInRange();

        ViewRowImpl r =
            super.activateCurrentRow(viewRowSetIteratorImpl, viewRowSetImpl,
                                     key);

        if (!LogManager.isAuditDisabled && !supressAuditing()) {
            long lastVoActivationTime =
                this.getAmStatisticsTime("lastVoActivationTime");
            long lastVoExecutionTime =
                this.getAmStatisticsTime("lastVoExecutionTime");
            if (lastVoExecutionTime > 0 && lastVoActivationTime > 0) {
                long lastVoActivationDiffTime =
                    lastVoExecutionTime - lastVoActivationTime;
                if (lastVoActivationDiffTime >
                    LogManager.DEFAULT_WAIT_ACTIVATION_TIME) {
                    this.setAmStatisticsTime("amActivationTime",
                                             lastVoExecutionTime);
                }
            }

            long amActivationTime =
                this.getAmStatisticsTime("amActivationTime");

            long end =
                (amActivationTime > 0) ? System.currentTimeMillis() - amActivationTime :
                -1;

            if (end > LogManager.DEFAULT_TOLLERATED_ACTIVATION_TIME) {
                StringBuilder sb = new StringBuilder();
                sb.append(":").append(fetchedRows).append(" records.");

                String userName =
                    ADFContext.getCurrent().getSecurityContext().getUserName().replaceAll("[\\s.]",
                                                                                          "");
                String activationLabelId =
                    amActivationTime + userName.replaceAll("_", "");

                if (this.getApplicationModule().isRoot() == false) {
                    activationLabelId += "NESTED";
                }

                LogManager.log(MESSAGE.SLOW_ACTIVATION,
                               this.getApplicationModule().getName() + "." +
                               this.getName() + "_" + activationLabelId, end,
                               sb.toString(),
                               ADFContext.getCurrent().getSecurityContext().getUserName());
            }

            this.setAmStatisticsTime("lastVoActivationTime",
                                     System.currentTimeMillis());
        }

        return r;
    }

    private long getAmStatisticsTime(String statName) {
        long time = -1;
        ArrayList stats =
            (ArrayList)this.getRootApplicationModule().getAMStatistics().getStatisticsInfo(null);
        if (stats != null) {
            for (int i = 0; i < stats.size(); i++) {
                if (stats.get(i) instanceof AMStatistics.CountStatsInfo) {
                    AMStatistics.CountStatsInfo stat =
                        (AMStatistics.CountStatsInfo)stats.get(i);
                    if (statName.equals(stat.getName())) {
                        time = stat.getValue();
                        break;
                    }
                }
            }
        }

        return time;
    }

    private void setAmStatisticsTime(String statName, long currentTime) {
        AMStatistics.StatsInfo statsInfo =
            new AMStatistics.CountStatsInfo(currentTime, statName, null);
        this.getRootApplicationModule().getAMStatistics().add(statName +
                                                              "Stats",
                                                              statsInfo);
    }

    @Override
    protected boolean hasNextForCollection(Object object) {
        boolean hasNext = super.hasNextForCollection(object);

        if (!LogManager.isAuditDisabled && !supressAuditing()) {
            if (hasNext == false) {
                if (LogManager.DEFAULT_TOLLERATED_FETCH_SIZE <= fetchedRows) {

                    long end = System.currentTimeMillis() - fetchTime;

                    StringBuilder sb = new StringBuilder();
                    sb.append(". fetching ").append(fetchedRows).append(" records in full scan");

                    LogManager.log(MESSAGE.FULL_SCAN,
                                   this.getApplicationModule().getName() +
                                   "." + this.getName(), end, sb.toString(),
                                   ADFContext.getCurrent().getSecurityContext().getUserName());
                }

                fetchTimePeriod = 0;
            }
        }

        return hasNext;
    }
    
    
   
       /**
        * method used to introspect the query produced at runtime by the vo.
        * @param qc
        * @param params
        */
       private void logQueryStatementAndBindParameters(QueryCollection qc, Object[] params) {
           String vrsiName = null;

           if (qc != null) {
               ViewRowSetImpl vrsi = qc.getRowSetImpl();
               vrsiName = vrsi.isDefaultRS() ? "<Default>" : vrsi.getName();
           }

           String voName = getName();
           String voDefName = getDefFullName();

           if (qc != null) {
               logger.info("---- " + " [Exec query for VO=" + voName + ", RS=" + vrsiName + "]----");
           } else {
               logger.info("---- " + " [Exec COUNT query for VO=" + voName + "]----");
           }
           logger.info("VO Definition Name =" + voDefName);

           String dbVCs = appliedCriteriaString(ViewCriteria.CRITERIA_MODE_QUERY);

           if (dbVCs != null && !dbVCs.isEmpty()) {
               logger.info("Applied Database VCs = " + dbVCs);
           }

           String memVCs = appliedCriteriaString(ViewCriteria.CRITERIA_MODE_CACHE);
           if (memVCs != null && !memVCs.isEmpty()) {
               logger.info("Applied In-Memory VCs =" + memVCs);
           }

           String bothVCs = appliedCriteriaString(ViewCriteria.CRITERIA_MODE_QUERY | ViewCriteria.CRITERIA_MODE_CACHE);

           if (bothVCs != null && !bothVCs.isEmpty()) {
               logger.info("Applied 'Both' VCs = " + bothVCs);
           }

           logger.info("Generated query : " + getQuery() +  getCurrentTaskFlowId());

           if (params != null) {
               if (getBindingStyle() == SQLBuilder.BINDING_STYLE_ORACLE_NAME) {
                   Map<String, Object> bindsMap = new HashMap<String, Object>(params.length);
                   for (Object param : params) {
                       Object[] nameValue = (Object[]) param;
                       String name = (String) nameValue[0];
                       Object value = nameValue[1];
                       bindsMap.put(name, value);
                   }
                   logger.info("Bind Variables " + bindsMap);
               }
           }
       }

       private String appliedCriteriaString(int mode) {
           ViewCriteria[] appliedCriterias = getApplyViewCriterias(mode);
           String result = "";

           if (appliedCriterias != null && appliedCriterias.length > 0) {
               java.util.List<String> list = new ArrayList<String>(appliedCriterias.length);

               for (ViewCriteria vc : appliedCriterias) {
                   list.add(vc.getName());
               }

               result = list.toString();
           }

           return result;
       }

       @Override
       public ViewRowImpl createInstanceFromResultSet(QueryCollection queryCollection, ResultSet resultSet) {
           ViewRowImpl vr = super.createInstanceFromResultSet(queryCollection, resultSet);

           if (getShowSql()) {
               if (vr != null)
                   logger.info("\n----[VO " + getName() + " fetched " + vr.getKey() + "]");
               else
                   logger.info("\n----[VO " + getName() + " fetched " + vr + "]");
           }

           return vr;
       }

       public boolean getShowSql() {
           if (showSql)
               return true;
           else {
               Object queryLoggingProp = this.getViewDef().getProperty("showSql");
               if ("true".equalsIgnoreCase(queryLoggingProp + ""))
                   return true;
               return false;
           }
       }
       
    /**
        * Retrieve task flow id using java reflection 
        * @return
        */
       public String getCurrentTaskFlowId()
       {
         ADFContext adfContext = ADFContext.getCurrent();
         if (adfContext != null && !adfContext.isJEE())
         {
           return "";
         }
         String ret = " \n :::::: TaskFlowId= ";

         try
         {
           Class controllerContextClass = Class.forName("oracle.adf.controller.ControllerContext");
           Method getInstanceMethod = controllerContextClass.getMethod("getInstance", null);
           Object controllerContextObject = getInstanceMethod.invoke(null, null);

           Method getCurrentViewPortMethod = controllerContextClass.getMethod("getCurrentViewPort", null);
           Object currentViewPortObject = getCurrentViewPortMethod.invoke(controllerContextObject, null);

           Class viewPortContextClass = Class.forName("oracle.adf.controller.ViewPortContext");
           Method getTaskFlowContextMethod = viewPortContextClass.getMethod("getTaskFlowContext", null);
           Object taskFlowContextObject = getTaskFlowContextMethod.invoke(currentViewPortObject, null);


           Class taskFlowContextClass = Class.forName("oracle.adf.controller.TaskFlowContext");
           Method getTaskFlowIdMethod = taskFlowContextClass.getMethod("getTaskFlowId", null);
           Object taskFlowIdObject = getTaskFlowIdMethod.invoke(taskFlowContextObject, null);
           ret = ret + taskFlowIdObject;

         }
         catch (Throwable e)
         {
           //ignore any error
         }

         return ret;
       }


    
}