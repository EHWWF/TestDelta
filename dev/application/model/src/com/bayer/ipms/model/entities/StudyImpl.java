package com.bayer.ipms.model.entities;

import com.bayer.ipms.model.base.IPMSEntityImpl;

import oracle.jbo.Key;
import oracle.jbo.domain.Date;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.server.EntityDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed Apr 09 09:47:32 EEST 2014
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class StudyImpl extends IPMSEntityImpl {


    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    public enum AttributesEnum {
        Id,
        ProjectId,
        TimelineId,
        WbsId,
        Code,
        Name,
        StatusCode,
        StartDate,
        FinishDate,
        Fpfv,
        Lplv,
        Phase,
        TimelineTypeCode,
        Placeholder,
        IsObligation,
        IsProbing,
        IsGpdcApproved,
        WbsCount,
        DmcActual,
        DmcPlan,
        PlanPatients,
        ActualPatients,
        TherapeuticGroupCode,
        TherapeuticGroupDesc,
        IntExtFlag,
        IsTimelineAutoImport,
        ActEnteredScreen,
        PlanEnteredScreen,
        StudyCountryCount,
        StudyCountryCountPlan,
        StudyUnitCount,
        StudyUnitCountPlan,
        StudyModusName,
        Csrapp,
        Prcompl,
        Cdblock,
        IsDelete,
        BudgetClass,
        Fpfvb,
        Lplva;
        private static AttributesEnum[] vals = null;
        private static final int firstIndex = 0;

        public int index() {
            return AttributesEnum.firstIndex() + ordinal();
        }

        public static final int firstIndex() {
            return firstIndex;
        }

        public static int count() {
            return AttributesEnum.firstIndex() + AttributesEnum.staticValues().length;
        }

        public static final AttributesEnum[] staticValues() {
            if (vals == null) {
                vals = AttributesEnum.values();
            }
            return vals;
        }
    }


    public static final int ID = AttributesEnum.Id.index();
    public static final int PROJECTID = AttributesEnum.ProjectId.index();
    public static final int TIMELINEID = AttributesEnum.TimelineId.index();
    public static final int WBSID = AttributesEnum.WbsId.index();
    public static final int CODE = AttributesEnum.Code.index();
    public static final int NAME = AttributesEnum.Name.index();
    public static final int STATUSCODE = AttributesEnum.StatusCode.index();
    public static final int STARTDATE = AttributesEnum.StartDate.index();
    public static final int FINISHDATE = AttributesEnum.FinishDate.index();
    public static final int FPFV = AttributesEnum.Fpfv.index();
    public static final int LPLV = AttributesEnum.Lplv.index();
    public static final int PHASE = AttributesEnum.Phase.index();
    public static final int TIMELINETYPECODE = AttributesEnum.TimelineTypeCode.index();
    public static final int PLACEHOLDER = AttributesEnum.Placeholder.index();
    public static final int ISOBLIGATION = AttributesEnum.IsObligation.index();
    public static final int ISPROBING = AttributesEnum.IsProbing.index();
    public static final int ISGPDCAPPROVED = AttributesEnum.IsGpdcApproved.index();
    public static final int WBSCOUNT = AttributesEnum.WbsCount.index();
    public static final int DMCACTUAL = AttributesEnum.DmcActual.index();
    public static final int DMCPLAN = AttributesEnum.DmcPlan.index();
    public static final int PLANPATIENTS = AttributesEnum.PlanPatients.index();
    public static final int ACTUALPATIENTS = AttributesEnum.ActualPatients.index();
    public static final int THERAPEUTICGROUPCODE = AttributesEnum.TherapeuticGroupCode.index();
    public static final int THERAPEUTICGROUPDESC = AttributesEnum.TherapeuticGroupDesc.index();
    public static final int INTEXTFLAG = AttributesEnum.IntExtFlag.index();
    public static final int ISTIMELINEAUTOIMPORT = AttributesEnum.IsTimelineAutoImport.index();
    public static final int ACTENTEREDSCREEN = AttributesEnum.ActEnteredScreen.index();
    public static final int PLANENTEREDSCREEN = AttributesEnum.PlanEnteredScreen.index();
    public static final int STUDYCOUNTRYCOUNT = AttributesEnum.StudyCountryCount.index();
    public static final int STUDYCOUNTRYCOUNTPLAN = AttributesEnum.StudyCountryCountPlan.index();
    public static final int STUDYUNITCOUNT = AttributesEnum.StudyUnitCount.index();
    public static final int STUDYUNITCOUNTPLAN = AttributesEnum.StudyUnitCountPlan.index();
    public static final int STUDYMODUSNAME = AttributesEnum.StudyModusName.index();
    public static final int CSRAPP = AttributesEnum.Csrapp.index();
    public static final int PRCOMPL = AttributesEnum.Prcompl.index();
    public static final int CDBLOCK = AttributesEnum.Cdblock.index();
    public static final int ISDELETE = AttributesEnum.IsDelete.index();
    public static final int BUDGETCLASS = AttributesEnum.BudgetClass.index();
    public static final int FPFVB = AttributesEnum.Fpfvb.index();
    public static final int LPLVA = AttributesEnum.Lplva.index();

    /**
     * This is the default constructor (do not remove).
     */
    public StudyImpl() {
    }

    /**
     * @param id key constituent
     * @param projectId key constituent
     * @param wbsId key constituent

     * @return a Key object based on given key constituents.
     */
    public static Key createPrimaryKey(String id, String projectId, String wbsId) {
        return new Key(new Object[] { id, projectId, wbsId });
    }

    /**
     * @return the definition object for this instance class.
     */
    public static synchronized EntityDefImpl getDefinitionObject() {
        return EntityDefImpl.findDefObject("com.bayer.ipms.model.entities.Study");
    }


    @Override
    public void lock() {
        // do not lock row in DB
    }
}
