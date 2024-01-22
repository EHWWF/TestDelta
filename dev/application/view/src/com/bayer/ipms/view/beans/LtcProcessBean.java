package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.ltc.common.LtcProcessViewRow;
import com.bayer.ipms.model.views.ltc.common.LtcProjectViewRow;
import com.bayer.ipms.model.views.common.ProgramView;
import com.bayer.ipms.model.views.common.ProgramViewRow;
import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.model.views.lookups.common.ProjectAreaViewRow;
import com.bayer.ipms.view.base.IPMSBean;

import com.bayer.ipms.view.utils.ViewUtils;

import java.io.Serializable;

import java.util.Iterator;
import java.util.List;

import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.component.rich.data.RichTable;
import oracle.adf.view.rich.component.rich.data.RichTree;
import oracle.adf.view.rich.component.rich.layout.RichShowDetailItem;
import oracle.adf.view.rich.dnd.DnDAction;
import oracle.adf.view.rich.event.DropEvent;
import oracle.adf.view.rich.event.QueryEvent;
import oracle.adf.view.rich.model.AttributeCriterion;
import oracle.adf.view.rich.model.Criterion;
import oracle.adf.view.rich.model.FilterableQueryDescriptor;

import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.RowIterator;
import oracle.jbo.RowSetIterator;

import org.apache.commons.lang.StringUtils;
import org.apache.myfaces.trinidad.event.DisclosureEvent;
import org.apache.myfaces.trinidad.model.CollectionModel;
import org.apache.myfaces.trinidad.model.RowKeySet;

import utils.system;

public class LtcProcessBean extends IPMSBean implements Serializable {

    private static final String IT_LEP = "LtcProcessViewIterator";
    private static final String IT_PRJ = "LtcProjectViewIterator";
    public LtcProcessBean() {
    }
    
    public void onDelete(ActionEvent event) {
        // Take target view
        RichTable target = (RichTable) ViewUtils.getUiComponent("prjSelected");
        RowKeySet keySet = target.getSelectedRowKeys();
        CollectionModel cm = (CollectionModel) target.getValue();

        // Take current process row
        LtcProcessViewRow lepRow = (LtcProcessViewRow) ViewUtils.getCurrentRow(IT_LEP);
        
        // loop through selected rows
        for (Iterator it = keySet.iterator(); it.hasNext();) {
            List<Key> keys = (List<Key>) it.next();
            LtcProjectViewRow prj =
                (LtcProjectViewRow) lepRow.getLtcProjectView().getRow(keys.get(0));
            prj.remove();
        }
        ViewUtils.reloadUiComponent("cmdRemove", "cmdOk");   
    }

    public DnDAction onDrop(DropEvent dropEvent) {

        // Take current process row
        LtcProcessViewRow lepRow = (LtcProcessViewRow) ViewUtils.getCurrentRow(IT_LEP);

        // Take source view
        RichTree source = (RichTree) dropEvent.getDragComponent();
        RowKeySet keySet = source.getSelectedRowKeys();


        // loop through selected rows
        for (Iterator it = keySet.iterator(); it.hasNext();) {
            List<Key> keys = (List<Key>) it.next();

            if ("Dev".equals(source.getId()) || "PrdMnt".equals(source.getId())) {
                // get program
                ProgramViewRow program = (ProgramViewRow) ViewUtils.getIteratorBinding(source.getId() + "ProgramViewIterator").findRowsByKeyValues(new Key[] {
                                                                                                                                                   keys.get(0) }).first();
                // find projects
                if (keys.size() == 1) {

                    RowIterator rit = program.getProjectView();
                    for (Row row = rit.first(); row != null; row = rit.next()) {
                        lepRow.add((ProjectViewRow) row);
                    }
                } else {
                    Row row = program.getProjectView().findByKey(keys.get(1), 1)[0];
                    lepRow.add((ProjectViewRow) row);
                }

            } else {
                ProjectViewRow project = (ProjectViewRow) ViewUtils.getIteratorBinding(source.getId() + "ProjectViewIterator").findRowsByKeyValues(new Key[] {
                                                                                                                                                   keys.get(0) }).first();
                lepRow.add(project);
            }

        }

        ViewUtils.getIteratorBinding("LtcProjectViewIterator").executeQuery();

        ViewUtils.reloadUiComponent("cmdRemove", "cmdOk");    
        return DnDAction.NONE;
    }

    public void onProjectTabDisclose(DisclosureEvent disclosureEvent) {

        RichShowDetailItem detItem = ((RichShowDetailItem) disclosureEvent.getComponent());

        if (detItem.isDisclosed()) {

            if (detItem.getId().equals("diDev")) {
                ((ProgramView) ViewUtils.getIteratorBinding("DevProgramViewIterator").getViewObject()).setSearchVcName("LtcDev");
            } else if (detItem.getId().equals("diPrdMnt")) {
                ((ProgramView) ViewUtils.getIteratorBinding("PrdMntProgramViewIterator").getViewObject()).setSearchVcName("LtcPrdMnt");
            }

        } 
    }

