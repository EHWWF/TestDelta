package com.bayer.ipms.model.utils;

import java.util.Map;
import java.util.UUID;

import oracle.adf.model.BindingContext;
import oracle.adf.share.ADFContext;
import oracle.adf.share.logging.ADFLogger;
import oracle.adf.share.security.SecurityContext;

import oracle.binding.AttributeBinding;
import oracle.binding.BindingContainer;

import oracle.jbo.domain.Date;

import oracle.security.idm.IdentityStore;
import oracle.security.jps.JpsContext;
import oracle.security.jps.JpsContextFactory;
import oracle.security.jps.JpsException;
import oracle.security.jps.service.idstore.IdentityStoreService;
import oracle.security.jps.service.policystore.ApplicationPolicy;
import oracle.security.jps.service.policystore.PolicyStore;

public final class ModelUtils {
    private static final ADFLogger logger = ADFLogger.createADFLogger(ModelUtils.class);

    private ModelUtils() {
    }

    public static boolean equals(Date x, Date y) {
        return (x == y || x != null && y != null && x.compareTo(y) == 0);
    }

    public static ApplicationPolicy getApplicationPolicy() throws JpsException {
        JpsContextFactory ctxf = JpsContextFactory.getContextFactory();
        JpsContext ctx = ctxf.getContext();

        PolicyStore policyStore = ctx.getServiceInstance(PolicyStore.class);

        // Application name "ipms-app is used only when runing on integretad server from jdeveloper directly. Even in case of "deploy" to integrated server, app name "ipms" is used.
        // Thus - "ipms-app" is just for development convenience purposes
        for (String name : new String[] { "ipms", "ipms-app" }) {
            try {
                ApplicationPolicy ap = policyStore.getApplicationPolicy(name);

                if (ap != null) {
                    return ap;
                }
            } catch (Exception exc) {
                logger.severe(exc);
                continue;
            }
        }

        return null;
    }

    public static IdentityStore getIdentityStore() throws JpsException {
        JpsContext jpsCtx = JpsContextFactory.getContextFactory().getContext();
        IdentityStoreService idSvc = jpsCtx.getServiceInstance(IdentityStoreService.class);
        return idSvc.getIdmStore();
    }

    public static IPMSArrayList<String> getCurrUserProjectTypes() {

        IPMSArrayList<String> list = new IPMSArrayList<String>();

        SecurityContext sctx = ADFContext.getCurrent().getSecurityContext();

        if (sctx.isUserInRole("ProjectViewRs")) {
            list.add("RS");
        }
        if (sctx.isUserInRole("ProjectViewLg")) {
            list.add("LG");
        }
        if (sctx.isUserInRole("ProjectViewLo")) {
            list.add("LO");
        }
        if (sctx.isUserInRole("ProjectViewD3Tr")) {
            list.add("D3-TR");
        }
        if (sctx.isUserInRole("ProjectViewD2Prj")) {
            list.add("D2-PRJ");
        }
        if (sctx.isUserInRole("ProjectViewSAMD")) {
            list.add("SAMD");
        }
        if (sctx.isUserInRole("ProjectViewPrdMnt")) {
            list.add("PRD-MNT");
        }
        if (sctx.isUserInRole("ProjectViewDev")) {
            list.add("PRE-POT");
            list.add("POST-POT");
        }
        if (sctx.isUserInRole("ProjectViewCo")) {
            list.add("CO");
        }
        if (sctx.isUserInRole("ProjectViewD1")) {
            list.add("D1");
        }

        return list;
    }


    public static IPMSArrayList<String> getCurrUserAssignedProjectTypes() {

        IPMSArrayList<String> list = new IPMSArrayList<String>();

        SecurityContext sctx = ADFContext.getCurrent().getSecurityContext();

        if (sctx.isUserInRole("ProjectViewAssignedD3Tr")) {
            list.add("D3-TR");
        }

        if (sctx.isUserInRole("ProjectViewAssignedPrdMnt")) {
            list.add("PRD-MNT");
        }
        if (sctx.isUserInRole("ProjectViewAssignedDev")) {
            list.add("PRE-POT");
            list.add("POST-POT");
        }

        return list;
    }


    public static AttributeBinding getAttributeBinding(String name) {
        BindingContainer bindingContainer = BindingContext.getCurrent().getCurrentBindingsEntry();
        return (AttributeBinding) bindingContainer.get(name);
    }

    public static void setAttributeBindingValue(String name, Object value) {
        getAttributeBinding(name).setInputValue(value);
    }

    @SuppressWarnings("unchecked")
    public static void setBaCode(String code) {
        Map session = ADFContext.getCurrent().getSessionScope();

        session.put("baCode", code != null ? code : "");
        session.put("uuid", code != null ? UUID.randomUUID().toString() : "");
    }

    public void clearBaCode() {
        setBaCode(null);
    }


}

