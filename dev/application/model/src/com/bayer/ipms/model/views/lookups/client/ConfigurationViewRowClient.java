package com.bayer.ipms.model.views.lookups.client;

import com.bayer.ipms.model.views.lookups.common.ConfigurationViewRow;

import oracle.jbo.RowSet;
import oracle.jbo.client.remote.RowImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Mar 14 12:42:00 EET 2014
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ConfigurationViewRowClient extends RowImpl {
    /**
     * This is the default constructor (do not remove).
     */
    public ConfigurationViewRowClient() {
    }


    public String getCode() {
        return (String) getAttribute("Code");
    }

    public String getValue() {
        return (String) getAttribute("Value");
    }
}
