package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.base.IPMSViewRowImpl;
import com.bayer.ipms.model.views.common.PlanAssumptionRequestViewRow;
import com.bayer.ipms.view.utils.ViewUtils;
import com.bayer.ipms.view.base.IPMSBean;

import java.util.List;

import javax.faces.event.ActionEvent;

import oracle.adf.view.rich.component.rich.data.RichTable;
import oracle.adf.view.rich.component.rich.input.RichInputText;
import oracle.adf.view.rich.component.rich.input.RichSelectOneChoice;
import oracle.adf.view.rich.event.QueryEvent;
import oracle.adf.view.rich.model.AttributeCriterion;
import oracle.adf.view.rich.model.ConjunctionCriterion;
import oracle.adf.view.rich.model.Criterion;
import oracle.adf.view.rich.model.FilterableQueryDescriptor;

import org.apache.myfaces.trinidad.event.PollEvent;
import org.apache.myfaces.trinidad.event.ReturnEvent;

public class PlanningAssumptionBean extends IPMSBean {
    public PlanningAssumptionBean() {
    }

    public String onTreeRefresh() {
        ViewUtils.getIteratorBinding("PlanAssumptionRequestViewIterator").executeQuery();
        ViewUtils.getIteratorBinding("GreenListProjectViewIterator").executeQuery();

        ViewUtils.reloadUiComponent("toolbar", "tree");

        return null;
    }

    public String onRefreshGreenListOnly() {
        ViewUtils.getIteratorBinding("GreenListProjectViewIterator").executeQuery();
        ViewUtils.reloadUiComponent("toolbar");

        return null;
    }

    public void ResetGreenListFilter(ActionEvent actionEvent) {
        RichTable table = (RichTable) ViewUtils.getUiComponent("tbGrLst");
        FilterableQueryDescriptor queryDescriptor = (FilterableQueryDescriptor) table.getFilterModel();
        if (queryDescriptor != null && queryDescriptor.getFilterCriteria() != null) {
            queryDescriptor.getFilterCriteria().clear();

            ((RichInputText) ViewUtils.getUiComponent("codeFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("nameFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("gbuNameFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("sbeNameFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("mainGroupNameFilter")).resetValue();
            ((RichSelectOneChoice) ViewUtils.getUiComponent("selIsPortfolio")).resetValue();
            ((RichSelectOneChoice) ViewUtils.getUiComponent("selIsTerminated")).resetValue();
            ((RichSelectOneChoice) ViewUtils.getUiComponent("selIsOnHold")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("controllingProjectTypeFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("commentPreviousFcFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("currentCommentFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("priorityNameFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("phaseNameFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("d3DateFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("d4DateFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("d5DateFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("pocDateFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("d6DateFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("d7DateFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("d8DateFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("probabilityPreclinicalFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("probabilityPhase1Filter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("probabilityPhase2Filter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("probabilityPhase3Filter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("probabilitySubmissionFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("probabilityTotalFilter")).resetValue();

            table.queueEvent(new QueryEvent(table, queryDescriptor));
            ViewUtils.reloadUiComponent("tbGrLst");
        }
    }

    public void ResetRedListFilter(ActionEvent actionEvent) {
        RichTable table = (RichTable) ViewUtils.getUiComponent("tbRdLst");
        FilterableQueryDescriptor queryDescriptor = (FilterableQueryDescriptor) table.getFilterModel();
        if (queryDescriptor != null && queryDescriptor.getFilterCriteria() != null) {
            queryDescriptor.getFilterCriteria().clear();

            ((RichInputText) ViewUtils.getUiComponent("redSbeNameFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("redCodeFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("redNameFilter")).resetValue();
            ((RichInputText) ViewUtils.getUiComponent("redSuccPrjFilter")).resetValue();

            table.queueEvent(new QueryEvent(table, queryDescriptor));
            ViewUtils.reloadUiComponent("tbRdLst");
        }
    }

    public String onRefreshRedListOnly() {
        ViewUtils.getIteratorBinding("RedListProjectViewIterator").executeQuery();
        ViewUtils.reloadUiComponent("toolbar");

        return null;
    }

    public String onRefresh() {
        PlanAssumptionRequestViewRow row =
            (PlanAssumptionRequestViewRow) ViewUtils.getCurrentRow("PlanAssumptionRequestViewIterator");
        if (row == null) {
            return null;
        }

        row.refresh();

        ViewUtils.getIteratorBinding("GreenListProjectViewIterator").executeQuery();

        ViewUtils.reloadUiComponent("toolbar", "content");

        return null;
    }

    public void onPoll(PollEvent pollEvent) {
        PlanAssumptionRequestViewRow row =
            (PlanAssumptionRequestViewRow) ViewUtils.getCurrentRow("PlanAssumptionRequestViewIterator");
        row.refresh();

        ViewUtils.getIteratorBinding("GreenListProjectViewIterator").executeQuery();

        ViewUtils.reloadUiComponent("toolbar", "tree", "content");
    }

    public void onStartReturn(ReturnEvent returnEvent) {
        ViewUtils.getIteratorBinding("LastPlanAssumptionRequestViewIterator").executeQuery();
        ViewUtils.getIteratorBinding("PlanAssumptionRequestViewIterator").executeQuery();
        ViewUtils.getIteratorBinding("GreenListProjectViewIterator").executeQuery();

        ViewUtils.reloadUiComponent("toolbar", "tree");
    }

    public String onTerminate() {
        PlanAssumptionRequestViewRow row =
            (PlanAssumptionRequestViewRow) ViewUtils.getCurrentRow("PlanAssumptionRequestViewIterator");
        row.stop();

        ViewUtils.getIteratorBinding("LastPlanAssumptionRequestViewIterator").executeQuery();
        ViewUtils.getIteratorBinding("PlanAssumptionRequestViewIterator").executeQuery();
        ViewUtils.getIteratorBinding("GreenListProjectViewIterator").executeQuery();

        ViewUtils.reloadUiComponent("toolbar", "tree");

        return null;
    }
}
