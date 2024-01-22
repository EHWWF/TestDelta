package com.bayer.ipms.view.beans;

import com.bayer.ipms.view.base.IPMSBean;

public class ModalStateBean extends IPMSBean {
    
    public ModalStateBean() {
        System.err.println("\n\n\n new instance of ModalStateBean!");
    }
    
    private boolean modalStateOn;

    public void setModalStateOn() {
        this.modalStateOn = true;
    }
    
    public void setModalStateOff() {
        this.modalStateOn = false;
    }

    public boolean isModalStateOn() {
        return modalStateOn;
    }
}
