package com.bayer.ipms.view.converters;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;

public class LinefeedConverter implements Converter {
    public LinefeedConverter() {
        super();
    }

    public Object getAsObject(FacesContext facesContext, UIComponent uIComponent, String value) {
        return value;
    }
    
    public String getAsString(FacesContext facesContext, UIComponent uIComponent, Object value) {
        if (value == null) {
            return "";
        }
        
        if (value instanceof String) {
            return ((String)value).replace("\n", "<br>").replace("\0", "<br>");
        }
        
        return value.toString();
    }
}
