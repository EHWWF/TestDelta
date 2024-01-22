package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.services.common.PrivateAppModule;
import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.model.views.imports.common.ImportD1View;
import com.bayer.ipms.view.utils.ViewUtils;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCDataControl;
import com.bayer.ipms.model.views.lookups.common.ProjectGoalFactorView;
import com.bayer.ipms.model.views.lookups.common.ProjectGoalFactorViewRow;

import java.math.BigDecimal;

import java.util.List;

import oracle.adf.view.rich.component.rich.RichQuery;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.QueryEvent;

import oracle.adf.view.rich.model.AttributeCriterion;
import oracle.adf.view.rich.model.AttributeDescriptor;
import oracle.adf.view.rich.model.Criterion;
import oracle.adf.view.rich.model.QueryDescriptor;

import oracle.jbo.RowSetIterator;
import oracle.jbo.Row;
import oracle.jbo.ViewCriteriaManager;

import org.apache.myfaces.trinidad.event.DisclosureEvent;

public class ProjectD1ViewBean extends ProjectViewBean {
    private static final String PROJECT_D1_VIEW_IT = "ProjectD1ViewIterator";
    private static final String IMPORT_D1_VIEW_IT = "ImportD1ViewIterator";
    private static final String PROJECT_GOAL_FACTOR_VIEW_IT = "ProjectGoalFactorViewIterator";
    private String goalFactorViewCriteria = "ProjectGoalFactorViewCriteria";
    
    public ProjectD1ViewBean() {
        super();
    }

    public void onImportD1(ActionEvent event) {
        UtilitiesBean.setBaCode("ProjectImportD1");
        ViewUtils.getIteratorBinding(IMPORT_D1_VIEW_IT).getDataControl().commitTransaction();
        
        FacesContext context = FacesContext.getCurrentInstance();
        BindingContext bindingContext = BindingContext.getCurrent();
        DCDataControl dc = bindingContext.findDataControl("PrivateAppModuleDataControl");
        PrivateAppModule appModule = (PrivateAppModule) dc.getDataProvider();

        appModule.runStatement("begin import_d1_pkg.start_d1_import; end;", true);
        UtilitiesBean.setBaCode(null);

        ImportD1View impVo = (ImportD1View) ViewUtils.getIteratorBinding(IMPORT_D1_VIEW_IT).getViewObject();

        impVo.executeQuery();

        ViewUtils.reloadUiComponent("tbImpD1");
    }
    
    public void refresh() {
        ViewUtils.getIteratorBinding(PROJECT_D1_VIEW_IT).executeQuery();
        ViewUtils.reloadUiComponent("tbPrjD1");        
    }
    
    public void onProjectD1TabDiscl(DisclosureEvent event) {
        refresh();

    }

    public void onEdit(ActionEvent event) {
        super.onEdit(event);
        refresh();
    }

    public void onCommit(ActionEvent event) {
        UtilitiesBean.setBaCode("ProjectEdit");
        ViewUtils.getIteratorBinding(PROJECT_D1_VIEW_IT).getDataControl().commitTransaction();
        UtilitiesBean.setBaCode(null);
        
        this.editable = null;
        ViewUtils.reloadUiComponent("content", "tools");            
    }

    public void onD1Rollback(ActionEvent event) {      
        this.editable = null;
        ViewUtils.reloadUiComponent("content", "tools");
        refresh();        
    }


    public void fillProjectGoalFactors(ActionEvent actionEvent) {

        BindingContext bindingContext = BindingContext.getCurrent();
        DCDataControl dc = bindingContext.findDataControl("PrivateAppModuleDataControl");
        PrivateAppModule appModule = (PrivateAppModule) dc.getDataProvider();

        ProjectGoalFactorView prjGFVo =
            (ProjectGoalFactorView) ViewUtils.getIteratorBinding(PROJECT_GOAL_FACTOR_VIEW_IT).getViewObject();

        RowSetIterator rsi = prjGFVo.createRowSetIterator(null);
        rsi.reset();

        ProjectGoalFactorViewRow currRow = null;

        while (rsi.hasNext()) {
            currRow = (ProjectGoalFactorViewRow)rsi.next();

            BigDecimal attFactorVal = (BigDecimal) currRow.getAttribute("Factor");

            if (attFactorVal.compareTo(new BigDecimal("1")) != 0) {

                if (currRow.getFactorflag().compareTo(new BigDecimal("-1")) !=0) {
                    appModule.runStatement("begin lookup_pkg.delete_prj_goalFactor(?,?); end;", false,
                                           currRow.getAttribute("ProjectId").toString(),
                                           currRow.getAttribute("MilestoneType").toString());
                }
                appModule.runStatement("begin lookup_pkg.create_prj_goalFactor(?,?,?); end;", false,
                                       currRow.getAttribute("ProjectId").toString(),
                                       currRow.getAttribute("MilestoneType").toString(),
                                       currRow.getAttribute("Factor").toString());
            } else if (attFactorVal.compareTo(new BigDecimal("1")) == 0) {
                if (currRow.getFactorflag().compareTo(new BigDecimal("-1")) !=0) {
                    appModule.runStatement("begin lookup_pkg.delete_prj_goalFactor(?,?); end;", false,
                                           currRow.getAttribute("ProjectId").toString(),
                                           currRow.getAttribute("MilestoneType").toString());
                }
            }
        }
        rsi.closeRowSetIterator();
        
        appModule.runStatement("begin lookup_pkg.synch_prj_goalFactors; end;", false );
    }

    public void customQueryListener(QueryEvent queryEvent) {

        String vcName = queryEvent.getDescriptor().getName();
        if (goalFactorViewCriteria.equals(vcName)) {
            QueryDescriptor qd =
                (QueryDescriptor) ViewUtils.runValueEl("#{bindings.ProjectGoalFactorQuery.queryDescriptor}");
            List<Criterion> criterionList = qd.getConjunctionCriterion().getCriterionList();

            for (Criterion criterion : criterionList) {
                AttributeDescriptor attrDescriptor = ((AttributeCriterion) criterion).getAttribute();

                if (attrDescriptor.getName().equalsIgnoreCase("SrchException")) {
                    ProjectGoalFactorView prjGFVo =
                        (ProjectGoalFactorView) ViewUtils.getIteratorBinding(PROJECT_GOAL_FACTOR_VIEW_IT).getViewObject();

                    ViewCriteriaManager vcmPrj = prjGFVo.getViewCriteriaManager();

                    if (((AttributeCriterion) criterion).getValues().get(0).toString() == "false") {
                        prjGFVo.setSearchGFactorVal(null);
                    } else {
                        prjGFVo.setSearchGFactorVal(true);
                    }
                    vcmPrj.applyViewCriteria(vcmPrj.getViewCriteria(goalFactorViewCriteria), false);
                    prjGFVo.executeQuery();

                    break;
                }
            }

            RichQuery qc = (RichQuery) queryEvent.getComponent();
            ViewUtils.reloadUiComponent("qryGoalFactId1");
        }
    }
    
    public void onUntypify(DialogEvent event) {
        ProjectViewRow prjRow = (ProjectViewRow) ViewUtils.getCurrentRow(PROJECT_D1_VIEW_IT);
        
        prjRow.remove();
    }
}

