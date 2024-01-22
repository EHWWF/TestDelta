package com.bayer.ipms.view.dbnotification;

import com.bayer.ipms.view.base.IPMSLoggable;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCIteratorBinding;

import oracle.jdbc.dcn.DatabaseChangeEvent;
import oracle.jdbc.dcn.DatabaseChangeListener;


public class DBChangeNotificationListener extends IPMSLoggable implements DatabaseChangeListener {

    CountDownLatchEx latch;
    DBChangeNotification controller;

    DBChangeNotificationListener(DBChangeNotification controller, CountDownLatchEx latch) {
        this.latch = latch;
        this.controller = controller;
    }

    public static DCIteratorBinding getIteratorBinding(String name) {
        return (DCIteratorBinding) BindingContext.getCurrent().getCurrentBindingsEntry().get(name);
    }

    public void onDatabaseChangeNotification(DatabaseChangeEvent e) {

        logger.finest("***** Notification from DB received");

        PromisDBResource.unregisterDCN(latch.getDcr());

        synchronized (latch) {
            latch.countDown();
        }
    }
}
