package com.bayer.ipms.view.help;

import java.util.ResourceBundle;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;

import oracle.adf.view.rich.help.ResourceBundleHelpProvider;

public class PromisHelpProvider extends ResourceBundleHelpProvider {
    public PromisHelpProvider() {
    }

    @Override
    protected String getExternalUrl(FacesContext context, UIComponent component, String topicId) {

        ResourceBundle resourceBundle= ResourceBundle.getBundle(this.getBaseName());

        if (topicId == null) {
            return null;
        } else {
            return resourceBundle.getString(topicId + "_URL");
        }
    }
}
