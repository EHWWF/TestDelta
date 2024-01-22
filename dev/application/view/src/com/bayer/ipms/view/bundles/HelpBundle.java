package com.bayer.ipms.view.bundles;

import com.bayer.ipms.model.services.common.ManagementAppModule;
import com.bayer.ipms.model.views.common.HelpBundleViewRow;
import com.bayer.ipms.view.utils.ViewUtils;

import java.util.HashMap;
import java.util.ListResourceBundle;
import java.util.Map;

import oracle.jbo.ApplicationModule;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewObject;

public class HelpBundle extends ListResourceBundle {
    public HelpBundle() {
        super();
    }
    
    private final String HELP_PREFIX = "HELP_";
    private final String HELP_DEFINITION_SUFFIX = "_DEFINITION";
    private final String HELP_URL_SUFFIX = "_URL";

    protected Object[][] getContents() {
        
        ApplicationModule appModule =
            (ApplicationModule) ViewUtils.getDataControl("PrivateAppModuleDataControl").getDataProvider();
        ManagementAppModule managementAppModule =
            (ManagementAppModule) appModule.findApplicationModule("ManagementAppModule");
        ViewObject rsbVo = managementAppModule.findViewObject("HelpBundleView");
        rsbVo.clearCache();
        
        Map<String, String> map = new HashMap<String, String>();
        RowSetIterator rsi = rsbVo.createRowSetIterator(null);

        while (rsi.hasNext()) {
            HelpBundleViewRow hbRow = (HelpBundleViewRow) rsi.next();
            map.put(HELP_PREFIX+hbRow.getCode()+HELP_DEFINITION_SUFFIX, hbRow.getDefinition());
            map.put(HELP_PREFIX+hbRow.getCode()+HELP_URL_SUFFIX, hbRow.getUrl());
        }
        rsi.closeRowSetIterator();

        Object[][] resBundle = new Object[map.size()][2];
        int row = 0;
        for (Map.Entry<String, String> entry : map.entrySet()) {

            resBundle[row][0] = entry.getKey();
            resBundle[row][1] = entry.getValue();
            row++;
        }

        return resBundle;
    }

}
