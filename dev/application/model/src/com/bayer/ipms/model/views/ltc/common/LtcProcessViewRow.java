package com.bayer.ipms.model.views.ltc.common;

import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.model.views.estimates.common.LatestEstimatesProjectViewRow;

import java.math.BigDecimal;

import oracle.jbo.Row;
import oracle.jbo.RowIterator;
import oracle.jbo.RowSet;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Thu Jun 29 14:44:00 EEST 2017
// ---------------------------------------------------------------------
public interface LtcProcessViewRow extends Row {

    void stop();
    void submit();

    RowIterator getLtcProjectView();

    String getComments();

    BigDecimal getId();

    String getName();

    void setId(BigDecimal value);

    Row getLtcTagView();

    void add(ProjectViewRow project);

    void refresh();

    void restart();

    void start();

    String getStatusCode();

    String getQualifiedName();

    String getUpdateUserId();

    void removeAllProjects();

    void add(LtcProjectViewRow leprRow);
}
