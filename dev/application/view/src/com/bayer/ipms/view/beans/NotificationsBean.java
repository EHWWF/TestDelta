package com.bayer.ipms.view.beans;

import com.bayer.ipms.view.base.IPMSBean;
import com.bayer.ipms.view.utils.ViewUtils;

import oracle.jbo.Row;

public class NotificationsBean extends IPMSBean {
    public NotificationsBean() {
        super();
    }
    
    
    public boolean isMilestoneInSequence() {
        Row row = ViewUtils.getIteratorBinding("QplanMilestonesViewIterator").getCurrentRow();
        return (Boolean)ViewUtils.getOperationBinding("isMilestonesInSequence").execute();
    }
}
