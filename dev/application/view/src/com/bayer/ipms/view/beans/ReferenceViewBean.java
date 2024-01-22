package com.bayer.ipms.view.beans;

import com.bayer.ipms.view.base.IPMSViewBean;
import com.bayer.ipms.view.utils.ViewUtils;

import javax.faces.component.UIComponent;
import javax.faces.event.ActionEvent;

import oracle.adf.view.rich.util.ResetUtils;


public class ReferenceViewBean extends IPMSViewBean {

    public ReferenceViewBean() {
        super("ReferenceViewIterator");
    }

    @Override
    public void onCommit(ActionEvent actionEvent) {
        UtilitiesBean.setBaCode("ReferencesMaintain");
        super.onCommit(actionEvent);
        UtilitiesBean.setBaCode(null);

    }

}
