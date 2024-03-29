package com.bayer.ipms.model.services;

import com.bayer.ipms.model.base.IPMSApplicationModuleImpl;
import com.bayer.ipms.model.base.IPMSViewObjectImpl;
import com.bayer.ipms.model.services.common.LtcAppModule;
import com.bayer.ipms.model.utils.ModelUtils;
import com.bayer.ipms.model.utils.U;
import com.bayer.ipms.model.views.ProgramViewImpl;
import com.bayer.ipms.model.views.ProjectViewImpl;
import com.bayer.ipms.model.views.estimates.common.LatestEstimatesProcessView;
import com.bayer.ipms.model.views.estimates.common.LatestEstimatesProcessViewRow;
import com.bayer.ipms.model.views.estimates.common.LatestEstimatesTagView;
import com.bayer.ipms.model.views.estimates.common.LatestEstimatesTagViewRow;
import com.bayer.ipms.model.views.lookups.ProjectAreaViewImpl;
import com.bayer.ipms.model.views.ltc.LtcEstimateViewImpl;
import com.bayer.ipms.model.views.ltc.LtcProcessViewImpl;
import com.bayer.ipms.model.views.ltc.LtcProjectViewImpl;

import com.bayer.ipms.model.views.ltc.LtcTagViewImpl;
import com.bayer.ipms.model.views.ltc.common.LtcTagViewRow;

import java.sql.Types;

import java.math.BigDecimal;

