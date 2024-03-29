package com.bayer.ipms.model.views.common;

import java.math.BigDecimal;

import java.sql.Date;

import oracle.jbo.Row;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Thu Jun 06 12:17:13 EEST 2019
// ---------------------------------------------------------------------
public interface ProgramTopVersionViewRow extends Row {
    void setVersion(String value);

    Date getApprovalDate();

    String getDescription();

    String getName();

    void setProgramId(String value);

    String getVersion();

    void setApprovalDate(Date value);

    void setDescription(String value);

    void setId(BigDecimal value);

    void setName(String value);

    void copyTopVersionToCurrent();

    void createTopVersion(String name, Date appDate, String description);
    
    void addMissingSub();
}

