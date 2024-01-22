package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.common.LtcInstanceViewRow;
import com.bayer.ipms.model.views.common.LtcValueViewRow;
import com.bayer.ipms.view.base.IPMSBean;
import com.bayer.ipms.view.utils.U;
import com.bayer.ipms.view.utils.ViewUtils;

import java.io.IOException;
import java.io.OutputStream;

import java.util.HashSet;

import java.util.ResourceBundle;

import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import javax.faces.validator.ValidatorException;

import oracle.adf.view.rich.component.rich.data.RichTreeTable;

import oracle.adf.view.rich.event.DialogEvent;

import oracle.jbo.RowSetIterator;
import oracle.jbo.domain.generic.GenericClob;
import oracle.jbo.uicli.binding.JUCtrlHierBinding;
import oracle.jbo.uicli.binding.JUCtrlHierNodeBinding;

import org.apache.commons.io.IOUtils;
import org.apache.myfaces.trinidad.event.PollEvent;
import org.apache.myfaces.trinidad.event.SelectionEvent;
import org.apache.myfaces.trinidad.model.CollectionModel;
import org.apache.myfaces.trinidad.model.RowKeySetImpl;


public class LtcBean extends IPMSBean {

    private static final String LTC_PLAN_IT = "LtcPlanViewIterator";
    private static final String LTC_PLAN_ROOT_IT = "LtcPlanRootViewIterator";
    private static final String LTC_INSTANCE_IT = "LtcInstanceViewIterator";
    private static final String LTC_VALUE_IT = "LtcValueViewIterator";
    private boolean isUserActionPerformed = false;
    private RowKeySetImpl ltcDisclosedTreeKeys;

    public LtcBean() {
        super();

    }


    public boolean getIsUserActionPerformed() {
        return isUserActionPerformed;
    }

    public String refresh() {

        LtcInstanceViewRow ltcRow = (LtcInstanceViewRow) ViewUtils.getCurrentRow(LTC_INSTANCE_IT);
        ltcRow.refresh();

        if (ltcRow.getStatusCode().equals("READY")) {
            ViewUtils.getIteratorBinding(LTC_PLAN_ROOT_IT).executeQuery();
            ViewUtils.getIteratorBinding(LTC_PLAN_IT).executeQuery();
        }

        return null;
    }

    public void onPoll(PollEvent pollEvent) {
        refresh();
    }

    public void onPoll2(PollEvent pollEvent) {

        LtcInstanceViewRow ltcRow = (LtcInstanceViewRow) ViewUtils.getCurrentRow(LTC_INSTANCE_IT);
        ltcRow.refresh();
    }


    public void onRefresh(ActionEvent actionEvent) {
        refresh();
    }


    private void doFunctionUniqueCheck() {

        HashSet<String> fncUnique = new HashSet<String>();
        RowSetIterator rsi = ViewUtils.getIteratorBinding(LTC_VALUE_IT).getRowSetIterator();
        rsi.reset();

        int cnt = 0;

        if (rsi != null) {

            if (rsi.getCurrentRow() != null) {
                fncUnique.add(((LtcValueViewRow) rsi.getCurrentRow()).getFunctionCode());
                cnt++;
            }

            while (rsi.hasNext()) {
                fncUnique.add(((LtcValueViewRow) rsi.next()).getFunctionCode());
                cnt++;
            }

            if (fncUnique.size() < cnt) {
                FacesContext ctx = FacesContext.getCurrentInstance();
                FacesMessage errorMessage =
                    new FacesMessage(FacesMessage.SEVERITY_ERROR,
                                     ResourceBundle.getBundle("com.bayer.ipms.view.bundles.viewBundle").getString("ltcFunctionDuplicatesNotAllowed"),
                                     null);
                //ctx.addMessage(ViewUtils.getUiComponent("tblDet").getClientId(ctx), errorMessage);
                throw new ValidatorException(errorMessage);
            }
        }
    }

