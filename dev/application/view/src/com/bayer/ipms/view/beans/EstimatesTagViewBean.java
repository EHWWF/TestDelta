package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.estimates.common.LatestEstimatesProcessView;
import com.bayer.ipms.model.views.estimates.common.LatestEstimatesProcessViewRow;
import com.bayer.ipms.model.views.estimates.common.LatestEstimatesTagViewRow;
import com.bayer.ipms.view.base.IPMSViewBean;
import com.bayer.ipms.view.utils.ViewUtils;

import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;

import oracle.jbo.RowIterator;

import org.apache.myfaces.trinidad.event.ReturnEvent;

public class EstimatesTagViewBean extends IPMSViewBean {

    private static final String LET_IT = "LatestEstimatesTagViewIterator";
    private static final String LEP_IT = "LatestEstimatesProcessViewIterator";

    public EstimatesTagViewBean() {
        super(LET_IT);
    }


    public void onEstimatesStartReturn(ReturnEvent returnEvent) {
        ViewUtils.reloadUiComponent("prcTab");
        ViewUtils.publishEvent("estimatesEventBinding");
    }

    private void setLetIsFrozen(Boolean value) {

        DCIteratorBinding letIt = ViewUtils.getIteratorBinding(LET_IT);
        LatestEstimatesTagViewRow letVoR = (LatestEstimatesTagViewRow) letIt.getCurrentRow();

        letVoR.setIsFrozen(value);

        UtilitiesBean.setBaCode("EstimatesTagFreeze");
        letIt.getDataControl().commitTransaction();
        UtilitiesBean.setBaCode(null);

        ViewUtils.publishEvent("estimatesEventBinding");

    }

    public void onTagFreezeConfirm(DialogEvent dialogEvent) {
        setLetIsFrozen(true);
    }

    public void onTagUnfreezeConfirm(DialogEvent dialogEvent) {
        setLetIsFrozen(false);
    }

    public boolean isNextYearProcessAvailable() {

        String letId = ((LatestEstimatesTagViewRow) ViewUtils.getCurrentRow(LET_IT)).getId();

        return ((LatestEstimatesProcessView) ViewUtils.getIteratorBinding(LEP_IT).getViewObject()).isNextYearProcessAvailable(letId);
    }

    public boolean isFreezeAllowed() {

        boolean isFreezeAllowed = false;
        LatestEstimatesTagViewRow letRow = ViewUtils.getCurrentRow(LET_IT);

        RowIterator ri = letRow.getLatestEstimatesProcessView();
        ri.reset();

        while (ri.hasNext()) {
            isFreezeAllowed = true;
            if (!((LatestEstimatesProcessViewRow) ri.next()).getStatusCode().equals("FIN")) {
                isFreezeAllowed = false;
                break;
            }
        }
        return isFreezeAllowed;
    }

    public void onPopMeetingFetch(PopupFetchEvent popupFetchEvent) {
        ((LatestEstimatesTagViewRow) ViewUtils.getCurrentRow(LET_IT)).refresh();
    }

    @Override
    public void onPopupSubmit(DialogEvent event) {
        UtilitiesBean.setBaCode("EstimatesTagMeetingFinalize");        
        super.onPopupSubmit(event);
        UtilitiesBean.setBaCode(null);        
    }    
}
