package com.bayer.ipms.view.base;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import oracle.adf.share.logging.ADFLogger;

public class IPMSSessionExpiryFilter implements Filter {
    
    ADFLogger logger = ADFLogger.createADFLogger(getClass());

    public IPMSSessionExpiryFilter() {
        super();
    }

    public void init(FilterConfig filterConfig) throws ServletException {
    }

    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse,
                         FilterChain filterChain) throws IOException, ServletException {
        final HttpServletRequest httpServletRequest = (HttpServletRequest)servletRequest;
        String requestedSessionId = httpServletRequest.getRequestedSessionId();
        String currentSessionId = httpServletRequest.getSession().getId();
        String requestURI = httpServletRequest.getRequestURI();
        String welcomeUrl = "/ipmsapp/faces/references.jspx";
        
        if (!currentSessionId.equalsIgnoreCase(requestedSessionId)
            && requestedSessionId != null
            && httpServletRequest.getUserPrincipal() == null
            && !requestURI.endsWith(welcomeUrl)) {
        
            logger.severe("promis:IPMSSessionExpiryFilter:Possible timeout detected.");
            logger.severe("promis:IPMSSessionExpiryFilter:requestedSessionId="+requestedSessionId);
            logger.severe("promis:IPMSSessionExpiryFilter:httpServletRequest.getUserPrincipal()="+(httpServletRequest.getUserPrincipal()==null?"true":"false"));
            logger.severe("promis:IPMSSessionExpiryFilter:requestURI.endsWith(welcomeUrl)="+(!requestURI.endsWith(welcomeUrl)?"true":"false"));             
            
            return;
        } else {
            filterChain.doFilter(servletRequest, servletResponse);
        }
    }

    public void destroy() {
    }
}