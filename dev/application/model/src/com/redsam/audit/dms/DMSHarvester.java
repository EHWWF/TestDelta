package com.redsam.audit.dms;

import com.redsam.audit.LogManager;
import com.redsam.audit.dms.domain.AMStats;

import com.redsam.audit.dms.domain.TaskFlowStats;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import javax.management.AttributeNotFoundException;
import javax.management.InstanceNotFoundException;
import javax.management.MBeanException;
import javax.management.MBeanServer;
import javax.management.MalformedObjectNameException;
import javax.management.ObjectName;
import javax.management.ReflectionException;
import javax.management.openmbean.CompositeData;
import javax.management.openmbean.TabularDataSupport;

import javax.naming.InitialContext;
import javax.naming.NamingException;

import oracle.adf.share.logging.ADFLogger;

/**
 * Red Samurai Audit. Version 4.0
 */
public class DMSHarvester {

    private static long lastHarvestTime = 0;


    private static Collection<TaskFlowStats> lastTaskFlowStats = null;

    private static ADFLogger LOGGER =
        ADFLogger.createADFLogger("com.redsam.audit.RedsamAuditVOImpl");

    public DMSHarvester() {
        super();
    }

    public Collection<AMStats> getAMStats() {
        //getting adfbindings stats
        Collection<AMStats> amStatsColl = new ArrayList<AMStats>();
        ObjectName spy;
        try {
            spy = new ObjectName(DmsConstants.SPY.getMbean());
        } catch (MalformedObjectNameException e) {
            throw new IllegalStateException(e);
        }
        HashMap properties = new HashMap();
        InitialContext ctx;
        try {
            ctx = new InitialContext();
        } catch (NamingException e) {
            throw new IllegalStateException(e);
        }
        MBeanServer server;
        try {
            server = (MBeanServer)ctx.lookup("java:comp/env/jmx/runtime");
        } catch (NamingException e) {
            throw new IllegalStateException(e);
        }
        Object result2;
        try {
            result2 =
                    server.invoke(spy, "getTablesInOpenType", new Object[] { new String[] { "ampool" }, lastHarvestTime,
                                                                             Long.MAX_VALUE, null,
                                                                             new String[] { System.getProperty("weblogic.Name") },
                                                                             properties }, null);
        } catch (InstanceNotFoundException e) {
            throw new IllegalStateException(e);
        } catch (MBeanException e) {
            throw new IllegalStateException(e);
        } catch (ReflectionException e) {
            throw new IllegalStateException(e);
        }
        javax.management.openmbean.CompositeData[] rs = (javax.management.openmbean.CompositeData[])result2;
        for (CompositeData compositeData : rs) {

            if (compositeData == null)
                return amStatsColl;

            Collection values = compositeData.values();
            for (Object val : values) {

                if (val instanceof TabularDataSupport) {

                    TabularDataSupport tds = (TabularDataSupport)val;
                    Set entries = tds.entrySet();
                    for (Object entry : entries) {
                        if (entry instanceof Map.Entry) {
                            Map.Entry entryColl = (Map.Entry)entry;
                            javax.management.openmbean.CompositeDataSupport cds =
                                (javax.management.openmbean.CompositeDataSupport)entryColl.getValue();

                            AMStats amStats = new AMStats();
                            amStatsColl.add(amStats);
                            Collection<String> parameters = amStats.getParameters();
                            for (String param : parameters) {
                                amStats.set(param, cds.get(param));
                            }

                            /* LOGGER.finest("\n\n\n\n*Host=" + cds.get("Host"));
                                LOGGER.finest("*Name=" + cds.get("Name"));
                                LOGGER.finest("Process=" + cds.get("Process"));
                                LOGGER.finest("*ServerName=" + cds.get("ServerName"));
                                LOGGER.finest("appModuleCreationTime.active=" + cds.get("appModuleCreationTime.active"));
                                LOGGER.finest("*aappModuleCreationTime.avg=" + cds.get("appModuleCreationTime.avg"));
                                LOGGER.finest("*appModuleCreationTime.completed=" + cds.get("appModuleCreationTime.completed"));
                                LOGGER.finest("*appModuleCreationTime.maxActive=" + cds.get("appModuleCreationTime.maxActive"));
                                LOGGER.finest("*appModuleCreationTime.maxTime=" + cds.get("appModuleCreationTime.maxTime"));
                                LOGGER.finest("*appModuleCreationTime.minTime=" + cds.get("appModuleCreationTime.minTime"));
                                LOGGER.finest("appModuleCreationTime.time=" + cds.get("appModuleCreationTime.time"));
                                LOGGER.finest("appName.count=" + cds.get("appName.count"));
                                LOGGER.finest("appName.value=" + cds.get("appName.value"));
                                LOGGER.finest("availableInstanceCount.count=" + cds.get("availableInstanceCount.count"));
                                LOGGER.finest("*availableInstanceCount.maxValue=" + cds.get("availableInstanceCount.maxValue"));
                                LOGGER.finest("*availableInstanceCount.minValue=" + cds.get("availableInstanceCount.minValue"));
                                LOGGER.finest("*availableInstanceCount.value=" + cds.get("availableInstanceCount.value"));
                                LOGGER.finest("*instanceCheckedIn.count=" + cds.get("instanceCheckedIn.count"));
                                LOGGER.finest("*instanceCheckedOut.count=" + cds.get("instanceCheckedOut.count"));
                                LOGGER.finest("instanceCount.count=" + cds.get("instanceCount.count"));
                                LOGGER.finest("instanceCount.maxValue=" + cds.get("instanceCount.maxValue"));
                                LOGGER.finest("instanceCount.minValue=" + cds.get("instanceCount.minValue"));
                                LOGGER.finest("instanceCount.value=" + cds.get("instanceCount.value"));
                                LOGGER.finest("*instanceCreated.count=" + cds.get("instanceCreated.count"));
                                LOGGER.finest("*instanceRemoved.count=" + cds.get("instanceRemoved.count"));
                                LOGGER.finest("*instanceReused.count=" + cds.get("instanceReused.count"));
                                LOGGER.finest("*refInstanceRecycled.count=" + cds.get("refInstanceRecycled.count"));
                                LOGGER.finest("*stateActivated.count=" + cds.get("stateActivated.count"));
                                LOGGER.finest("*statePassivated.count=" + cds.get("statePassivated.count"));
                                LOGGER.finest("unrefInstanceRecycled.count=" + cds.get("unrefInstanceRecycled.count")); */
                        }
                    }

                    lastHarvestTime = System.currentTimeMillis();
                } else
                    LOGGER.finest(val.getClass().toString());
            }
        }

        return amStatsColl;
    }


