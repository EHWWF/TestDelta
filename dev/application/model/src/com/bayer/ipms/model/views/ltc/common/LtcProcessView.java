package com.bayer.ipms.model.views.ltc.common;

import com.bayer.ipms.model.views.estimates.common.LatestEstimatesProcessViewRow;

import oracle.jbo.ViewObject;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Thu Jun 29 14:55:02 EEST 2017
// ---------------------------------------------------------------------
public interface LtcProcessView extends ViewObject {


    Boolean isNextYearProcessAvailable(String letId);

    LtcProcessViewRow getRowById(String id);
}

