package com.bayer.ipms.model.views.lookups;

import com.bayer.ipms.model.base.IPMSViewRowImpl;
import com.bayer.ipms.model.entities.lookups.ProjectTerminationReasonImpl;

import com.bayer.ipms.model.views.lookups.common.ProjectTerminationReasonsViewRow;

import oracle.jbo.RowSet;
import oracle.jbo.server.AttributeDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Thu Aug 13 09:36:50 EEST 2015
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ProjectTerminationReasonsViewRowImpl extends IPMSViewRowImpl implements ProjectTerminationReasonsViewRow {

    public static final int ENTITY_PROJECTTERMINATIONREASON = 0;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    public enum AttributesEnum {
        Code {
            public Object get(ProjectTerminationReasonsViewRowImpl obj) {
                return obj.getCode();
            }

            public void put(ProjectTerminationReasonsViewRowImpl obj, Object value) {
                obj.setCode((String) value);
            }
        }
        ,
        Name {
            public Object get(ProjectTerminationReasonsViewRowImpl obj) {
                return obj.getName();
            }

            public void put(ProjectTerminationReasonsViewRowImpl obj, Object value) {
                obj.setName((String) value);
            }
        }
        ,
        IsActive {
            public Object get(ProjectTerminationReasonsViewRowImpl obj) {
                return obj.getIsActive();
            }

            public void put(ProjectTerminationReasonsViewRowImpl obj, Object value) {
                obj.setIsActive((Boolean) value);
            }
        }
        ,
        Description {
            public Object get(ProjectTerminationReasonsViewRowImpl obj) {
                return obj.getDescription();
            }

            public void put(ProjectTerminationReasonsViewRowImpl obj, Object value) {
                obj.setDescription((String) value);
            }
        }
        ,
        RefReasonCode {
            public Object get(ProjectTerminationReasonsViewRowImpl obj) {
                return obj.getRefReasonCode();
            }

            public void put(ProjectTerminationReasonsViewRowImpl obj, Object value) {
                obj.setRefReasonCode((String) value);
            }
        }
        ,
        D1 {
            public Object get(ProjectTerminationReasonsViewRowImpl obj) {
                return obj.getD1();
            }

            public void put(ProjectTerminationReasonsViewRowImpl obj, Object value) {
                obj.setD1((Boolean) value);
            }
        }
        ,
        D2 {
            public Object get(ProjectTerminationReasonsViewRowImpl obj) {
                return obj.getD2();
            }

            public void put(ProjectTerminationReasonsViewRowImpl obj, Object value) {
                obj.setD2((Boolean) value);
            }
        }
        ,
        Dev {
            public Object get(ProjectTerminationReasonsViewRowImpl obj) {
                return obj.getDev();
            }

            public void put(ProjectTerminationReasonsViewRowImpl obj, Object value) {
                obj.setDev((Boolean) value);
            }
        }
        ,
        PrdMnt {
            public Object get(ProjectTerminationReasonsViewRowImpl obj) {
                return obj.getPrdMnt();
            }

            public void put(ProjectTerminationReasonsViewRowImpl obj, Object value) {
                obj.setPrdMnt((Boolean) value);
            }
        }
        ,
        ManagementAppModule_TerminationReasonNoRefView {
            public Object get(ProjectTerminationReasonsViewRowImpl obj) {
                return obj.getManagementAppModule_TerminationReasonNoRefView();
            }

            public void put(ProjectTerminationReasonsViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        LOV_TerminationReasonNoRefView {
            public Object get(ProjectTerminationReasonsViewRowImpl obj) {
                return obj.getLOV_TerminationReasonNoRefView();
            }

            public void put(ProjectTerminationReasonsViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ;
        static AttributesEnum[] vals = null;
        ;
        private static final int firstIndex = 0;

        public abstract Object get(ProjectTerminationReasonsViewRowImpl object);

        public abstract void put(ProjectTerminationReasonsViewRowImpl object, Object value);

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

    public static final int CODE = AttributesEnum.Code.index();
    public static final int NAME = AttributesEnum.Name.index();
    public static final int ISACTIVE = AttributesEnum.IsActive.index();
    public static final int DESCRIPTION = AttributesEnum.Description.index();
    public static final int REFREASONCODE = AttributesEnum.RefReasonCode.index();
    public static final int D1 = AttributesEnum.D1.index();
    public static final int D2 = AttributesEnum.D2.index();
    public static final int DEV = AttributesEnum.Dev.index();
    public static final int PRDMNT = AttributesEnum.PrdMnt.index();
    public static final int MANAGEMENTAPPMODULE_TERMINATIONREASONNOREFVIEW =
        AttributesEnum.ManagementAppModule_TerminationReasonNoRefView.index();
    public static final int LOV_TERMINATIONREASONNOREFVIEW = AttributesEnum.LOV_TerminationReasonNoRefView.index();

    /**
     * This is the default constructor (do not remove).
     */
    public ProjectTerminationReasonsViewRowImpl() {
    }

    /**
     * Gets ProjectTerminationReason entity object.
     * @return the ProjectTerminationReason
     */
    public ProjectTerminationReasonImpl getProjectTerminationReason() {
        return (ProjectTerminationReasonImpl) getEntity(ENTITY_PROJECTTERMINATIONREASON);
    }

    /**
     * Gets the attribute value for CODE using the alias name Code.
     * @return the CODE
     */
    public String getCode() {
        return (String) getAttributeInternal(CODE);
    }

    /**
     * Sets <code>value</code> as attribute value for CODE using the alias name Code.
     * @param value value to set the CODE
     */
    public void setCode(String value) {
        setAttributeInternal(CODE, value);
    }

    /**
     * Gets the attribute value for NAME using the alias name Name.
     * @return the NAME
     */
    public String getName() {
        return (String) getAttributeInternal(NAME);
    }

    /**
     * Sets <code>value</code> as attribute value for NAME using the alias name Name.
     * @param value value to set the NAME
     */
    public void setName(String value) {
        setAttributeInternal(NAME, value);
    }

    /**
     * Gets the attribute value for IS_ACTIVE using the alias name IsActive.
     * @return the IS_ACTIVE
     */
    public Boolean getIsActive() {
        return (Boolean) getAttributeInternal(ISACTIVE);
    }

    /**
     * Sets <code>value</code> as attribute value for IS_ACTIVE using the alias name IsActive.
     * @param value value to set the IS_ACTIVE
     */
    public void setIsActive(Boolean value) {
        setAttributeInternal(ISACTIVE, value);
    }

    /**
     * Gets the attribute value for DESCRIPTION using the alias name Description.
     * @return the DESCRIPTION
     */
    public String getDescription() {
        return (String) getAttributeInternal(DESCRIPTION);
    }

    /**
     * Sets <code>value</code> as attribute value for DESCRIPTION using the alias name Description.
     * @param value value to set the DESCRIPTION
     */
    public void setDescription(String value) {
        setAttributeInternal(DESCRIPTION, value);
    }

    /**
     * Gets the attribute value for REF_REASON_CODE using the alias name RefReasonCode.
     * @return the REF_REASON_CODE
     */
    public String getRefReasonCode() {
        return (String) getAttributeInternal(REFREASONCODE);
    }

    /**
     * Sets <code>value</code> as attribute value for REF_REASON_CODE using the alias name RefReasonCode.
     * @param value value to set the REF_REASON_CODE
     */
    public void setRefReasonCode(String value) {
        setAttributeInternal(REFREASONCODE, value);
    }

    /**
     * Gets the attribute value for D1 using the alias name D1.
     * @return the D1
     */
    public Boolean getD1() {
        return (Boolean) getAttributeInternal(D1);
    }

    /**
     * Sets <code>value</code> as attribute value for D1 using the alias name D1.
     * @param value value to set the D1
     */
    public void setD1(Boolean value) {
        setAttributeInternal(D1, value);
    }

    /**
     * Gets the attribute value for D2 using the alias name D2.
     * @return the D2
     */
    public Boolean getD2() {
        return (Boolean) getAttributeInternal(D2);
    }

    /**
     * Sets <code>value</code> as attribute value for D2 using the alias name D2.
     * @param value value to set the D2
     */
    public void setD2(Boolean value) {
        setAttributeInternal(D2, value);
    }

    /**
     * Gets the attribute value for DEV using the alias name Dev.
     * @return the DEV
     */
    public Boolean getDev() {
        return (Boolean) getAttributeInternal(DEV);
    }

    /**
     * Sets <code>value</code> as attribute value for DEV using the alias name Dev.
     * @param value value to set the DEV
     */
    public void setDev(Boolean value) {
        setAttributeInternal(DEV, value);
    }

    /**
     * Gets the attribute value for PRD_MNT using the alias name PrdMnt.
     * @return the PRD_MNT
     */
    public Boolean getPrdMnt() {
        return (Boolean) getAttributeInternal(PRDMNT);
    }

    /**
     * Sets <code>value</code> as attribute value for PRD_MNT using the alias name PrdMnt.
     * @param value value to set the PRD_MNT
     */
    public void setPrdMnt(Boolean value) {
        setAttributeInternal(PRDMNT, value);
    }

    /**
     * Gets the view accessor <code>RowSet</code> ManagementAppModule_TerminationReasonNoRefView.
     */
    public RowSet getManagementAppModule_TerminationReasonNoRefView() {
        return (RowSet) getAttributeInternal(MANAGEMENTAPPMODULE_TERMINATIONREASONNOREFVIEW);
    }

    /**
     * Gets the view accessor <code>RowSet</code> LOV_TerminationReasonNoRefView.
     */
    public RowSet getLOV_TerminationReasonNoRefView() {
        return (RowSet) getAttributeInternal(LOV_TERMINATIONREASONNOREFVIEW);
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
}

