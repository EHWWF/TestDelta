package com.bayer.ipms.model.utils;

import java.util.ArrayList;

import java.util.Iterator;

import oracle.security.jps.principals.JpsApplicationRole;

public class IPMSArrayList<T> extends ArrayList {
    public IPMSArrayList() {
        super();
    }

    public String toStringList() {

        StringBuffer strList = new StringBuffer();

        for (Iterator it = this.iterator(); it.hasNext(); ) {

            strList.append(it.next());
            strList.append("|");
        }

        return strList.toString();
    }
}
