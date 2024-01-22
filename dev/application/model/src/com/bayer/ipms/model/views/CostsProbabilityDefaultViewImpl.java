package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSViewObjectImpl;

import com.bayer.ipms.model.views.common.CostsProbabilityDefaultView;
import com.bayer.ipms.model.views.common.CostsProbabilityDefaultViewRow;
import com.bayer.ipms.model.views.common.CostsProbabilityInternalViewRow;
import com.bayer.ipms.model.views.common.CostsProbabilityViewRow;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import oracle.jbo.RowSetIterator;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Jun 13 15:39:46 EEST 2014
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CostsProbabilityDefaultViewImpl extends IPMSViewObjectImpl implements CostsProbabilityDefaultView {
    private Map<String, CostsProbabilityDefaultViewRow> internal = null;
    
    /**
     * This is the default constructor (do not remove).
     */
    public CostsProbabilityDefaultViewImpl() {
    }
    
    public Map getInternal() {
        if (internal == null) {
            executeQuery();
        }
    
        return internal;
    }
    
    protected void executeQueryForCollection(Object rowset, Object[] params, int noUserParams) {
        super.executeQueryForCollection(rowset, params, noUserParams);
        
        internal = new HashMap<String, CostsProbabilityDefaultViewRow>();
        
        RowSetIterator it = createRowSetIterator(null);
        it.reset();
        
        while (it.hasNext()) {
            CostsProbabilityDefaultViewRow row = (CostsProbabilityDefaultViewRow)it.next();
            internal.put(row.getPhaseCode(), row);
        }
        
        it.closeRowSetIterator();
        
        internal = Collections.unmodifiableMap(internal);
    }
}