    public void onApplyValues(ActionEvent actionEvent) {

        doFunctionUniqueCheck();

        ViewUtils.getIteratorBinding(LTC_VALUE_IT).getDataControl().commitTransaction();

        LtcInstanceViewRow ltcRow = (LtcInstanceViewRow) ViewUtils.getCurrentRow(LTC_INSTANCE_IT);
        ltcRow.recalculateTotals();

        ViewUtils.getIteratorBinding(LTC_PLAN_ROOT_IT).executeQuery();
        ViewUtils.getIteratorBinding(LTC_VALUE_IT).executeQuery();

    }

    public void onSubmit(ActionEvent actionEvent) {
        onApplyValues(actionEvent);
    }


    public void onPlanTreeSelect(SelectionEvent selectionEvent) {

        doFunctionUniqueCheck();

        ViewUtils.runMethodEl("#{bindings.LtcPlanView.treeModel.makeCurrent}", new Class[] { SelectionEvent.class },
                              new Object[] { selectionEvent });
        isUserActionPerformed = true;
        
        ViewUtils.reloadUiComponent("tblDet");
    }

    public void onPrefillFps(DialogEvent actionEvent) {

        LtcInstanceViewRow ltcRow = (LtcInstanceViewRow) ViewUtils.getCurrentRow(LTC_INSTANCE_IT);
        ltcRow.prefill();

        ViewUtils.getIteratorBinding(LTC_VALUE_IT).executeQuery();
        ViewUtils.getIteratorBinding(LTC_PLAN_ROOT_IT).executeQuery();

        ViewUtils.reloadUiComponent("tblDet", "treePlan");
    }

    public void onPrefillProfit(DialogEvent actionEvent) {

        LtcInstanceViewRow ltcRow = (LtcInstanceViewRow) ViewUtils.getCurrentRow(LTC_INSTANCE_IT);
        ltcRow.prefillProfit();

        ViewUtils.getIteratorBinding(LTC_VALUE_IT).executeQuery();
        ViewUtils.getIteratorBinding(LTC_PLAN_ROOT_IT).executeQuery();

        ViewUtils.reloadUiComponent("tblDet", "treePlan");
    }

    public void onReport(FacesContext facesContext, OutputStream outputStream) {

        LtcInstanceViewRow ltciRow = (LtcInstanceViewRow) ViewUtils.getCurrentRow(LTC_INSTANCE_IT);
        GenericClob cl = (GenericClob) ltciRow.getExcelReport();

        try {
            IOUtils.copy(cl.getCharacterStream(), outputStream);
            cl.closeCharacterStream();
            outputStream.flush();
        } catch (IOException e) {
            logger.severe("Could not generate Excel output stream: " + e.getStackTrace());
        }

    }

    /**
     * Used in the tree table to disclose all children per default.
     * @return set of disclosed node keys.
     */
    public RowKeySetImpl getLtcDisclosedTreeKeys() {
        if (this.ltcDisclosedTreeKeys == null) {
            this.ltcDisclosedTreeKeys = new RowKeySetImpl();

            RichTreeTable tt = (RichTreeTable) ViewUtils.getUiComponent("treePlan");
            CollectionModel cm = (CollectionModel) tt.getValue();

            if (cm != null) {

                JUCtrlHierBinding treeBinding = (JUCtrlHierBinding) cm.getWrappedData();
                JUCtrlHierNodeBinding nodeBinding = treeBinding.getRootNodeBinding();

                ViewUtils.collectAllNodes(nodeBinding, this.ltcDisclosedTreeKeys);
            }
        }

        return this.ltcDisclosedTreeKeys;
    }

    public void onCancel(ActionEvent actionEvent) {
        LtcInstanceViewRow ltcRow = (LtcInstanceViewRow) ViewUtils.getCurrentRow(LTC_INSTANCE_IT);
        ltcRow.setStatusCode("FAIL");
        ltcRow.setStageNumber(0);
        ViewUtils.getIteratorBinding(LTC_INSTANCE_IT).getDataControl().commitTransaction();
    }
}
