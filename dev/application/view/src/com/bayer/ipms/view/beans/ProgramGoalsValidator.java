package com.bayer.ipms.view.beans;

//import com.bayer.ipms.model.views.ProjectViewRowImpl;

import java.text.SimpleDateFormat;

import javax.faces.application.FacesMessage;
import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.validator.ValidatorException;
import javax.faces.validator.Validator;

import java.util.Date;

//import oracle.adf.share.logging.ADFLogger;
import oracle.adf.view.rich.component.rich.input.RichInputDate;

public class ProgramGoalsValidator implements Validator {
    public ProgramGoalsValidator() {
        super();
    }
    //private static final ADFLogger logger = ADFLogger.createADFLogger(ProjectViewRowImpl.class);
    @Override
    public void validate(FacesContext facesContext, UIComponent uiComponent, Object value) {

        String targetDate = (String) uiComponent.getAttributes().get("targetDate");
        Object goalType = (Object) uiComponent.getAttributes().get("goalType");
        String goalSetupYear = (String) uiComponent.getAttributes().get("goalSetupYear");
        Boolean isGpm = (Boolean) uiComponent.getAttributes().get("isGpm");
        String achievedDate = (String) uiComponent.getAttributes().get("achievedDate");
        String revisedDate = (String) uiComponent.getAttributes().get("revisedDate");
        Boolean isEdit = (Boolean) uiComponent.getAttributes().get("isEdit");
        Integer oldYear = null;

        Object oldValue = ((RichInputDate) uiComponent).getValue();
        if (oldValue != null) {
            SimpleDateFormat formatNowYear = new SimpleDateFormat("yyyy");
            oldYear = Integer.parseInt(formatNowYear.format(new Date(oldValue.toString())));
        }
        String attrId = uiComponent.getId();
        
        //logger.severe("!!!!ProgramGoalsValidator1=AttrId =" + attrId + "; Value=" + value + "; targetDate=" + targetDate +
        //                           " ; Old Year=" + oldYear + "; achievedDate=" + achievedDate + "; revisedDate=" +
        //                           revisedDate + "; goalType=" + goalType);
        
        if (isGpm) {

            if (attrId.equals("dc_goaltype")) {
                if (value != null)
                    goalType = value;
            } else if (attrId.equals("dc_targetdate")) {
                if (value != null)
                    targetDate = value.toString();
            } else if (attrId.equals("dc_achievedDate")) {
                if (value != null)
                    achievedDate = value.toString();
            } else if (attrId.equals("dc_revisedDate")) {
                if (value != null)
                    revisedDate = value.toString();
            }

            if (targetDate != null && goalType != null) {

                Integer targetYear = null;
                if (targetDate != null) {
                    SimpleDateFormat formatNowYear = new SimpleDateFormat("yyyy");

                    targetYear = Integer.parseInt(formatNowYear.format(new Date(targetDate)));
                }
                Integer setupYear = null;
                setupYear = Integer.parseInt(goalSetupYear);

                //logger.severe("!!!!ProgramGoalsValidator2=AttrId =" + attrId + "; Value=" + value + "; targetDate=" + targetDate +
                //                   " ; Old Year=" + oldYear + "; achievedDate=" + achievedDate + "; revisedDate=" +
                //                   revisedDate + "; goalType=" + goalType);

                //if (!goalType.equals(1)) {
                if(!goalType.equals("T")) {

                    //KEY or ODC/TA goal
                    if (targetYear < setupYear && attrId.equals("dc_targetdate")) {
                        if (!isEdit || (isEdit && oldYear != null && oldYear >= setupYear)) {
                            throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                                                                          "Goals can be set starting from the year " +
                                                                          setupYear.toString(), null));
                        }
                    } else if (targetYear >= setupYear) {
                        if (achievedDate != null || revisedDate != null) {
                            throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                                                                          "For the goals in Setup phase, no Achieved and Revised dates can be provided.",
                                                                          null));
                        }
                    }
                }
            }
        }
    }
}
