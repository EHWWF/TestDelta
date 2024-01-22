package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.ltc.common.LtcProcessView;
import com.bayer.ipms.model.views.ltc.common.LtcProcessViewRow;
import com.bayer.ipms.model.views.ltc.common.LtcTagViewRow;
import com.bayer.ipms.view.base.IPMSViewBean;
import com.bayer.ipms.view.utils.ViewUtils;

import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;
import oracle.jbo.RowIterator;
import org.apache.myfaces.trinidad.event.ReturnEvent;

public class LtcTagViewBean extends IPMSViewBean {

    private static final String LET_IT = "LtcTagViewIterator";  
    
    public LtcTagViewBean() {
        super(LET_IT);
    }
    
    public void onLtcStartReturn(ReturnEvent returnEvent) {
        ViewUtils.reloadUiComponent("prcTab");
        ViewUtils.publishEvent("ltcEventBinding");
    }

    public void onTagFreezeConfirm(DialogEvent dialogEvent) {
        UtilitiesBean.setBaCode("EstimatesTagFreezeLTC");  
        LtcTagViewRow letRow = ViewUtils.getCurrentRow(LET_IT);       
        letRow.freeze();
        
        UtilitiesBean.setBaCode(null);  
        ViewUtils.publishEvent("ltcEventBinding");
    }

    public void onTagUnfreezeConfirm(DialogEvent dialogEvent) {
        UtilitiesBean.setBaCode("EstimatesTagUnFreezeLTC");  
        LtcTagViewRow letRow = ViewUtils.getCurrentRow(LET_IT);
        letRow.unfreeze();
        
        UtilitiesBean.setBaCode(null);  
        ViewUtils.publishEvent("ltcEventBinding");
    }

    public boolean isFreezeAllowed() {

        boolean isFreezeAllowed = false;
        LtcTagViewRow letRow = ViewUtils.getCurrentRow(LET_IT);

        if (letRow != null) {
            RowIterator ri = letRow.getLtcProcessView();
            ri.reset();


            while (ri.hasNext()) {
                isFreezeAllowed = true;                
                if (!"FIN".equals(((LtcProcessViewRow) ri.next()).getStatusCode())) {
                    isFreezeAllowed = false;
                    break;
                }
            }
        }
        return isFreezeAllowed;
    }
    
    public void onPopMeetingFetch(PopupFetchEvent popupFetchEvent) {
        ((LtcTagViewRow) ViewUtils.getCurrentRow(LET_IT)).refresh();
    }

    @Override
    public void onPopupSubmit(DialogEvent event) {
        //UtilitiesBean.setBaCode("LtcTagMeetingFinalize");        
        super.onPopupSubmit(event);
        //UtilitiesBean.setBaCode(null);        
    }

    public void onCalcProb(DialogEvent dialogEvent) {
        UtilitiesBean.setBaCode("EstimatesTagCalculateProbLTC");  
        LtcTagViewRow letRow = ViewUtils.getCurrentRow(LET_IT);
        letRow.calcProb();

        UtilitiesBean.setBaCode(null);         
        ViewUtils.publishEvent("ltcEventBinding");
    }

    public void onReport(DialogEvent dialogEvent) {
        LtcTagViewRow letRow = ViewUtils.getCurrentRow(LET_IT);
        letRow.submit();
        
        ViewUtils.publishEvent("ltcEventBinding");
    }
    
    public void onPrefillProfit(DialogEvent dialogEvent) {
        UtilitiesBean.setBaCode("EstimatesTagPrefillLTC"); 
        LtcTagViewRow letRow = ViewUtils.getCurrentRow(LET_IT);
        letRow.prefill();

        UtilitiesBean.setBaCode(null);          
        ViewUtils.publishEvent("ltcEventBinding");
    }
}
