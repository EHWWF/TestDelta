package com.redsam.audit.dms.domain;

import java.lang.reflect.Field;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Red Samurai Audit. Version 4.0
 */
public class AMStats extends AbstractStats{
    
    
    public AMStats() {
        super();
    }

    protected String Host;
    protected String Name;
    protected String ServerName;    
    protected double appModuleCreationTime_avg;
    protected double appModuleCreationTime_completed;
    protected double appModuleCreationTime_maxActive;
    protected double appModuleCreationTime_maxTime;
    protected double appModuleCreationTime_minTime;
    protected double availableInstanceCount_maxValue;
    protected double availableInstanceCount_minValue;
    protected double availableInstanceCount_value;

    protected double instanceCheckedIn_count;
    protected double instanceCheckedOut_count;
    protected double instanceCreated_count;
    protected double instanceRemoved_count;
    protected double instanceReused_count;
    protected double refInstanceRecycled_count;
    protected double stateActivated_count;
    protected double statePassivated_count;


    public double getAppModuleCreationTime_avg() {
        return appModuleCreationTime_avg;
    }

    public double getAppModuleCreationTime_completed() {
        return appModuleCreationTime_completed;
    }

    public double getAppModuleCreationTime_maxActive() {
        return appModuleCreationTime_maxActive;
    }

    public double getAppModuleCreationTime_maxTime() {
        return appModuleCreationTime_maxTime;
    }

    public double getAppModuleCreationTime_minTime() {
        return appModuleCreationTime_minTime;
    }

    public double getAvailableInstanceCount_maxValue() {
        return availableInstanceCount_maxValue;
    }

    public double getAvailableInstanceCount_minValue() {
        return availableInstanceCount_minValue;
    }

    public double getAvailableInstanceCount_value() {
        return availableInstanceCount_value;
    }

    public double getInstanceCheckedIn_count() {
        return instanceCheckedIn_count;
    }

    public double getInstanceCheckedOut_count() {
        return instanceCheckedOut_count;
    }

    public double getInstanceCreated_count() {
        return instanceCreated_count;
    }

    public double getInstanceRemoved_count() {
        return instanceRemoved_count;
    }

   public double getInstanceReused_count() {
        return instanceReused_count;
    }

    public double getRefInstanceRecycled_count() {
        return refInstanceRecycled_count;
    }

   

    public double getStateActivated_count() {
        return stateActivated_count;
    }

  

    public double getStatePassivated_count() {
        return statePassivated_count;
    }


    public String getHost() {
        return Host;
    }

    public String getName() {
        return Name;
    }

    public String getServerName() {
        return ServerName;
    }
}
