package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSEntityImpl;

import com.bayer.ipms.model.views.common.CostsProbabilityDefaultViewRow;

import com.bayer.ipms.model.views.common.CostsProbabilitySpecificViewRow;

import oracle.jbo.RowSet;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.server.ViewDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue Sep 23 18:40:34 EEST 2014
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CostsProbabilitySpecificViewRowImpl extends CostsProbabilityViewRowImpl implements CostsProbabilitySpecificViewRow {
    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    public enum AttributesEnum {
        PhaseCode {
            public Object get(CostsProbabilitySpecificViewRowImpl obj) {
                return obj.getPhaseCode();
            }

            public void put(CostsProbabilitySpecificViewRowImpl obj,
                            Object value) {
                obj.setPhaseCode((String)value);
            }
        }
        ,
        SbeCode {
            public Object get(CostsProbabilitySpecificViewRowImpl obj) {
                return obj.getSbeCode();
            }

            public void put(CostsProbabilitySpecificViewRowImpl obj,
                            Object value) {
                obj.setSbeCode((String)value);
            }
        }
        ,
        SubstanceTypeCode {
            public Object get(CostsProbabilitySpecificViewRowImpl obj) {
                return obj.getSubstanceTypeCode();
            }

            public void put(CostsProbabilitySpecificViewRowImpl obj,
                            Object value) {
                obj.setSubstanceTypeCode((String)value);
            }
        }
        ,
        _PhaseCode {
            public Object get(CostsProbabilitySpecificViewRowImpl obj) {
                return obj.get_PhaseCode();
            }

            public void put(CostsProbabilitySpecificViewRowImpl obj,
                            Object value) {
                obj.set_PhaseCode((String)value);
            }
        }
        ,
        PhaseName {
            public Object get(CostsProbabilitySpecificViewRowImpl obj) {
                return obj.getPhaseName();
            }

            public void put(CostsProbabilitySpecificViewRowImpl obj,
                            Object value) {
                obj.setPhaseName((String)value);
            }
        }
        ,
        _SbeCode {
            public Object get(CostsProbabilitySpecificViewRowImpl obj) {
                return obj.get_SbeCode();
            }

            public void put(CostsProbabilitySpecificViewRowImpl obj,
                            Object value) {
                obj.set_SbeCode((String)value);
            }
        }
        ,
        SbeName {
            public Object get(CostsProbabilitySpecificViewRowImpl obj) {
                return obj.getSbeName();
            }

            public void put(CostsProbabilitySpecificViewRowImpl obj,
                            Object value) {
                obj.setSbeName((String)value);
            }
        }
        ,
        _SubstanceTypeCode {
            public Object get(CostsProbabilitySpecificViewRowImpl obj) {
                return obj.get_SubstanceTypeCode();
            }

            public void put(CostsProbabilitySpecificViewRowImpl obj,
                            Object value) {
                obj.set_SubstanceTypeCode((String)value);
            }
        }
        ,
        Name {
            public Object get(CostsProbabilitySpecificViewRowImpl obj) {
                return obj.getName();
            }

            public void put(CostsProbabilitySpecificViewRowImpl obj,
                            Object value) {
                obj.setName((String)value);
            }
        }
        ,
        ProjectId {
            public Object get(CostsProbabilitySpecificViewRowImpl obj) {
                return obj.getProjectId();
            }

            public void put(CostsProbabilitySpecificViewRowImpl obj,
                            Object value) {
                obj.setProjectId((String)value);
            }
        }
        ,
        CostsProbabilityPhaseView {
            public Object get(CostsProbabilitySpecificViewRowImpl obj) {
                return obj.getCostsProbabilityPhaseView();
            }

            public void put(CostsProbabilitySpecificViewRowImpl obj,
                            Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        CostsProbabilitySbeView {
            public Object get(CostsProbabilitySpecificViewRowImpl obj) {
                return obj.getCostsProbabilitySbeView();
            }

            public void put(CostsProbabilitySpecificViewRowImpl obj,
                            Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        CostsProbabilitySubstanceTypeView {
            public Object get(CostsProbabilitySpecificViewRowImpl obj) {
                return obj.getCostsProbabilitySubstanceTypeView();
            }

            public void put(CostsProbabilitySpecificViewRowImpl obj,
                            Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        CostsProbabilityPTRPhaseView {
            public Object get(CostsProbabilitySpecificViewRowImpl obj) {
                return obj.getCostsProbabilityPTRPhaseView();
            }

            public void put(CostsProbabilitySpecificViewRowImpl obj,
                            Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ;
        private static AttributesEnum[] vals = null;
        private static final int firstIndex = ViewDefImpl.getMaxAttrConst("com.bayer.ipms.model.views.CostsProbabilityView");

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

        public abstract Object get(CostsProbabilitySpecificViewRowImpl object);

        public abstract void put(CostsProbabilitySpecificViewRowImpl object,
                                 Object value);
    }


    public static final int PHASECODE = AttributesEnum.PhaseCode.index();
    public static final int SBECODE = AttributesEnum.SbeCode.index();
    public static final int SUBSTANCETYPECODE = AttributesEnum.SubstanceTypeCode.index();
    public static final int _PHASECODE = AttributesEnum._PhaseCode.index();
    public static final int PHASENAME = AttributesEnum.PhaseName.index();
    public static final int _SBECODE = AttributesEnum._SbeCode.index();
    public static final int SBENAME = AttributesEnum.SbeName.index();
    public static final int _SUBSTANCETYPECODE = AttributesEnum._SubstanceTypeCode.index();
    public static final int NAME = AttributesEnum.Name.index();
    public static final int PROJECTID = AttributesEnum.ProjectId.index();
    public static final int COSTSPROBABILITYPHASEVIEW = AttributesEnum.CostsProbabilityPhaseView.index();
    public static final int COSTSPROBABILITYSBEVIEW = AttributesEnum.CostsProbabilitySbeView.index();
    public static final int COSTSPROBABILITYSUBSTANCETYPEVIEW = AttributesEnum.CostsProbabilitySubstanceTypeView.index();
    public static final int COSTSPROBABILITYPTRPHASEVIEW = AttributesEnum.CostsProbabilityPTRPhaseView.index();

    /**
     * This is the default constructor (do not remove).
     */
    public CostsProbabilitySpecificViewRowImpl() {
    }

    /**
     * Gets CostsProbability entity object.
     * @return the CostsProbability
     */
    public IPMSEntityImpl getCostsProbability() {
        return (IPMSEntityImpl)getEntity(0);
    }

    /**
     * Gets Phase entity object.
     * @return the Phase
     */
    public IPMSEntityImpl getPhase() {
        return (IPMSEntityImpl)getEntity(1);
    }

    /**
     * Gets StrategicBusinessEntity entity object.
     * @return the StrategicBusinessEntity
     */
    public IPMSEntityImpl getStrategicBusinessEntity() {
        return (IPMSEntityImpl)getEntity(2);
    }

    /**
     * Gets SubstanceType entity object.
     * @return the SubstanceType
     */
    public IPMSEntityImpl getSubstanceType() {
        return (IPMSEntityImpl)getEntity(3);
    }

    /**
     * Gets the attribute value for SCOPE_CODE using the alias name ScopeCode.
     * @return the SCOPE_CODE
     */
    public String getScopeCode() {
        return super.getScopeCode();
    }

    /**
     * Sets <code>value</code> as attribute value for SCOPE_CODE using the alias name ScopeCode.
     * @param value value to set the SCOPE_CODE
     */
    public void setScopeCode(String value) {
        super.setScopeCode(value);
    }

    /**
     * Gets the attribute value for PHASE_CODE using the alias name PhaseCode.
     * @return the PHASE_CODE
     */
    public String getPhaseCode() {
        return (String) getAttributeInternal(PHASECODE);
    }

    /**
     * Sets <code>value</code> as attribute value for PHASE_CODE using the alias name PhaseCode.
     * @param value value to set the PHASE_CODE
     */
    public void setPhaseCode(String value) {
        setAttributeInternal(PHASECODE, value);
    }

    /**
     * Gets the attribute value for SBE_CODE using the alias name SbeCode.
     * @return the SBE_CODE
     */
    public String getSbeCode() {
        return (String) getAttributeInternal(SBECODE);
    }

    /**
     * Sets <code>value</code> as attribute value for SBE_CODE using the alias name SbeCode.
     * @param value value to set the SBE_CODE
     */
    public void setSbeCode(String value) {
        setAttributeInternal(SBECODE, value);
    }

    /**
     * Gets the attribute value for SUBSTANCE_TYPE_CODE using the alias name SubstanceTypeCode.
     * @return the SUBSTANCE_TYPE_CODE
     */
    public String getSubstanceTypeCode() {
        return (String) getAttributeInternal(SUBSTANCETYPECODE);
    }

    /**
     * Sets <code>value</code> as attribute value for SUBSTANCE_TYPE_CODE using the alias name SubstanceTypeCode.
     * @param value value to set the SUBSTANCE_TYPE_CODE
     */
    public void setSubstanceTypeCode(String value) {
        setAttributeInternal(SUBSTANCETYPECODE, value);
    }

    /**
     * Gets the attribute value for CODE using the alias name _PhaseCode.
     * @return the CODE
     */
    public String get_PhaseCode() {
        return (String) getAttributeInternal(_PHASECODE);
    }

    /**
     * Sets <code>value</code> as attribute value for CODE using the alias name _PhaseCode.
     * @param value value to set the CODE
     */
    public void set_PhaseCode(String value) {
        setAttributeInternal(_PHASECODE, value);
    }

    /**
     * Gets the attribute value for NAME using the alias name PhaseName.
     * @return the NAME
     */
    public String getPhaseName() {
        return (String) getAttributeInternal(PHASENAME);
    }

    /**
     * Sets <code>value</code> as attribute value for NAME using the alias name PhaseName.
     * @param value value to set the NAME
     */
    public void setPhaseName(String value) {
        setAttributeInternal(PHASENAME, value);
    }

    /**
     * Gets the attribute value for CODE using the alias name _SbeCode.
     * @return the CODE
     */
    public String get_SbeCode() {
        return (String) getAttributeInternal(_SBECODE);
    }

    /**
     * Sets <code>value</code> as attribute value for CODE using the alias name _SbeCode.
     * @param value value to set the CODE
     */
    public void set_SbeCode(String value) {
        setAttributeInternal(_SBECODE, value);
    }

    /**
     * Gets the attribute value for NAME using the alias name SbeName.
     * @return the NAME
     */
    public String getSbeName() {
        return (String) getAttributeInternal(SBENAME);
    }

    /**
     * Sets <code>value</code> as attribute value for NAME using the alias name SbeName.
     * @param value value to set the NAME
     */
    public void setSbeName(String value) {
        setAttributeInternal(SBENAME, value);
    }

    /**
     * Gets the attribute value for CODE using the alias name _SubstanceTypeCode.
     * @return the CODE
     */
    public String get_SubstanceTypeCode() {
        return (String) getAttributeInternal(_SUBSTANCETYPECODE);
    }

    /**
     * Sets <code>value</code> as attribute value for CODE using the alias name _SubstanceTypeCode.
     * @param value value to set the CODE
     */
    public void set_SubstanceTypeCode(String value) {
        setAttributeInternal(_SUBSTANCETYPECODE, value);
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
     * Gets the attribute value for PROJECT_ID using the alias name ProjectId.
     * @return the PROJECT_ID
     */
    public String getProjectId() {
        return (String) getAttributeInternal(PROJECTID);
    }

    /**
     * Sets <code>value</code> as attribute value for PROJECT_ID using the alias name ProjectId.
     * @param value value to set the PROJECT_ID
     */
    public void setProjectId(String value) {
        setAttributeInternal(PROJECTID, value);
    }


    /**
     * Gets the view accessor <code>RowSet</code> CostsProbabilityPhaseView.
     */
    public RowSet getCostsProbabilityPhaseView() {
        return (RowSet)getAttributeInternal(COSTSPROBABILITYPHASEVIEW);
    }

    /**
     * Gets the view accessor <code>RowSet</code> CostsProbabilitySbeView.
     */
    public RowSet getCostsProbabilitySbeView() {
        return (RowSet)getAttributeInternal(COSTSPROBABILITYSBEVIEW);
    }

    /**
     * Gets the view accessor <code>RowSet</code> CostsProbabilitySubstanceTypeView.
     */
    public RowSet getCostsProbabilitySubstanceTypeView() {
        return (RowSet)getAttributeInternal(COSTSPROBABILITYSUBSTANCETYPEVIEW);
    }

    /**
     * Gets the view accessor <code>RowSet</code> CostsProbabilityPTRPhaseView.
     */
    public RowSet getCostsProbabilityPTRPhaseView() {
        return (RowSet)getAttributeInternal(COSTSPROBABILITYPTRPHASEVIEW);
    }

    /**
     * getAttrInvokeAccessor: generated method. Do not modify.
     * @param index the index identifying the attribute
     * @param attrDef the attribute

     * @return the attribute value
     * @throws Exception
     */
    protected Object getAttrInvokeAccessor(int index,
                                           AttributeDefImpl attrDef) throws Exception {
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
    protected void setAttrInvokeAccessor(int index, Object value,
                                         AttributeDefImpl attrDef) throws Exception {
        if ((index >= AttributesEnum.firstIndex()) && (index < AttributesEnum.count())) {
            AttributesEnum.staticValues()[index - AttributesEnum.firstIndex()].put(this, value);
            return;
        }
        super.setAttrInvokeAccessor(index, value, attrDef);
    }

}
