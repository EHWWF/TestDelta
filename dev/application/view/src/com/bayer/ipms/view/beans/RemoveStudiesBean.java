package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.model.views.common.TimelineViewRow;
import com.bayer.ipms.view.dbnotification.DCNManager;
import com.bayer.ipms.view.dbnotification.DCNParams;
import com.bayer.ipms.view.utils.ViewUtils;

import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.share.logging.ADFLogger;
import oracle.adf.view.rich.component.rich.output.RichPanelCollection;
import oracle.adf.view.rich.render.ClientEvent;

import oracle.jbo.Key;
import oracle.jbo.Row;

public class RemoveStudiesBean {
    public RemoveStudiesBean() {
        super();
    }
    ADFLogger logger = ADFLogger.createADFLogger(RemoveStudiesBean.class);

    public void setSyncing() {

        DCIteratorBinding prjVo =
            (DCIteratorBinding) ViewUtils.runValueEl("#{data.com_bayer_ipms_view_remove_studiesPageDef.ProjectViewIterator}");
        ProjectViewRow prjRow = (ProjectViewRow) prjVo.getViewObject().getCurrentRow();
        TimelineViewRow prTimRow = prjRow.getVersions().get("RAW");

        if (prjRow != null) {

            Key key = new Key(new Object[] { prjRow.getTimelineRawId() });

            if (prTimRow != null) {
                prTimRow.setIsSyncing(true);
            }
        }
    }

    public void retrieveStudies() {

        DCIteratorBinding prjVo =
            (DCIteratorBinding) ViewUtils.runValueEl("#{data.com_bayer_ipms_view_remove_studiesPageDef.ProjectViewIterator}");
        ProjectViewRow prjRow = (ProjectViewRow) prjVo.getViewObject().getCurrentRow();

        Key key = new Key(new Object[] { prjRow.getTimelineRawId() });
        TimelineViewRow prTimRow = (TimelineViewRow) prjRow.getTimelineView().getRow(key);

        if (prTimRow != null) {
            class DCNParamsRemoveStudyReceive extends DCNParams

            {
                @Override
                public void executeLogic() {
                    prTimRow.receiveStudies();
                }
            }

            DCNParamsRemoveStudyReceive params = new DCNParamsRemoveStudyReceive();
            params.setNotifyingSelectStmt("select 1 from timeline t where t.notify_id='" + prjRow.getTimelineRawId() +
                                          ":0'");
            params.setLockedObject(this);
            params.setTimeout(180);
            DCNManager.run(params);
        }
    }

    public void submitStudies() {

        DCIteratorBinding prjVo =
            (DCIteratorBinding) ViewUtils.runValueEl("#{data.com_bayer_ipms_view_remove_studiesPageDef.ProjectViewIterator}");
        ProjectViewRow prjRow = (ProjectViewRow) prjVo.getViewObject().getCurrentRow();
        
        String rawId = ((TimelineViewRow) prjRow.getVersions().get("RAW")).getId();

        Key key = new Key(new Object[] { rawId });
        TimelineViewRow prTimRow = (TimelineViewRow) prjRow.getTimelineView().getRow(key);

        if (prTimRow != null) {

            class DCNParamsRemoveStudyReceive extends DCNParams

            {
                @Override
                public void executeLogic() {
                    prTimRow.deleteStudies();
                }
            }

            DCNParamsRemoveStudyReceive params = new DCNParamsRemoveStudyReceive();
            params.setNotifyingSelectStmt("select 1 from timeline t where t.notify_id='" + rawId +
                                          ":0'");
            params.setLockedObject(this);
            params.setTimeout(180);
            DCNManager.run(params);
        }
    }

    public void onPageLoad(ClientEvent clientEvent) {

        String currActivityId = ViewUtils.getCurrTrainActivityId();

        switch (currActivityId) {

        case "receive-data":
            ViewUtils.handleNavigation("receive");
            break;
        case "select":
            ViewUtils.getIteratorBinding("StudyRemoveViewIterator").executeQuery();
            ((RichPanelCollection) ViewUtils.getUiComponent("pc1")).setVisible(true);
            ViewUtils.reloadUiComponent("pc1");
            break;
        case "submit":
            ViewUtils.handleNavigation("submit");
            ViewUtils.reloadUiComponent("t2");
            break;
        case "complete":
            ViewUtils.getIteratorBinding("StudyRemoveViewIterator").executeQuery();
            ((RichPanelCollection) ViewUtils.getUiComponent("pc1")).setVisible(true);
            ViewUtils.reloadUiComponent("pc1");
            break;
        }
    }

    public String getCurrTrainActivityId() {
        return ViewUtils.getCurrTrainActivityId();

    }
}
