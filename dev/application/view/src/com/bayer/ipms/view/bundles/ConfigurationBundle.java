package com.bayer.ipms.view.bundles;

import com.bayer.ipms.model.services.common.ManagementAppModule;
import com.bayer.ipms.model.views.lookups.common.ConfigurationViewRow;
import com.bayer.ipms.view.utils.ViewUtils;

import java.util.HashMap;
import java.util.ListResourceBundle;
import java.util.Locale;
import java.util.Map;

import oracle.jbo.ApplicationModule;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewObject;

public class ConfigurationBundle extends ListResourceBundle {
    public ConfigurationBundle() {
        super();
    }
    public Locale getLocaleCode() {
        return Locale.US;
    }
    protected Object[][] getContents() {
        
        ApplicationModule appModule =
            (ApplicationModule) ViewUtils.getDataControl("PrivateAppModuleDataControl").getDataProvider();
        ManagementAppModule managementAppModule =
            (ManagementAppModule) appModule.findApplicationModule("ManagementAppModule");
        ViewObject rsbVo = managementAppModule.findViewObject("ConfigurationResourceView");
        rsbVo.clearCache();
        
        Map<String, String> map = new HashMap<String, String>();
        RowSetIterator rsi = rsbVo.createRowSetIterator(null);

        while (rsi.hasNext()) {
            ConfigurationViewRow cnfRow = (ConfigurationViewRow) rsi.next();
            map.put(cnfRow.getCode(),cnfRow.getValue());
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
