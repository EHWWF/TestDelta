package com.bayer.ipms.model.views.common;

import oracle.jbo.Row;
import oracle.jbo.domain.Date;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Jun 07 09:21:24 EEST 2019
// ---------------------------------------------------------------------
public interface ProjectDeviceViewRow extends Row {
    String getProjectId();

    void setProjectId(String value);

    String getId();

    void setId(String value);

    String getRelatedProjectId();

    void setRelatedProjectId(String value);

    String getPrjCode();

    void setPrjCode(String value);

    String getPrjName();

    void setPrjName(String value);

    String getId1();

    Date getUpdateDate();
}