    public void customQueryListener(QueryEvent queryEvent) {

        ProgramView prgVo = (ProgramView) ViewUtils.getIteratorBinding("DevProgramViewIterator").getViewObject();
      
        String vcName = queryEvent.getDescriptor().getName();
        FilterableQueryDescriptor qd = (FilterableQueryDescriptor) queryEvent.getDescriptor();
        List<Criterion> criterionList = qd.getConjunctionCriterion().getCriterionList();

        for (Criterion criterion : criterionList) {

            AttributeCriterion acr = (AttributeCriterion) criterion;
            List<? extends Object> list = acr.getValues();
            StringBuilder strList = null;

            switch (acr.getAttribute().getName()) {

            case "SearchProjectSbeCode":

                strList = new StringBuilder();
                for (int i : (int[]) list.get(0)) {
                    if (i != 0) {
                        strList.append(ViewUtils.getLookupIndexCode("StrategicBusinessEntityView", i - 1)).append("|");
                    }
                }
                if (strList.length()>0){
                prgVo.setSearchSbeCodeVar(StringUtils.stripEnd(strList.toString(), "|"));
                } else { prgVo.setSearchSbeCodeVar(null);}
                break;

            case "SearchProjectAreaCode":

                DCIteratorBinding prjAreaIt = ViewUtils.getIteratorBinding("DevProjectAreaViewIterator");
                strList = new StringBuilder();
                for (int i : (int[]) list.get(0)) {
                    if (i != 0) {
                        strList.append(((ProjectAreaViewRow) prjAreaIt.getRowAtRangeIndex(i -
                                                                                        1)).getCode()).append("|");
                    }
                }
                if (strList.length()>0){
                prgVo.setSearchAreaCodeVar(StringUtils.stripEnd(strList.toString(), "|"));
                } else { prgVo.setSearchAreaCodeVar(null);}
                break;
            
                case "SearchProjectBU":

                    strList = new StringBuilder();
                    for (int i : (int[]) list.get(0)) {
                        if (i != 0) {
                            strList.append(ViewUtils.getManagementLookupIndexCode("TherapeuticAreaView", i - 1)).append("|");
                        }
                    }
                if (strList.length()>0){
                    prgVo.setSearchProjectBUCodeVar(StringUtils.stripEnd(strList.toString(), "|"));
                }else { prgVo.setSearchProjectBUCodeVar(null);}
                    break;
            
                case "SearchProjectDevelopmentPhase":

                    strList = new StringBuilder();
                    for (int i : (int[]) list.get(0)) {
                        if (i != 0) {
                            strList.append(ViewUtils.getLookupIndexCode("DevelopmentPhaseView", i - 1)).append("|");
                        }
                    }
                if (strList.length()>0){
                    prgVo.setSearchProjectDevPhaseVar(StringUtils.stripEnd(strList.toString(), "|"));
                }else { prgVo.setSearchProjectDevPhaseVar(null);}
                    break;
            }
        }

       ViewUtils.runMethodEl("#{bindings." + vcName + "Query.processQuery}", new Class[] { QueryEvent.class }, new Object[] {
                              queryEvent });
        ((RichTree) ViewUtils.getUiComponent("Dev")).getSelectedRowKeys().clear();


    }

    public Boolean getContainsProjects() {

        // Take current process row
        LtcProcessViewRow lepRow = (LtcProcessViewRow) ViewUtils.getCurrentRow(IT_LEP);

        if ((LtcProjectViewRow) lepRow.getLtcProjectView().first() == null) {
            return false;
        } else {
            return true;
        }
    }   

    public void onPrefillProcessChange(ValueChangeEvent event) {

        LtcProcessViewRow lepRow = (LtcProcessViewRow) ViewUtils.getCurrentRow(IT_LEP);

        lepRow.removeAllProjects();

        //Do not process any prefill if "blank" selected
        if (event.getNewValue() instanceof String && ((String) event.getNewValue()).equals("blank")) {
            return;
        }

        ViewUtils.getIteratorBinding("ParentTagProcessViewIterator").setCurrentRowIndexInRange((Integer) event.getNewValue());

        DCIteratorBinding srcPrjIt = ViewUtils.getIteratorBinding("ParentTagProjectViewIterator");
        srcPrjIt.executeQuery();

        RowSetIterator rsi = srcPrjIt.getViewObject().createRowSetIterator(null);

        while (rsi.hasNext()) {
            lepRow.add((LtcProjectViewRow) rsi.next());
        }

        rsi.closeRowSetIterator();
        
        ViewUtils.getIteratorBinding(IT_LEP).executeQuery();
        ViewUtils.getIteratorBinding(IT_PRJ).executeQuery();

        ViewUtils.reloadUiComponent("cmdRemove", "cmdOk");
    }

}