    /**
     * collects task flow information
     * @return
     */
    public Collection<TaskFlowStats> harvestTFStats() {

        Collection<TaskFlowStats> currentTaskFlowStats = new ArrayList<TaskFlowStats>();
        Collection<TaskFlowStats> returnTaskFlowStats = new ArrayList<TaskFlowStats>();
        try {
            InitialContext ctx = new InitialContext();

            MBeanServer server = (MBeanServer)ctx.lookup("java:comp/env/jmx/runtime");
            //getting jdbc datasource stats
            ObjectName objName = new ObjectName(DmsConstants.TF.getMbean());
            Set<ObjectName> serarchResult = server.queryNames(objName, null);
            for (ObjectName objectName1 : serarchResult) {

                TaskFlowStats tfStats = new TaskFlowStats();
                Collection<String> parameters = tfStats.getParameters();
                //building  tf statistics
                for (String param : parameters) {
                    try {
                        tfStats.set(param, server.getAttribute(objectName1, param));
                    } catch (AttributeNotFoundException anfe) {
                        LOGGER.warning("Attribute: '" + param + "' cannot be read from " + objectName1);
                    } 
                }

                if (this.lastTaskFlowStats != null) {
                    boolean firstTime = true;
                    //comparing current stats values with previous values
                    for (TaskFlowStats lastStats : this.lastTaskFlowStats) {
                        if (lastStats.equals(tfStats)) {
                            firstTime = false;
                            TaskFlowStats toBeReturned = tfStats.retainDifference(lastStats);
                            //if there was no accesses since the last statistics, no log will be done
                            if(toBeReturned.getEntered_value() > 0) {
                                returnTaskFlowStats.add(toBeReturned);
                            } else {
                                LOGGER.finest("harvesting data on task flow: " + toBeReturned.getName() + ", " + toBeReturned.getADFc() + ". Skipping logs, no access since last harvest.");
                            }
                        }
                    }
                    
                    if(firstTime) {
                        returnTaskFlowStats.add(tfStats);
                    }
                    
                    
                } else {
                    returnTaskFlowStats.add(tfStats);
                }
                currentTaskFlowStats.add(tfStats);

            }

            lastTaskFlowStats = currentTaskFlowStats;


        } catch (MalformedObjectNameException e) {
            throw new IllegalStateException(e);
        } catch (MBeanException e) {
            throw new IllegalStateException(e);
        } catch (InstanceNotFoundException e) {
            throw new IllegalStateException(e);
        } catch (ReflectionException e) {
            throw new IllegalStateException(e);
        } catch (NamingException e) {
            throw new IllegalStateException(e);
        }

     

        return returnTaskFlowStats;
    }

}
