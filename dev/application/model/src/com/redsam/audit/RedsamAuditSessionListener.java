package com.redsam.audit;

import java.io.Serializable;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSessionBindingListener;


/**
 * Used for listening to session end events.
 * When session ends (either by user logging off or by session timing out),
 * the  LOGOUT_AT column of the session will be  updated by the process thread
 * 
 * Red Samurai Audit. Version 4.0
 */
public class RedsamAuditSessionListener implements HttpSessionBindingListener, Serializable {
    private String auditId;
    private String username;

    public RedsamAuditSessionListener(String auditId, String username) {
        this.auditId = auditId;
        this.username = username;

    }

    public void valueBound(HttpSessionBindingEvent event) {
        if (!LogManager.isAuditDisabled) {
            Map<String, Object> info = new HashMap<String, Object>();
            info.put("sessionId", auditId);
            info.put("username", username);
            info.put("loggedOn", LogManager.getSysdate());
            info.put("loggedOff", new java.sql.Timestamp(0));
            info.put("loginEvent", Boolean.TRUE);
            LogManager.logSession(info); 
        }
    }

    /**
     * Fires an Log-Off Event, basically updating the record inserted at Log-On Event.
     * @param event
     */
    public void valueUnbound(HttpSessionBindingEvent event) {
        if (!LogManager.isAuditDisabled) {
            if (auditId != null) {
                Map<String, Object> info = new HashMap<String, Object>();
                info.put("sessionId", auditId);
                info.put("loggedOff", LogManager.getSysdate());
                info.put("loginEvent", Boolean.FALSE);
                LogManager.logSession(info);
            }
        }
    }


}
