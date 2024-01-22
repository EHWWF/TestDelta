package com.bayer.ipms.view.beans;

import com.bayer.ipms.view.base.IPMSBean;
import com.bayer.ipms.view.utils.ViewUtils;

import java.io.IOException;

import java.util.ResourceBundle;

import javax.faces.application.FacesMessage;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import javax.security.auth.Subject;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.login.FailedLoginException;
import javax.security.auth.login.LoginException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import oracle.adf.view.rich.component.rich.input.RichInputText;

import weblogic.security.URLCallbackHandler;
import weblogic.security.services.Authentication;

import weblogic.servlet.security.ServletAuthentication;

public class AuthenticationBean extends IPMSBean {

    private RichInputText inputTextUsername;
    private RichInputText inputTextPassword;


    public AuthenticationBean() {
        super();
    }

    public String login() {
        final FacesContext ctx = FacesContext.getCurrentInstance();
        final HttpServletRequest request = (HttpServletRequest) ctx.getExternalContext().getRequest();

        final String username = getInputTextUsername().getValue().toString().toUpperCase();
        final String password = (String) getInputTextPassword().getValue();

        try {
            CallbackHandler handler = new URLCallbackHandler(username, password.getBytes());
            Subject mySubject = Authentication.login(handler);
            ServletAuthentication.runAs(mySubject, request);
            ServletAuthentication.generateNewSessionID(request);

            String loginUrl = "/adfAuthentication?success_url=" + "/";
            HttpServletResponse response = (HttpServletResponse) ctx.getExternalContext().getResponse();
            ViewUtils.sendForward(request, response, loginUrl);
        } catch (FailedLoginException fle) {
            FacesMessage msg =
                new FacesMessage(FacesMessage.SEVERITY_ERROR, null,
                                 ResourceBundle.getBundle("com.bayer.ipms.view.bundles.viewBundle").getString("loginError"));
            ctx.addMessage(getInputTextPassword().getClientId(ctx), msg);
        } catch (LoginException le) {
            logger.severe("Could not login user '" + username + "'", le);
            ViewUtils.addFacesMessage(le);
        }

        return null;
    }

    public void setInputTextUsername(RichInputText inputTextUsername) {
        this.inputTextUsername = inputTextUsername;
    }

    public RichInputText getInputTextUsername() {
        return inputTextUsername;
    }

    public void setInputTextPassword(RichInputText inputTextPassword) {
        this.inputTextPassword = inputTextPassword;
    }

    public RichInputText getInputTextPassword() {
        return inputTextPassword;
    }

    public void onLogout(ActionEvent actionEvent) {
        FacesContext ctx = FacesContext.getCurrentInstance();
        ExternalContext ectx = ctx.getExternalContext();
        String logoutUrl = "";
        HttpServletRequest request = (HttpServletRequest) ectx.getRequest();
        request.getSession(false).invalidate();
        try {
            request.logout();
            ectx.redirect(logoutUrl);
        } catch (ServletException e) {
            logger.severe("Could not logout", e);
        } catch (IOException e) {
            logger.severe("Could not redirect to '" + logoutUrl + "'", e);
        }
    }
}

