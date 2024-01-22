package com.redsam.audit;

import oracle.jbo.SessionData;
import oracle.jbo.common.ampool.AMStatistics;
import oracle.jbo.server.ApplicationModuleImpl;

import org.w3c.dom.Element;

/**
 * Red Samurai Audit. Version 4.0
 */
public class RedsamAuditAMImpl extends ApplicationModuleImpl {
    
    public RedsamAuditAMImpl() {
        super();
    }

    protected void activateState(Element element) {
        super.activateState(element);
        
        if (!LogManager.isAuditDisabled) {
            LogManager.incrementStats(this.getFullName(), STATS.ACTIVATIONS);
        }
    }
    
    @Override
    public byte[] activateState(int i, SessionData sessionData, int i2) {
        if (!LogManager.isAuditDisabled) {
            this.setAmStatisticsTime("amActivationTime", System.currentTimeMillis());
            this.setAmStatisticsTime("lastVoExecutionTime", -1);
            this.setAmStatisticsTime("lastVoActivationTime", -1);
        }
        
        return super.activateState(i, sessionData, i2);
    }
    
    private void setAmStatisticsTime(String statName, long currentTime) {
        AMStatistics.StatsInfo statsInfo = new AMStatistics.CountStatsInfo(currentTime, statName, null);
        this.getRootApplicationModule().getAMStatistics().add(statName + "Stats", statsInfo);
    }
}
