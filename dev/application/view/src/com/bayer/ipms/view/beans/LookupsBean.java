package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.services.SharedAppModuleImpl;
import com.bayer.ipms.view.base.IPMSBean;
import com.bayer.ipms.view.utils.ViewUtils;

import java.util.Arrays;

import java.util.Iterator;
import java.util.List;

import oracle.adf.model.binding.DCIteratorBinding;

import oracle.adf.view.rich.component.rich.data.RichTable;

import oracle.adfinternal.view.faces.model.binding.FacesCtrlHierBinding;

import oracle.jbo.ApplicationModule;
import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.RowSet;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewObject;

import oracle.jbo.server.ViewObjectImpl;
import oracle.jbo.server.ViewRowImpl;

import org.apache.myfaces.trinidad.model.CollectionModel;
import org.apache.myfaces.trinidad.model.RowKeySet;
import org.apache.myfaces.trinidad.model.RowKeySetImpl;

public class LookupsBean extends IPMSBean {
    public LookupsBean() {
        super();
    }
    
    public String onCreate() {
        ViewObject vo = (ViewObject)ViewUtils.runValueEl("#{pageFlowScope.lookup.viewObject}");
        vo.getRowSet().reset();
        Row row = vo.createRow();
        row.setAttribute("Code", null);
        row.setAttribute("Name", null);
        if(null != ViewUtils.runValueEl("#{pageFlowScope.lookup}") && ViewUtils.runValueEl("#{bindings.ProjectPlanningCodeView}")!= ViewUtils.runValueEl("#{pageFlowScope.lookup}")) 
        row.setAttribute("Description", null);
        row.setAttribute("IsActive", false);
        row.setNewRowState(Row.STATUS_INITIALIZED);
        vo.insertRow(row);
        vo.setCurrentRow(row);
        //ViewUtils.getIteratorBinding(vo.getName() + "Iterator").setCurrentRowIndexInRange(0);
        
        return null;
    }
    
    
    
    public String onDelete() {
        // Take target table
        RichTable table = (RichTable)ViewUtils.getUiComponent("table");
        RowKeySet keySet = table.getSelectedRowKeys();
        
        // Take target iterator
        DCIteratorBinding iterator = ((FacesCtrlHierBinding)ViewUtils.runValueEl("#{pageFlowScope.lookup}")).getDCIteratorBinding();
        RowSetIterator rsIt  = iterator.getRowSetIterator();
        rsIt.reset();
        
        // loop through selected rows
        for (Iterator it = keySet.iterator(); it.hasNext(); ) {
            List<Key> keys = (List<Key>)it.next();
            ViewRowImpl row = (ViewRowImpl)rsIt.getRow(keys.get(0));
            if (row != null && ( iterator.getName() == "ProjectTerminationReasonsViewIterator" || iterator.getName() == "ProjectPlanningCodeViewIterator" || row.getEntity(0).getEntityState() == Row.STATUS_NEW ) ) {
                row.remove();
            }
        }
        
        return null;
    }
    
    public void onCommit() {
        System.err.println("on commit start");
        ViewUtils.runValueEl("#{bindings.Commit.execute}");
        System.err.println("after commit");
        DCIteratorBinding iterator = ((FacesCtrlHierBinding)ViewUtils.runValueEl("#{pageFlowScope.lookup}")).getDCIteratorBinding();
        String lookupVOInstanceName = iterator.getViewObject().getName();
        System.err.println("lookupVOInstanceName: " + lookupVOInstanceName);
        
        
         
        SharedAppModuleImpl sharedAppModule =
            (SharedAppModuleImpl) ViewUtils.getDataControl("SharedAppModuleDataControl").getDataProvider();
        ViewObjectImpl vo = (ViewObjectImpl)sharedAppModule.findViewObject(lookupVOInstanceName);
        
        if(vo != null) {
            vo.forceExecuteQueryOfSharedVO();
            System.out.println("vo.getRowSets():::: " + vo.getRowSets());
            System.out.println("vo.getRowSets().length:::: " + vo.getRowSets().length);
            if(vo.getRowSets() != null ) {
                for (RowSet rs : vo.getRowSets()) {
                    rs.executeQuery();
                    
               }
            }
        }
        System.err.println("forceExecuteQueryOfSharedVO executed ");
        
        
        
    }
}
