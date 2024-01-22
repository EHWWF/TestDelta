package com.bayer.ipms.model.views.lookups;

import com.bayer.ipms.model.base.IPMSEntityImpl;
import com.bayer.ipms.model.base.IPMSViewRowImpl;

import com.bayer.ipms.model.entities.lookups.ProjectGoalFactorImpl;
import com.bayer.ipms.model.views.lookups.common.ProjectGoalFactorViewRow;

import java.math.BigDecimal;

import oracle.jbo.RowSet;
import oracle.jbo.server.AttributeDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed Sep 16 10:56:43 EEST 2015
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ProjectGoalFactorViewRowImpl extends IPMSViewRowImpl implements ProjectGoalFactorViewRow {


    public static final int ENTITY_PROJECTGOALFACTOR = 0;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    public enum AttributesEnum {
        Id {
            public Object get(ProjectGoalFactorViewRowImpl obj) {
                return obj.getId();
            }

            public void put(ProjectGoalFactorViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        AreaCode {
            public Object get(ProjectGoalFactorViewRowImpl obj) {
                return obj.getAreaCode();
            }

            public void put(ProjectGoalFactorViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        ProjectCode {
            public Object get(ProjectGoalFactorViewRowImpl obj) {
                return obj.getProjectCode();
            }

            public void put(ProjectGoalFactorViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        ProjectName {
            public Object get(ProjectGoalFactorViewRowImpl obj) {
                return obj.getProjectName();
            }

            public void put(ProjectGoalFactorViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        MilestoneType {
            public Object get(ProjectGoalFactorViewRowImpl obj) {
                return obj.getMilestoneType();
            }

            public void put(ProjectGoalFactorViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        Factor {
            public Object get(ProjectGoalFactorViewRowImpl obj) {
                return obj.getFactor();
            }

            public void put(ProjectGoalFactorViewRowImpl obj, Object value) {
                obj.setFactor((BigDecimal) value);
            }
        }
        ,
        ProjectId {
            public Object get(ProjectGoalFactorViewRowImpl obj) {
                return obj.getProjectId();
            }

            public void put(ProjectGoalFactorViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        SrchException {
            public Object get(ProjectGoalFactorViewRowImpl obj) {
                return obj.getSrchException();
            }

            public void put(ProjectGoalFactorViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        Factorflag {
            public Object get(ProjectGoalFactorViewRowImpl obj) {
                return obj.getFactorflag();
            }

            public void put(ProjectGoalFactorViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        ProjectAreaView {
            public Object get(ProjectGoalFactorViewRowImpl obj) {
                return obj.getProjectAreaView();
            }

            public void put(ProjectGoalFactorViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ;
        static AttributesEnum[] vals = null;
        ;
        private static final int firstIndex = 0;

        public abstract Object get(ProjectGoalFactorViewRowImpl object);

        public abstract void put(ProjectGoalFactorViewRowImpl object, Object value);

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
    public static final int AREACODE = AttributesEnum.AreaCode.index();
    public static final int PROJECTCODE = AttributesEnum.ProjectCode.index();
    public static final int PROJECTNAME = AttributesEnum.ProjectName.index();
    public static final int MILESTONETYPE = AttributesEnum.MilestoneType.index();
    public static final int FACTOR = AttributesEnum.Factor.index();
    public static final int PROJECTID = AttributesEnum.ProjectId.index();
    public static final int SRCHEXCEPTION = AttributesEnum.SrchException.index();
    public static final int FACTORFLAG = AttributesEnum.Factorflag.index();
    public static final int PROJECTAREAVIEW = AttributesEnum.ProjectAreaView.index();

    /**
     * This is the default constructor (do not remove).
     */
    public ProjectGoalFactorViewRowImpl() {
    }

    /**
     * Gets ProjectGoalFactor entity object.
     * @return the ProjectGoalFactor
     */
    public ProjectGoalFactorImpl getProjectGoalFactor() {
        return (ProjectGoalFactorImpl) getEntity(ENTITY_PROJECTGOALFACTOR);
    }

    /**
     * Gets the attribute value for ID using the alias name Id.
     * @return the ID
     */
    public String getId() {
        return (String) getAttributeInternal(ID);
    }

    /**
     * Gets the attribute value for AREA_CODE using the alias name AreaCode.
     * @return the AREA_CODE
     */
    public String getAreaCode() {
        return (String) getAttributeInternal(AREACODE);
    }

    /**
     * Gets the attribute value for PROJECT_CODE using the alias name ProjectCode.
     * @return the PROJECT_CODE
     */
    public String getProjectCode() {
        return (String) getAttributeInternal(PROJECTCODE);
    }

    /**
     * Gets the attribute value for PROJECT_NAME using the alias name ProjectName.
     * @return the PROJECT_NAME
     */
    public String getProjectName() {
        return (String) getAttributeInternal(PROJECTNAME);
    }

    /**
     * Gets the attribute value for MILESTONE_TYPE using the alias name MilestoneType.
     * @return the MILESTONE_TYPE
     */
    public String getMilestoneType() {
        return (String) getAttributeInternal(MILESTONETYPE);
    }


    /**
     * Gets the attribute value for FACTOR using the alias name Factor.
     * @return the FACTOR
     */
    public BigDecimal getFactor() {
        return (BigDecimal) getAttributeInternal(FACTOR);
    }

    /**
     * Sets <code>value</code> as attribute value for FACTOR using the alias name Factor.
     * @param value value to set the FACTOR
     */
    public void setFactor(BigDecimal value) {
        setAttributeInternal(FACTOR, value);
    }

    /**
     * Gets the attribute value for PROJECT_ID using the alias name ProjectId.
     * @return the PROJECT_ID
     */
    public String getProjectId() {
        return (String) getAttributeInternal(PROJECTID);
    }


    /**
     * Gets the attribute value for SRCH_EXCEPTION using the alias name SrchException.
     * @return the SRCH_EXCEPTION
     */
    public Boolean getSrchException() {
        return (Boolean) getAttributeInternal(SRCHEXCEPTION);
    }


    /**
     * Gets the attribute value for FACTORFLAG using the alias name Factorflag.
     * @return the FACTORFLAG
     */
    public BigDecimal getFactorflag() {
        return (BigDecimal) getAttributeInternal(FACTORFLAG);
    }

    /**
     * Gets the view accessor <code>RowSet</code> ProjectAreaView.
     */
    public RowSet getProjectAreaView() {
        return (RowSet) getAttributeInternal(PROJECTAREAVIEW);
    }

    /**
     * getAttrInvokeAccessor: generated method. Do not modify.
     * @param index the index identifying the attribute
     * @param attrDef the attribute

     * @return the attribute value
     * @throws Exception
     */
    protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception {
        if ((index >= AttributesEnum.firstIndex()) && (index < AttributesEnum.count())) {
            return AttributesEnum.staticValues()[index - AttributesEnum.firstIndex()].get(this);
        }
        return super.getAttrInvokeAccessor(index, attrDef);
    }

    /**
     * setAttrInvokeAccessor: generated method. Do not modify.
     * @param index the index identifying the attribute
     * @param value the value to assign to the attribute
     * @param attrDef the attribute

     * @throws Exception
     */
    protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception {
        if ((index >= AttributesEnum.firstIndex()) && (index < AttributesEnum.count())) {
            AttributesEnum.staticValues()[index - AttributesEnum.firstIndex()].put(this, value);
            return;
        }
        super.setAttrInvokeAccessor(index, value, attrDef);
    }

    public void fillGoalFactors(String projectId, String milestoneCode, String factor) {
        runStatement("begin lookup_pkg.create_prj_goalFactor(?,?,?); end;", false, projectId, milestoneCode, factor);
    }
}

