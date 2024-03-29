package com.bayer.ipms.model.views.ltc.common;

import java.math.BigDecimal;

import java.sql.Date;

import oracle.jbo.Row;
import oracle.jbo.RowIterator;
import oracle.jbo.RowSet;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue Aug 08 12:42:15 EEST 2017
// ---------------------------------------------------------------------
public interface LtcTagViewRow extends Row {
    RowIterator getLtcProcessView();

    RowSet getLtcTagView();

    void refresh();

    Date getCalculateProbDate();

    Date getCreateDate();

    String getFcNumbver();

    BigDecimal getId();

    Boolean getIsForecastProb();

    Boolean getIsFrozen();

    String getName();

    Integer getNextYear();

    Date getPrefilFromProfitDate();

    String getQualifiedName();

    Integer getStartYear();

    Date getSubmitReportDate();

    void setCreateDate(Date value);

    void setIsForecastProb(Boolean value);

    void setIsFrozen(Boolean value);

    void setName(String value);

    void setStartYear(Integer value);

    void setSubmitReportDate(Date value);

    void freeze();    

    void unfreeze();
    
    void calcProb();

    void submit();

    void prefill();

    BigDecimal getParentId();

    void setParentId(BigDecimal value);

    BigDecimal getForecastNumber();

    BigDecimal getNumberOfProfitYears();
}

