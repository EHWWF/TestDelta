package com.bayer.ipms.model.views.imports.common;

import java.util.Set;

import oracle.jbo.Row;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Mon Sep 28 18:15:51 CEST 2015
// ---------------------------------------------------------------------
public interface ImportStudyViewRow extends Row {


    Set getParentWbsDisclosedKeys();

    Set getParentWbsSelectedKeys();

    void setParentWbsDisclosedKeys(Set value);


    void setParentWbsSelectedKeys(Set value);

    String getName();

    void setIsImport(Boolean value);


    void setParentWbsName(String value);

    void setParentWbsId(String value);
}

