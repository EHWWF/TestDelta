package com.bayer.ipms.model.views.common;

import oracle.jbo.Row;
import oracle.jbo.RowSet;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Jul 01 12:52:45 EEST 2016
// ---------------------------------------------------------------------
public interface CostsProbabilityExternalViewRow extends Row {
    RowSet getFunctionView();

    Integer getProbability();

    RowSet getProbabilityRuleView();
}
