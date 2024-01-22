package com.bayer.ipms.view.dbnotification;

import java.util.concurrent.CountDownLatch;

import oracle.jdbc.dcn.DatabaseChangeRegistration;

public class CountDownLatchEx extends CountDownLatch {

    private DatabaseChangeRegistration dcr;

    public CountDownLatchEx(int i) {
        super(i);
    }

    public DatabaseChangeRegistration getDcr() {
     
        return dcr;
    }

    public void setDcr(DatabaseChangeRegistration dcrPar) {
        dcr = dcrPar;
    }

}
