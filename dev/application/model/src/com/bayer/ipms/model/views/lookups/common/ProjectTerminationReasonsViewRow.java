package com.bayer.ipms.model.views.lookups.common;

import oracle.jbo.Row;
import oracle.jbo.RowSet;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Thu Aug 13 09:37:06 EEST 2015
// ---------------------------------------------------------------------
public interface ProjectTerminationReasonsViewRow extends Row {
    RowSet getLOV_TerminationReasonNoRefView();

    RowSet getManagementAppModule_TerminationReasonNoRefView();

    void refresh();

    String getCode();

    Boolean getD1();

    Boolean getD2();

    String getDescription();

    Boolean getDev();

    Boolean getIsActive();

    String getName();

    Boolean getPrdMnt();

    String getRefReasonCode();

    void setCode(String value);

    void setD1(Boolean value);

    void setD2(Boolean value);

    void setDescription(String value);

    void setDev(Boolean value);

    void setIsActive(Boolean value);

    void setName(String value);

    void setPrdMnt(Boolean value);

    void setRefReasonCode(String value);
}

