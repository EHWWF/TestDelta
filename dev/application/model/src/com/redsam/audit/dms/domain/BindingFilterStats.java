package com.redsam.audit.dms.domain;

import java.lang.reflect.Field;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import oracle.adf.share.logging.ADFLogger;

/**
 * Red Samurai Audit. Version 4.0
 */
public class BindingFilterStats extends AbstractStats {
    public BindingFilterStats() {
        super();
    }
    
    protected String Name;
    protected String Parent;
    protected double doFilter_avg;
    protected double doFilter_maxActive;
    protected double doFilter_completed;
    private static ADFLogger LOGGER =
        ADFLogger.createADFLogger("com.redsam.audit.RedsamAuditVOImpl");

    public String getName() {
        return Name;
    }

    public String getParent() {
        return Parent;
    }

    public double getDoFilter_avg() {
        return doFilter_avg;
    }

    public double getDoFilter_maxActive() {
        return doFilter_maxActive;
    }

    public double getDoFilter_completed() {
        return doFilter_completed;
    }
    
    
    //no replace needed for the params name
    public Collection getParameters(){
        List al = new ArrayList();
        Field[] field = this.getClass().getDeclaredFields();
        for (Field field1 : field) {
            al.add(field1.getName());
        }
        
        return al;
    }


    //no replace needed for the params name
    public void set(String parameter, Object value){
        String fieldStr = parameter;
        Field field;

        try {
            field = this.getClass().getDeclaredField(fieldStr);
            LOGGER.finest(field + "=" + value);
            field.set(this, value);
        } catch (NoSuchFieldException e) {
            throw new IllegalStateException(e);
        } catch (IllegalAccessException e) {
            throw new IllegalStateException(e);
        }
    }

}
