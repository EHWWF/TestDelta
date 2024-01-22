package com.redsam.audit.dms.domain;

import java.lang.reflect.Field;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import oracle.adf.share.logging.ADFLogger;

/**
 * Red Samurai Audit. Version 4.0
 */
public class TaskFlowStats extends AbstractStats implements Cloneable {
    public TaskFlowStats() {
        super();
    }

    protected String ADFc;
    protected String Name;
    protected String Parent;

    protected double active_value;
    protected double active_maxValue;
    protected double active_minValue;

    protected double entered_value;
    protected double entered_maxValue;
    protected double entered_minValue;

    protected double invoke_avg;
    protected double invoke_maxActive;
    protected double invoke_maxTime;

    //no replace needed for the params name
    public void set(String parameter, Object value) {
        String fieldStr = parameter;
        Field field;

        try {
            field = this.getClass().getDeclaredField(fieldStr);
            //LOGGER.finest(field + "=" + value);
            field.set(this, value);
        } catch (NoSuchFieldException e) {
            throw new IllegalStateException(e);
        } catch (IllegalAccessException e) {
            throw new IllegalStateException(e);
        }
    }


    public String toString() {
        return super.toString();
    }

    public boolean equals(Object obj) {

        if (obj instanceof TaskFlowStats) {
            TaskFlowStats tf = (TaskFlowStats)obj;
            if (tf.get("ADFc").equals(this.get("ADFc")) && tf.get("Name").equals(this.get("Name")) &&
                tf.get("Parent").equals(this.get("Parent"))) {
                
                return true;

            }
        }
        
        return false;

    }

    public int hashCode() {
        return ADFc.hashCode();
    }

    /**
     * 
     * @param prevStats
     */
    public TaskFlowStats retainDifference(TaskFlowStats prevStats) {
        TaskFlowStats xclone;
        try {
            xclone = (TaskFlowStats)this.clone();
        } catch (CloneNotSupportedException e) {
            throw new IllegalStateException(e);
        }
        if(this.entered_value >= prevStats.entered_value) {
            xclone.entered_value = xclone.entered_value - prevStats.entered_value;
        }
        
        return xclone;
        
    }


    public void setADFc(String ADFc) {
        this.ADFc = ADFc;
    }

    public String getADFc() {
        return ADFc;
    }

    public void setName(String Name) {
        this.Name = Name;
    }

    public String getName() {
        return Name;
    }

    public void setParent(String Parent) {
        this.Parent = Parent;
    }

    public String getParent() {
        return Parent;
    }

    public void setActive_value(double active_value) {
        this.active_value = active_value;
    }

    public double getActive_value() {
        return active_value;
    }

    public void setActive_maxValue(double active_maxValue) {
        this.active_maxValue = active_maxValue;
    }

    public double getActive_maxValue() {
        return active_maxValue;
    }

    public void setActive_minValue(double active_minValue) {
        this.active_minValue = active_minValue;
    }

    public double getActive_minValue() {
        return active_minValue;
    }

    public void setEntered_value(double entered_value) {
        this.entered_value = entered_value;
    }

    public double getEntered_value() {
        return entered_value;
    }

    public void setEntered_maxValue(double entered_maxValue) {
        this.entered_maxValue = entered_maxValue;
    }

    public double getEntered_maxValue() {
        return entered_maxValue;
    }

    public void setEntered_minValue(double entered_minValue) {
        this.entered_minValue = entered_minValue;
    }

    public double getEntered_minValue() {
        return entered_minValue;
    }

    public void setInvoke_avg(double invoke_avg) {
        this.invoke_avg = invoke_avg;
    }

    public double getInvoke_avg() {
        return invoke_avg;
    }

    public void setInvoke_maxActive(double invoke_maxActive) {
        this.invoke_maxActive = invoke_maxActive;
    }

    public double getInvoke_maxActive() {
        return invoke_maxActive;
    }

    public void setInvoke_maxTime(double invoke_maxTime) {
        this.invoke_maxTime = invoke_maxTime;
    }

    public double getInvoke_maxTime() {
        return invoke_maxTime;
    }
    
    //DO NOT REMOVE: no replace needed for the params name
    public Collection getParameters(){
        List al = new ArrayList();
        Field[] field = this.getClass().getDeclaredFields();
        for (Field field1 : field) {
            if(field1.getName().equals("serialVersionUID")) {
              System.out.println("skip serialVersionUID....");
              continue;
            } 
            
            al.add(field1.getName());
        }
        
        return al;
    }

}
