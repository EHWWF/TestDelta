package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.common.LeadStudyInstanceViewRow;
import com.bayer.ipms.model.views.common.TimelineViewRow;
import com.bayer.ipms.model.views.imports.common.ImportView;
import com.bayer.ipms.model.views.imports.common.ImportViewRow;
import com.bayer.ipms.view.base.IPMSBean;
import com.bayer.ipms.view.dbnotification.DCNManager;
import com.bayer.ipms.view.dbnotification.DCNParams;
import com.bayer.ipms.view.utils.ViewUtils;

import javax.faces.event.ActionEvent;

import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.component.rich.input.RichSelectOneChoice;
import oracle.adf.view.rich.component.rich.nav.RichButton;
import oracle.adf.view.rich.component.rich.output.RichOutputText;
import oracle.adf.view.rich.component.rich.output.RichPanelCollection;
import oracle.adf.view.rich.render.ClientEvent;

import oracle.jbo.server.ViewRowImpl;


public class ActivitiesPhasesBean extends IPMSBean {
    public ActivitiesPhasesBean() {
    }

    private String importStatusCode;

    private ImportViewRow getImportRow() {

        DCIteratorBinding importIt =
            (DCIteratorBinding) ViewUtils.runValueEl("#{data.com_bayer_ipms_view_activities_set_phases_activities_set_phases_CreateWithParametersPageDef.ImportViewIterator}");
        return (ImportViewRow) importIt.getViewObject().getCurrentRow();

    }

    public void loadActivities() {

        final ImportViewRow importRow = getImportRow();

        class DCNParamsLoadActivities extends DCNParams

        {
            @Override
            public void executeLogic() {
                importRow.start();
            }
        }

        DCNParamsLoadActivities params = new DCNParamsLoadActivities();
        params.setNotifyingSelectStmt("select id from import imp where imp.notify_id='" + importRow.getId() +
                                      ":READY' or imp.notify_id='" + importRow.getId() + ":DONE' or imp.notify_id='" +
                                      importRow.getId() + ":FAIL'");
        params.setLockedObject(this);
        params.setTimeout(180);
        DCNManager.run(params);

    }

    public void submitActivities() {

        final ImportViewRow importRow = getImportRow();

        class DCNParamsLoadActivities extends DCNParams

        {
            @Override
            public void executeLogic() {
                importRow.finish();
            }
        }

        DCNParamsLoadActivities params = new DCNParamsLoadActivities();
        params.setNotifyingSelectStmt("select id from import imp where imp.notify_id='" + importRow.getId() + ":DONE'");
        params.setLockedObject(this);
        params.setTimeout(180);
        DCNManager.run(params);
    }

    public void onPageLoad(ClientEvent clientEvent) {

        String currActivityId = ViewUtils.getCurrTrainActivityId();

        switch (currActivityId) {

            case "receive-data":
                ViewUtils.handleNavigation("receive");
                break;
            case "maintain":

                ImportViewRow impRow =
                    (ImportViewRow) ViewUtils.getIteratorBinding("ImportViewIterator").getCurrentRow();

                impRow.refresh(ViewRowImpl.REFRESH_WITH_DB_FORGET_CHANGES);

                importStatusCode = impRow.getStatusCode();

                if (("DONE").equals(importStatusCode)) {

                    ((RichOutputText) ViewUtils.getUiComponent("otEmpty")).setVisible(true);
                    ((RichButton) ViewUtils.getUiComponent("b3")).setVisible(false);

                } else if (("FAIL").equals(importStatusCode)) {

                    ((RichButton) ViewUtils.getUiComponent("b3")).setVisible(false);

                    TimelineViewRow tmlRow =
                        (TimelineViewRow) ViewUtils.getIteratorBinding("TimelineRawViewIterator").getCurrentRow();

                    tmlRow.refresh(ViewRowImpl.REFRESH_WITH_DB_FORGET_CHANGES);
                    Boolean isPaConflict = tmlRow.getIsPaConflict();

                    if (isPaConflict) {
                        ((RichOutputText) ViewUtils.getUiComponent("otDuplicates")).setVisible(true);
                    } else {
                        ((RichOutputText) ViewUtils.getUiComponent("otError")).setVisible(true);
                    }

                } else {

                    ViewUtils.getIteratorBinding("ImportProjectActivityViewIterator").executeQuery();
                    ((RichPanelCollection) ViewUtils.getUiComponent("pc1")).setVisible(true);

                }

                ViewUtils.reloadUiComponent("g1", "pgl12");

                break;

            case "submit":
                ViewUtils.handleNavigation("submit");
                ViewUtils.reloadUiComponent("t2");
                break;
            case "complete":
                ViewUtils.getIteratorBinding("ImportProjectActivityViewIterator").executeQuery();
                ((RichPanelCollection) ViewUtils.getUiComponent("pc1")).setVisible(true);
                ((RichSelectOneChoice) ViewUtils.getUiComponent("soc1")).setReadOnly(true);
                ViewUtils.reloadUiComponent("pc1");
                break;

        }


    }

    public String getCurrTrainActivityId() {
        return ViewUtils.getCurrTrainActivityId();

    }

    public String getImportStatusCode() {
        return importStatusCode;

    }

}