import oracle.jbo.server.ViewLinkImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Mon Jul 31 16:12:00 EEST 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class LtcAppModuleImpl extends IPMSApplicationModuleImpl implements LtcAppModule {

    /**
     * This is the default constructor (do not remove).
     */
    public LtcAppModuleImpl() {
    }

    /**
     * Container's getter for LtcTagView.
     * @return LtcTagView
     */
    public LtcTagViewImpl getLtcTagView() {
        return (LtcTagViewImpl) findViewObject("LtcTagView");
    }

    /**
     * Container's getter for LtcProcessView.
     * @return LtcProcessView
     */
    public LtcProcessViewImpl getLtcProcessView() {
        return (LtcProcessViewImpl) findViewObject("LtcProcessView");
    }

    /**
     * Container's getter for LtcProjectView.
     * @return LtcProjectView
     */
    public LtcProjectViewImpl getLtcProjectView() {
        return (LtcProjectViewImpl) findViewObject("LtcProjectView");
    }

    /**
     * Container's getter for LtcEstimateView.
     * @return LtcEstimateView
     */
    public LtcEstimateViewImpl getLtcEstimateView() {
        return (LtcEstimateViewImpl) findViewObject("LtcEstimateView");
    }

    /**
     * Container's getter for DevProgramView.
     * @return DevProgramView
     */
    public ProgramViewImpl getDevProgramView() {
        return (ProgramViewImpl) findViewObject("DevProgramView");
    }

    /**
     * Container's getter for D3TrProjectView.
     * @return D3TrProjectView
     */
    public ProjectViewImpl getD3TrProjectView() {
        return (ProjectViewImpl) findViewObject("D3TrProjectView");
    }

    /**
     * Container's getter for DevProjectAreaView.
     * @return DevProjectAreaView
     */
    public ProjectAreaViewImpl getDevProjectAreaView() {
        return (ProjectAreaViewImpl) findViewObject("DevProjectAreaView");
    }

    /**
     * Container's getter for PrdMntProgramView.
     * @return PrdMntProgramView
     */
    public ProgramViewImpl getPrdMntProgramView() {
        return (ProgramViewImpl) findViewObject("PrdMntProgramView");
    }

    /**
     * Container's getter for LtcpLtcT1.
     * @return LtcpLtcT1
     */
    public ViewLinkImpl getLtcpLtcT1() {
        return (ViewLinkImpl) findViewLink("LtcpLtcT1");
    }

    /**
     * Container's getter for LtcProcessProjects.
     * @return LtcProcessProjects
     */
    public ViewLinkImpl getLtcProcessProjects() {
        return (ViewLinkImpl) findViewLink("LtcProcessProjects");
    }


    public void initLtcExcelForm(String tagId, String processId, String programId, String projectId) {

        LtcTagViewRow ltcTagRow = getLtcTagView().getRowById(tagId);
        ModelUtils.setAttributeBindingValue("StartYear", ltcTagRow.getStartYear());
        ModelUtils.setAttributeBindingValue("FcNumber", ltcTagRow.getForecastNumber());
        ModelUtils.setAttributeBindingValue("NumberOfProfitYears", ltcTagRow.getNumberOfProfitYears());
    }

    public String getCurrentLtcTagId() {
        try {
            if (getLtcTagView().getCurrentRow() != null) {
                BigDecimal ltcTagId = ((LtcTagViewRow) getLtcTagView().getCurrentRow()).getId();
                if (ltcTagId != null) {
                    return ltcTagId.toString();
                }
            } else {
                return null;
            }
        } catch (NullPointerException e) {
            System.out.print("Caught the NullPointerException");
        }
        return null;
    }


    /**
     * Container's getter for LtcProcessView1.
     * @return LtcProcessView1
     */
    public LtcProcessViewImpl getParentTagProcessView() {
        return (LtcProcessViewImpl) findViewObject("ParentTagProcessView");
    }

    /**
     * Container's getter for LtcProjectView1.
     * @return LtcProjectView1
     */
    public LtcProjectViewImpl getParentTagProjectView() {
        return (LtcProjectViewImpl) findViewObject("ParentTagProjectView");
    }

    /**
     * Container's getter for LtcProcessProjects1.
     * @return LtcProcessProjects1
     */
    public ViewLinkImpl getParentTagProcessProjects() {
        return (ViewLinkImpl) findViewLink("ParentTagProcessProjects");
    }

    public String getParentId() {
        try {
            if (getLtcTagView().getCurrentRow() != null) {
                BigDecimal parentId = ((LtcTagViewRow) getLtcTagView().getCurrentRow()).getParentId();
                if (parentId != null) {
                    return parentId.toString();
                } else return "-1";
            } else {
                return null;
            }
        } catch (NullPointerException e) {
            System.out.print("Caught the NullPointerException");
        }
        return null;
    }

    public void refreshPreviousLtcTagProcesses() {

        getParentTagProcessView().executeQuery();

    }

    /**
     * Container's getter for LtcEstimateReadonly1.
     * @return LtcEstimateReadonly1
     */
    public IPMSViewObjectImpl getLtcEstimateDiscrepanciesView() {
        return (IPMSViewObjectImpl) findViewObject("LtcEstimateDiscrepanciesView");
    }

    /**
     * Container's getter for LtcEstimateReadonly2.
     * @return LtcEstimateReadonly2
     */
    public IPMSViewObjectImpl getLtcEstimateReadonlyView() {
        return (IPMSViewObjectImpl) findViewObject("LtcEstimateReadonlyView");
    }


    /**
     * Container's getter for LtcAvailableProjects1.
     * @return LtcAvailableProjects1
     */
    public IPMSViewObjectImpl getLtcAvailableProjectsView() {
        return (IPMSViewObjectImpl) findViewObject("LtcAvailableProjectsView");
    }

    public void prefill(String tagId, String processId, String programId, String projectId) {
        runStatement("begin ltc_sheet_pkg.prefill_all(?,?,?,?); end;", true, tagId, processId, programId, projectId);
    }
    
    public void commitLtc(){
        
        ModelUtils.setBaCode("EstimatesProvideLTC");
        
        getDBTransaction().commit();
        
        ModelUtils.setBaCode(null);
    }
    
    public void commitFte(){
        
        ModelUtils.setBaCode("EstimatesProvideFTE");
        
        getDBTransaction().commit();
        
        ModelUtils.setBaCode(null);
    }

    /**
     * Container's getter for LTCProcessView1.
     * @return LTCProcessView1
     */
    public IPMSViewObjectImpl getLTCProcessLookUp() {
        return (IPMSViewObjectImpl) findViewObject("LTCProcessLookUp");
    }
}

