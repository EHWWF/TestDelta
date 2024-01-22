package com.bayer.ipms.view.events;

import com.bayer.ipms.view.utils.ViewUtils;
import javax.faces.application.ViewExpiredException;
import javax.faces.context.FacesContext;
import javax.faces.event.PhaseId;

import oracle.adf.controller.ControllerContext;
import oracle.adf.controller.ViewPortContext;
import oracle.adf.controller.security.AuthorizationException;
import oracle.adf.share.logging.ADFLogger;
import oracle.adf.view.rich.context.ExceptionHandler;

public class ControllerExceptionHandler extends ExceptionHandler {
    protected final ADFLogger logger = ADFLogger.createADFLogger(getClass());

    public ControllerExceptionHandler() {
        super();
    }

    public void handleException() throws Throwable {
        ViewPortContext context = ControllerContext.getInstance().getCurrentViewPort();
        Exception exception = context.getExceptionData();
        
        handleException(exception);
    }

    public void handleException(FacesContext facesContext, Throwable throwable, PhaseId phaseId) {
        handleException(throwable);
    }
    
    private void handleException(Throwable throwable) {
        logger.severe(throwable);
        ViewUtils.addFacesMessage(throwable);
        
        if (throwable instanceof AuthorizationException || throwable instanceof ViewExpiredException) {
            logger.warning("promis:controllerExceptionHandler:handleException:Caught AuthorizationException or ViewExpiredException :handleException:errorMessage="+throwable.getMessage());
            logger.severe("promis:controllerExceptionHandler:handleException:errorMessage="+throwable.getMessage());
        }
    }
}
