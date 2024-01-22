package com.bayer.ipms.model.base;

import java.sql.PreparedStatement;
import java.sql.SQLException;

import oracle.jbo.JboException;
import oracle.jbo.server.ViewRowImpl;

public class IPMSLookupViewRowImpl extends IPMSViewRowImpl implements IPMSLookupViewRow {
    public IPMSLookupViewRowImpl() {
        super();
    }

    public boolean isActive() {
        return getIsActive();
    }

    public String getName() {
        return (String)getAttributeInternal("Name");
    }

    @Override
    public String toString() {
        return getName();
    }

    public String getCode() {
        return (String)getAttributeInternal("Code");
    }

    public Boolean getIsActive() {
        return (Boolean)getAttributeInternal("IsActive");
    }
    
}
