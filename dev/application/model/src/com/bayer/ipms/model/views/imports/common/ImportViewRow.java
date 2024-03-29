package com.bayer.ipms.model.views.imports.common;

import oracle.jbo.Row;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Mon Sep 16 08:36:15 EEST 2013
// ---------------------------------------------------------------------
public interface ImportViewRow extends Row {
    void cancel();

    void start();

    void finish();


    void refresh();

    Integer launch(String projectId, short importType, boolean isManual);

    String getId();

    String getStatusCode();
}
