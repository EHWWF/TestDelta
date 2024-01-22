package com.redsam.audit;


import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import oracle.i18n.servlet.filter.ServletFilter;


/**
 * Class in charge with start/stoping the statistics collecting Thread.
 * Aditionally, it acts as a servlet filter, wrapping authentication servlet
 *
 * Red Samurai Audit. Version 4.0
 */
public class RedsamAuditProcessManager extends ServletFilter implements ServletContextListener {


    @Override
    public void init(FilterConfig config) throws ServletException {
        super.init(config);

        String diagnosticLevel =
            config.getServletContext().getInitParameter("REDSAMAUDIT_DIAGNOSTIC_LEVEL");
        if (diagnosticLevel != null) {
            LogManager.setDiagnosticLevel(diagnosticLevel);

        }
    }
    
    

    /**
     * Starting the Performance Audit Thread on application-start.
     * @param event
     */
    public void contextInitialized(ServletContextEvent event) {
        if ((!LogManager.isAuditDisabled)) {
            LogManager.startup();   
        }
    }

    /**
     * Stopping the Performance Audit Thread on application-stop.
     * @param event
     */
    public void contextDestroyed(ServletContextEvent event) {
        if ((!LogManager.isAuditDisabled)) {
            LogManager.shutdown();   
        }
    }


    /**
     * Wraps the adfAuthentication Servlet, in order to identify the 'real' ADF login.
     * @param request
     * @param response
     * @param chain
     * @throws IOException
     * @throws ServletException
     */
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException,
                                                   ServletException {
        if (!LogManager.isAuditDisabled) {
            HttpServletRequest req = (HttpServletRequest)request;
            //if loging on (not logging out)
            if (req.getParameter("logout") == null) {
                HttpSession session = req.getSession(true);
                String auditId =
                    session.getId() + "_" + System.currentTimeMillis();
                session.setAttribute("auditId",
                                     new RedsamAuditSessionListener(auditId,
                                                                    req.getUserPrincipal().getName()));

            }
        }
        chain.doFilter(request, response);
    }

}
