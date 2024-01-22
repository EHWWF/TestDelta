package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.ltc.common.LtcProcessViewRow;
import com.bayer.ipms.model.views.ltc.common.LtcProjectViewRow;
import com.bayer.ipms.model.views.ltc.common.LtcTagViewRow;
import com.bayer.ipms.view.base.IPMSViewBean;
import com.bayer.ipms.view.utils.ViewUtils;
import java.util.Arrays;

import javax.faces.application.NavigationHandler;
import javax.faces.context.FacesContext;

import oracle.adf.view.rich.event.DialogEvent;

import oracle.jbo.Row;

import oracle.jbo.RowSetIterator;
import oracle.jbo.server.ViewRowImpl;

import org.apache.myfaces.trinidad.event.ReturnEvent;
import org.apache.myfaces.trinidad.event.SelectionEvent;
import org.apache.myfaces.trinidad.model.RowKeySet;
import org.apache.myfaces.trinidad.model.RowKeySetImpl;

public class LtcViewBean extends IPMSViewBean {
    private static final String LEP_IT = "LtcProcessViewIterator";
    private static final String LEPRJ_IT = "LtcProjectViewIterator";
    private static final String LTC_TAG_IT = "LtcTagViewIterator";  
    
    public LtcViewBean() {
        super(LEP_IT);
    }
     
    public void onLtcUpdateReturn(ReturnEvent returnEvent) {
       ViewUtils.publishEvent("ltcEventBinding");        
    }

    protected void refresh(boolean forced) {
        super.refresh(forced);

        if (forced) {
            ViewUtils.executeIterators("LtcProjectViewIterator");
        }

        ViewUtils.reloadUiComponent("content");
        ViewUtils.publishEvent("ltcEventBinding");
    }

    public String onTerminate() {       
        UtilitiesBean.setBaCode("EstimatesProcessTerminateLTC"); 
        LtcProcessViewRow proc = (LtcProcessViewRow)ViewUtils.getCurrentRow(LEP_IT);
        proc.stop();
        
        UtilitiesBean.setBaCode(null);  
        ViewUtils.getIteratorBinding(LEP_IT).getCurrentRow();
        refresh(false);
        return null;
    }

    public void onReport(DialogEvent event) {
        LtcProcessViewRow proc = (LtcProcessViewRow)ViewUtils.getCurrentRow(LEP_IT);
        proc.submit();
    }

    public void onDelete(DialogEvent event) {
        UtilitiesBean.setBaCode("EstimatesProcessDeleteLTC"); 
        ViewUtils.getIteratorBinding(LEP_IT).removeCurrentRow();
        ViewUtils.getIteratorBinding(LEP_IT).getDataControl().commitTransaction();
        ViewUtils.publishEvent("ltcEventBinding");

        UtilitiesBean.setBaCode(null); 
        ((LtcTagViewRow) ViewUtils.getIteratorBinding(LTC_TAG_IT).getCurrentRow()).refresh();            
        ViewUtils.reloadUiComponent("toolbar", "ltcPlTree");
    }    

    public RowKeySet getProjectSelectedKeys() {
        LtcProjectViewRow prjView = (LtcProjectViewRow) ViewUtils.getIteratorBinding(LEPRJ_IT).getCurrentRow();
        RowKeySet selectedRowKeys = new RowKeySetImpl();

        if (prjView != null) {
            ViewUtils.getIteratorBinding(LEPRJ_IT).setCurrentRowWithKey(prjView.getKey().toStringFormat(true));
            selectedRowKeys.add(Arrays.asList(prjView.getKey()));
        }
        return selectedRowKeys;
    }  


    public void runOkAction () {
        super.onCommit(null);

        ViewUtils.reloadUiComponent("content", "tools");   
        
        NavigationHandler  nvHndlr = FacesContext.getCurrentInstance().getApplication().getNavigationHandler();
        nvHndlr.handleNavigation(FacesContext.getCurrentInstance(), null, "ok");                                
    }

    public Boolean projectAdded() {
        RowSetIterator rsIt = ViewUtils.getIteratorBinding(LEPRJ_IT).getViewObject().createRowSetIterator(null);

        while (rsIt.hasNext()) {
            ViewRowImpl row = (ViewRowImpl) rsIt.next();
            if (row.getEntity(0).getEntityState() == Row.STATUS_NEW) {
                return true;
            }
        }
        return false;
    }

    public void onLtcProjectSelect(SelectionEvent selectionEvent) {
        ViewUtils.runMethodEl("#{bindings.LtcProjectView.collectionModel.makeCurrent}",
                              new Class[] { SelectionEvent.class }, new Object[] { selectionEvent });
        
        ViewUtils.reloadUiComponent("cmdReviewLtcData");
        ViewUtils.reloadUiComponent("cmdReviewFteData");
    }

    public String getDataLtcProjectId() {
        LtcProjectViewRow prjView = (LtcProjectViewRow) ViewUtils.getIteratorBinding(LEPRJ_IT).getCurrentRow();
        if (prjView == null)
            return null;
        return prjView.getProjectId();
    }
}
