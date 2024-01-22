package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.estimates.common.LatestEstimatesProcessViewRow;
import com.bayer.ipms.model.views.estimates.common.LatestEstimatesTagViewRow;
import com.bayer.ipms.view.base.IPMSViewBean;
import com.bayer.ipms.view.utils.ViewUtils;

import oracle.adf.view.rich.event.DialogEvent;

import org.apache.myfaces.trinidad.event.ReturnEvent;

public class EstimatesViewBean extends IPMSViewBean {

private static final String LEP_IT = "LatestEstimatesProcessViewIterator";
    private static final String LET_IT = "LatestEstimatesTagViewIterator";

    public EstimatesViewBean() {
        super(LEP_IT);
    }

    public void onEstimatesUpdateReturn(ReturnEvent returnEvent) {
        ViewUtils.publishEvent("estimatesEventBinding");
    }

    protected void refresh(boolean forced) {
        super.refresh(forced);

        if (forced) {
            ViewUtils.executeIterators("LatestEstimatesProjectViewIterator");
        }

        ViewUtils.reloadUiComponent("content");
        ViewUtils.publishEvent("estimatesEventBinding");
    }

    public String onTerminate() {
        UtilitiesBean.setBaCode("EstimatesProcessTerminate");        
        LatestEstimatesProcessViewRow proc = (LatestEstimatesProcessViewRow)ViewUtils.getCurrentRow(LEP_IT);
        proc.stop();
        UtilitiesBean.setBaCode(null);
        refresh(false);
        return null;
    }

    public void onReport(DialogEvent event) {
        LatestEstimatesProcessViewRow proc = (LatestEstimatesProcessViewRow)ViewUtils.getCurrentRow(LEP_IT);
        proc.submit();
    }

    public void onDelete(DialogEvent event) {
        UtilitiesBean.setBaCode("EstimatesProcessDelete");
        ViewUtils.getIteratorBinding(LEP_IT).removeCurrentRow();
        ((LatestEstimatesTagViewRow)ViewUtils.getIteratorBinding(LET_IT).getCurrentRow()).doMeetingAllowedRecalc();
        ViewUtils.getIteratorBinding(LEP_IT).getDataControl().commitTransaction();
        ViewUtils.publishEvent("estimatesEventBinding");
        UtilitiesBean.setBaCode(null);        
    }

}
