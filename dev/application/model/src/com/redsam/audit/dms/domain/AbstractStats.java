package com.redsam.audit.dms.domain;

import java.lang.reflect.Field;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import oracle.adf.share.logging.ADFLogger;

/**
 * Red Samurai Audit. Version 4.0
 */
public abstract class AbstractStats {
    private static ADFLogger LOGGER =
        ADFLogger.createADFLogger("com.redsam.audit.RedsamAuditVOImpl");
    
    public AbstractStats() {
        super();
    }

   public Collection getParameters(){
        List al = new ArrayList();
        Field[] field = this.getClass().getDeclaredFields();
        for (Field field1 : field) {
            if(field1.getName().equals("serialVersionUID")) {
              LOGGER.finest("skip serialVersionUID....");
              continue;
            } 
            al.add(field1.getName().replace("_", "."));
            
        }
        return al;
    }
    
    public void set(String parameter, Object value){
        String fieldStr = parameter.replace(".", "_");
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
    
    public Object get(String parameter) {
        Field[] field = this.getClass().getDeclaredFields();
        for (Field field1 : field) {
            if(field1.getName().equals(parameter)) {
               try {
                    return field1.get(this);
                } catch (IllegalAccessException e) {
                    throw new IllegalArgumentException(e);
                }
            }
        }
     
        throw new IllegalArgumentException("The parameter '" + parameter + "' doesnt exist in class:  " + this.getClass() );
    }

}
