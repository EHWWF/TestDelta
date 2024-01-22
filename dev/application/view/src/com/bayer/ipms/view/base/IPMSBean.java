package com.bayer.ipms.view.base;

import com.bayer.ipms.view.beans.ModalStateBean;
import com.bayer.ipms.view.utils.ViewUtils;

import java.io.PrintWriter;
import java.io.Serializable;
import java.io.StringWriter;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;

import javax.servlet.http.HttpServletRequest;

import oracle.adf.model.BindingContext;

import oracle.adf.view.rich.context.AdfFacesContext;

import oracle.binding.BindingContainer;
import oracle.binding.OperationBinding;

public abstract class IPMSBean extends IPMSLoggable implements Serializable {


    /**
     * Retrieves data from the unbounded pageFlowScope, which is unique per browser window.
     * This is necessary for multiple browser tab support to replace the HTTP session managed bean
     * @param key
     * @return
     */
    public static Object getFromUnboundedPageFlowScope(String key) {
        Object value = null;
        oracle.adfinternal.controller.state.AdfcContext adfcContext = oracle.adfinternal
                                                                            .controller
                                                                            .state
                                                                            .AdfcContext
                                                                            .getCurrentInstance();

        if (adfcContext == null)
            return null;

        if (adfcContext.getCurrentRootViewPort() == null)
            return null;
        oracle.adfinternal.controller.state.PageFlowScope pageFlowScope =
            adfcContext.getCurrentRootViewPort().getPageFlowScopeMap(adfcContext);
        value = pageFlowScope.get(key);

        return value;
    }


    /**
     * Sets data into the unbounded pageFlowScope, which is unique per browser window.
     * This is necessary for multiple browser tab support to replace the HTTP session managed bean
     * @param key
     * @return
     */
    public static boolean setIntoUnboundedPageFlowScope(String key, Object value) {

        oracle.adfinternal.controller.state.AdfcContext adfcContext = oracle.adfinternal
                                                                            .controller
                                                                            .state
                                                                            .AdfcContext
                                                                            .getCurrentInstance();

        if (adfcContext == null)
            return false;

        if (adfcContext.getCurrentRootViewPort() == null)
            return false;
        oracle.adfinternal.controller.state.PageFlowScope pageFlowScope =
            adfcContext.getCurrentRootViewPort().getPageFlowScopeMap(adfcContext);
        value = pageFlowScope.put(key, value);

        return true;
    }


    /**
     * returns true if modal mode (edit screen open) is ON
     * otherwise, returns false
     * @return
     */
    public boolean getModalMode() {
        ModalStateBean instance = (ModalStateBean) getFromUnboundedPageFlowScope("modalStateBean");
        if (instance == null) {
            instance = new ModalStateBean();
            boolean result = setIntoUnboundedPageFlowScope("modalStateBean", instance);
        }
        return (instance.isModalStateOn());

    }

    public void setModalModeOn(boolean ignoreIt) {
        System.err.println("setModalModeOn....start");
        ModalStateBean instance = (ModalStateBean) getFromUnboundedPageFlowScope("modalStateBean");
        System.err.println("setModalModeOn....instance" + instance);
        if (instance == null) {
            instance = new ModalStateBean();
            boolean result = setIntoUnboundedPageFlowScope("modalStateBean", instance);
            System.err.println(" setModalModeOn creating a new page flow scope modalStateBean instance. success: " + result);
        }
       instance.setModalStateOn();
       HttpServletRequest req = (HttpServletRequest)FacesContext.getCurrentInstance().getExternalContext().getRequest();
       UIComponent uiComponent = (UIComponent)req.getAttribute("prjTabPanel");
       System.err.println("prjTabPanel...." + uiComponent);
       if (uiComponent != null)
            AdfFacesContext.getCurrentInstance().addPartialTarget(uiComponent);
       
        uiComponent = (UIComponent) req.getAttribute("prgTabPanel");
        if (uiComponent != null)
            AdfFacesContext.getCurrentInstance().addPartialTarget(uiComponent);

        uiComponent = (UIComponent) req.getAttribute("programMenu");
        if (uiComponent != null)
            AdfFacesContext.getCurrentInstance().addPartialTarget(uiComponent);
    }


    public void setModalModeOff(boolean ignoreIt) {
        System.err.println("setModalModeOff....start");
        ModalStateBean instance = (ModalStateBean) getFromUnboundedPageFlowScope("modalStateBean");
        System.err.println("setModalModeOff....instance" + instance);
        if (instance == null) {
            instance = new ModalStateBean();
            boolean result = setIntoUnboundedPageFlowScope("modalStateBean", instance);
            System.err.println(" setModalModeOff creating a new page flow scope modalStateBean instance. success: " + result);
        }
       instance.setModalStateOff();
        HttpServletRequest req = (HttpServletRequest)FacesContext.getCurrentInstance().getExternalContext().getRequest();
        UIComponent uiComponent = (UIComponent)req.getAttribute("prjTabPanel");
        System.err.println("xo prjTabPanel...." + uiComponent);
       
        if (uiComponent != null)
            AdfFacesContext.getCurrentInstance().addPartialTarget(uiComponent);
        
        uiComponent = (UIComponent) req.getAttribute("prgTabPanel");
        if (uiComponent != null)
            AdfFacesContext.getCurrentInstance().addPartialTarget(uiComponent);

        uiComponent = (UIComponent) req.getAttribute("programMenu");
        if (uiComponent != null)
            AdfFacesContext.getCurrentInstance().addPartialTarget(uiComponent);
    }


}
