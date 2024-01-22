package com.bayer.ipms.view.beans;


import com.bayer.ipms.model.views.common.ProgramView;
import com.bayer.ipms.model.views.common.ProgramViewRow;
import com.bayer.ipms.model.views.common.ProjectView;
import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.view.base.IPMSBean;
import com.bayer.ipms.view.utils.ViewUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.faces.event.ActionEvent;

import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.component.rich.RichPopup;
import oracle.adf.view.rich.component.rich.RichQuery;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.QueryEvent;
import oracle.adf.view.rich.model.QueryDescriptor;

import oracle.jbo.Row;
import oracle.jbo.RowIterator;
import oracle.jbo.RowSetIterator;


public class ProjectTypificationBean extends IPMSBean {
    public ProjectTypificationBean() {
        super();
    }

    public void onApply(ActionEvent event) {
        RichPopup pop = (RichPopup)ViewUtils.getUiComponent("popApply");
        pop.show(new RichPopup.PopupHints());
    }

    public void onApplyConfirmed(DialogEvent event) {
        List<ProjectViewRow> prjSend = new ArrayList<ProjectViewRow>();
        DCIteratorBinding prjIt = ViewUtils.getIteratorBinding("ProjectViewIterator");
        DCIteratorBinding reservedPrgIt = ViewUtils.getIteratorBinding("ReservedProgramsViewIterator");
        DCIteratorBinding allPrgIt = ViewUtils.getIteratorBinding("AllProgramViewIterator");
        Map<String, String> AreaPrgMap = new HashMap<String, String>();
        ProgramView prgVo = (ProgramView)allPrgIt.getViewObject();
        ProjectView prjVo = (ProjectView)prjIt.getViewObject();
        ProgramViewRow prgRow = null;
        boolean prgAssigned = false;

        for (Row row : reservedPrgIt.getRowSetIterator().getAllRowsInRange()) {
            prgRow = (ProgramViewRow)row;
            AreaPrgMap.put(prgRow.getCode(), prgRow.getId());
        }

        int i = 0; //How many rows processed
        int fetchedSize = prjIt.getRowSetIterator().getFetchedRowCount(); //How many rows user has fetched

        while (prjIt.getRowSetIterator().getCurrentRow() != null) {
            i++;
            if (i > fetchedSize) {
                break; //Do not process more rows than user has fetched - no typification made for those anyway
            }

            ProjectViewRow prjRow = (ProjectViewRow)prjIt.getRowSetIterator().getCurrentRow();

            if (prjRow.getAreaCode() != null) {

                if (prjRow.getIsTypifyExcluded()) {
                    RichPopup pop = (RichPopup)ViewUtils.getUiComponent("popInconsErr");
                    pop.show(new RichPopup.PopupHints());
                    return;
                }

                if ("PRD-MNT".equals(prjRow.getAreaCode())) {
                    prgRow = null;
                    prgAssigned = false;
                    RowIterator allPrgRowIt = null;

                    if (prjRow.getImportProgramCode() != null) {

                        prgVo.setProgramCode(prjRow.getImportProgramCode());
                        allPrgRowIt =
                                prgVo.findByViewCriteria(prgVo.getViewCriteriaManager().getViewCriteria("SpecificProgram"),
                                                         1, prgVo.QUERY_MODE_SCAN_DATABASE_TABLES);
                        prgRow = (ProgramViewRow)allPrgRowIt.getRowAtRangeIndex(0);

                        if (prgRow != null) {
                            prjRow.setProgramId(prgRow.getId());
                            prgAssigned = true;

                            // Update program name if it was provided in project
                            if (prjRow.getImportProgramName() != null &&
                                !prjRow.getImportProgramName().equals(prgRow.getName())) {
                                prgRow.setName(prjRow.getImportProgramName());
                            }

                        } else if (prjRow.getImportProgramName() != null) {
                            prjRow.setProgramId(prgVo.createProgram(prjRow.getImportProgramCode(),
                                                                    prjRow.getImportProgramName()));
                            prgAssigned = true;
                        }
                    }
                }

                if (!"PRD-MNT".equals(prjRow.getAreaCode()) || !prgAssigned) {
                    prjRow.setProgramId(AreaPrgMap.get("RESERVED-PT-" + prjRow.getAreaCode()));
                }


                if ("PRD-MNT".equals(prjRow.getAreaCode()) || "D3-TR".equals(prjRow.getAreaCode())) {
                    prjSend.add(prjRow);
                }

            }
            //Move to nex only if current row was not removed and implicitly set to next
            if ((ProjectViewRow)prjIt.getRowSetIterator().getCurrentRow() !=
                null &&
                prjRow.getId() == ((ProjectViewRow)prjIt.getRowSetIterator().getCurrentRow()).getId()) {
                prjIt.getRowSetIterator().next();
            }
        }

        UtilitiesBean.setBaCode("ProjectTypify");
        prjIt.getDataControl().commitTransaction();
        
        for (ProjectViewRow prjRow : prjSend) {

            if ("PRD-MNT".equals(prjRow.getAreaCode())) {
                // Reason for 5 seconds sleep - JIRA CUC-368 (P6 is not capable to process two immediate sequential requests)
                prgVo.send(prjRow.getProgramId(), "dbms_lock.sleep(5); project_pkg.send('" + prjRow.getId() + "');",
                           "create");
            } else {
                prjVo.send(prjRow.getId());
            }
        }
        UtilitiesBean.setBaCode(null);

        RichQuery q = (RichQuery)ViewUtils.getUiComponent("qryId1");
        QueryDescriptor qd = (QueryDescriptor)ViewUtils.runValueEl("#{bindings.UntQuery.queryDescriptor}");
        ViewUtils.runMethodEl("#{bindings.UntQuery.processQuery}", new Class[] { QueryEvent.class },
                              new Object[] { new QueryEvent(q, qd) });
    }


    public String onRefresh() {

        ViewUtils.getIteratorBinding("ProjectViewIterator").executeQuery();

        return null;
    }

}
