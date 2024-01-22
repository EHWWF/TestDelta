package com.bayer.ipms.model.base;

import java.sql.PreparedStatement;
import java.sql.SQLException;

import oracle.jbo.JboException;
import oracle.jbo.Row;
import oracle.jbo.server.ViewRowImpl;

public interface IPMSLookupViewRow extends Row {

    public String getName();
    public String getCode();
    public Boolean getIsActive();
    public boolean isActive();

}
