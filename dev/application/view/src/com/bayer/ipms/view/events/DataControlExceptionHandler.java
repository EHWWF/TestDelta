package com.bayer.ipms.view.events;

import com.bayer.ipms.view.base.IPMSLoggable;

import com.bayer.ipms.view.utils.ViewUtils;

import java.sql.SQLIntegrityConstraintViolationException;

import java.text.MessageFormat;

import java.util.ResourceBundle;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCErrorHandlerImpl;
import oracle.adf.share.logging.ADFLogger;

public class DataControlExceptionHandler extends DCErrorHandlerImpl {
    protected final ADFLogger logger = ADFLogger.createADFLogger(getClass());
    
    public DataControlExceptionHandler() {
        super(true);
    }

    @Override
    public String getDisplayMessage(BindingContext bindingContext, Exception exception) {
        logger.severe(exception.getMessage());
        return ViewUtils.getLocalizedError(exception);
    }
}
