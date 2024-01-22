package com.bayer.ipms.view.base;

import java.io.PrintWriter;
import java.io.StringWriter;

import oracle.adf.share.logging.ADFLogger;

/**
 * Provides logging functionality for extending classes with the help of
 * public LOGGER attribute.
 */
public abstract class IPMSLoggable {
	protected final ADFLogger logger = ADFLogger.createADFLogger(getClass());
}
