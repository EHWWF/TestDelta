package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.common.ProgramTopSubCategoryViewRow;
import com.bayer.ipms.model.views.common.TppSubcategoryViewRow;
import com.bayer.ipms.view.base.IPMSBean;
import com.bayer.ipms.view.utils.ViewUtils;

import java.util.ResourceBundle;

import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.binding.DCIteratorBinding;

import oracle.jbo.Row;

public class AdministrationBean extends IPMSBean {
    public AdministrationBean() {
        super();
    }

    public void onDeleteTppCat(ActionEvent event) {
        ViewUtils.getOperationBinding("DeleteCat").execute();
        ViewUtils.reloadUiComponent("tabCat");
    }

    public void onDeleteTppSubc(ActionEvent event) {
        ViewUtils.getOperationBinding("DeleteSubc").execute();
        ViewUtils.reloadUiComponent("tabSubc");
    }

    public void onCreateTppCat(ActionEvent event) {
        ViewUtils.getOperationBinding("CreateInsertCat").execute();
        ViewUtils.reloadUiComponent("tabCat", "tabSubc");
    }


    public void onTppCatActiveValueChange(ValueChangeEvent event) {

        if (!(Boolean) event.getNewValue()) {
            DCIteratorBinding it = ViewUtils.getIteratorBinding("TppSubcategoryViewIterator");
            it.setRangeSize(-1);

            Row rows[] = it.getAllRowsInRange();

            for (Row row : it.getAllRowsInRange()) {
                ((TppSubcategoryViewRow) row).setIsActive(false);
            }
            it.setRangeSize(100);
        }
        ViewUtils.reloadUiComponent("tabSubc", "btnAddSubc");

    }

    public void clearHelpCache() {

        ResourceBundle helpBundle = ResourceBundle.getBundle("com.bayer.ipms.view.bundles.HelpBundle");
        helpBundle.clearCache();
    }
    
    public void onDeleteTopTemplateCat(ActionEvent event) {
        ViewUtils.getOperationBinding("DeleteCat").execute();
        ViewUtils.reloadUiComponent("tabTopCat");
    }

    public void onDeleteTopTemplateSubc(ActionEvent event) {
        ViewUtils.getOperationBinding("DeleteSubCat").execute();
        ViewUtils.reloadUiComponent("tabTopSubc");
    }

    public void onCreateTopTemplateCat(ActionEvent event) {
        ViewUtils.getOperationBinding("CreateInsertCat").execute();
        ViewUtils.reloadUiComponent("tabTopCat", "tabTopSubc");
    }
    
    public void onTopTemplateCatActiveValueChange(ValueChangeEvent event) {

        if (!(Boolean) event.getNewValue()) {
            DCIteratorBinding it = ViewUtils.getIteratorBinding("ProgramTopSubCategoryViewIterator");
            it.setRangeSize(-1);

            Row rows[] = it.getAllRowsInRange();

            for (Row row : it.getAllRowsInRange()) {
                ((ProgramTopSubCategoryViewRow) row).setIsActive(false);
            }
            it.setRangeSize(100);
        }
        ViewUtils.reloadUiComponent("tabTopSubc", "btnAddSubCat");
    }   
}
