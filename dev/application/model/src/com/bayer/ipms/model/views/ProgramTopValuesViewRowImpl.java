package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSEntityImpl;
import com.bayer.ipms.model.base.IPMSViewRowImpl;

import com.bayer.ipms.model.views.common.ProgramTopValuesViewRow;

import java.math.BigDecimal;

import oracle.jbo.Row;
import oracle.jbo.server.AttributeDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Thu Jun 06 12:05:55 EEST 2019
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ProgramTopValuesViewRowImpl extends IPMSViewRowImpl implements ProgramTopValuesViewRow {


    public static final int ENTITY_PROGRAMTOPVALUE = 0;
    public static final int ENTITY_PROGRAMTOPSUBCATEGORY = 1;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    public enum AttributesEnum {
        Id {
            public Object get(ProgramTopValuesViewRowImpl obj) {
                return obj.getId();
            }

            public void put(ProgramTopValuesViewRowImpl obj, Object value) {
                obj.setId((BigDecimal) value);
            }
        }
        ,
        Indication1 {
            public Object get(ProgramTopValuesViewRowImpl obj) {
                return obj.getIndication1();
            }

            public void put(ProgramTopValuesViewRowImpl obj, Object value) {
                obj.setIndication1((String) value);
            }
        }
        ,
        Indication2 {
            public Object get(ProgramTopValuesViewRowImpl obj) {
                return obj.getIndication2();
            }

            public void put(ProgramTopValuesViewRowImpl obj, Object value) {
                obj.setIndication2((String) value);
            }
        }
        ,
        Indication3 {
            public Object get(ProgramTopValuesViewRowImpl obj) {
                return obj.getIndication3();
            }

            public void put(ProgramTopValuesViewRowImpl obj, Object value) {
                obj.setIndication3((String) value);
            }
        }
        ,
        Indication4 {
            public Object get(ProgramTopValuesViewRowImpl obj) {
                return obj.getIndication4();
            }

            public void put(ProgramTopValuesViewRowImpl obj, Object value) {
                obj.setIndication4((String) value);
            }
        }
        ,
        Indication5 {
            public Object get(ProgramTopValuesViewRowImpl obj) {
                return obj.getIndication5();
            }

            public void put(ProgramTopValuesViewRowImpl obj, Object value) {
                obj.setIndication5((String) value);
            }
        }
        ,
        Indication6 {
            public Object get(ProgramTopValuesViewRowImpl obj) {
                return obj.getIndication6();
            }

            public void put(ProgramTopValuesViewRowImpl obj, Object value) {
                obj.setIndication6((String) value);
            }
        }
        ,
        Indication7 {
            public Object get(ProgramTopValuesViewRowImpl obj) {
                return obj.getIndication7();
            }

            public void put(ProgramTopValuesViewRowImpl obj, Object value) {
                obj.setIndication7((String) value);
            }
        }
        ,
        Indication8 {
            public Object get(ProgramTopValuesViewRowImpl obj) {
                return obj.getIndication8();
            }

            public void put(ProgramTopValuesViewRowImpl obj, Object value) {
                obj.setIndication8((String) value);
            }
        }
        ,
        ProgramVersionId {
            public Object get(ProgramTopValuesViewRowImpl obj) {
                return obj.getProgramVersionId();
            }

            public void put(ProgramTopValuesViewRowImpl obj, Object value) {
                obj.setProgramVersionId((BigDecimal) value);
            }
        }
        ,
        SubcategoryCode {
            public Object get(ProgramTopValuesViewRowImpl obj) {
                return obj.getSubcategoryCode();
            }

            public void put(ProgramTopValuesViewRowImpl obj, Object value) {
                obj.setSubcategoryCode((String) value);
            }
        }
        ,
        IsActive {
            public Object get(ProgramTopValuesViewRowImpl obj) {
                return obj.getIsActive();
            }

            public void put(ProgramTopValuesViewRowImpl obj, Object value) {
                obj.setIsActive((Boolean) value);
            }
        }
        ,
        Code {
            public Object get(ProgramTopValuesViewRowImpl obj) {
                return obj.getCode();
            }

            public void put(ProgramTopValuesViewRowImpl obj, Object value) {
                obj.setCode((String) value);
            }
        }
        ,
        ProgramTopSubCategoryView {
            public Object get(ProgramTopValuesViewRowImpl obj) {
                return obj.getProgramTopSubCategoryView();
            }

            public void put(ProgramTopValuesViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ;
        static AttributesEnum[] vals = null;
        ;
        private static final int firstIndex = 0;

        public abstract Object get(ProgramTopValuesViewRowImpl object);

        public abstract void put(ProgramTopValuesViewRowImpl object, Object value);

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
    public static final int INDICATION1 = AttributesEnum.Indication1.index();
    public static final int INDICATION2 = AttributesEnum.Indication2.index();
    public static final int INDICATION3 = AttributesEnum.Indication3.index();
    public static final int INDICATION4 = AttributesEnum.Indication4.index();
    public static final int INDICATION5 = AttributesEnum.Indication5.index();
    public static final int INDICATION6 = AttributesEnum.Indication6.index();
    public static final int INDICATION7 = AttributesEnum.Indication7.index();
    public static final int INDICATION8 = AttributesEnum.Indication8.index();
    public static final int PROGRAMVERSIONID = AttributesEnum.ProgramVersionId.index();
    public static final int SUBCATEGORYCODE = AttributesEnum.SubcategoryCode.index();
    public static final int ISACTIVE = AttributesEnum.IsActive.index();
    public static final int CODE = AttributesEnum.Code.index();
    public static final int PROGRAMTOPSUBCATEGORYVIEW = AttributesEnum.ProgramTopSubCategoryView.index();

    /**
     * This is the default constructor (do not remove).
     */
    public ProgramTopValuesViewRowImpl() {
    }

    /**
     * Gets ProgramTopValue entity object.
     * @return the ProgramTopValue
     */
    public IPMSEntityImpl getProgramTopValue() {
        return (IPMSEntityImpl) getEntity(ENTITY_PROGRAMTOPVALUE);
    }

    /**
     * Gets ProgramTopSubcategory entity object.
     * @return the ProgramTopSubcategory
     */
    public IPMSEntityImpl getProgramTopSubcategory() {
        return (IPMSEntityImpl) getEntity(ENTITY_PROGRAMTOPSUBCATEGORY);
    }

    /**
     * Gets the attribute value for ID using the alias name Id.
     * @return the ID
     */
    public BigDecimal getId() {
        return (BigDecimal) getAttributeInternal(ID);
    }

    /**
     * Sets <code>value</code> as attribute value for ID using the alias name Id.
     * @param value value to set the ID
     */
    public void setId(BigDecimal value) {
        setAttributeInternal(ID, value);
    }

    /**
     * Gets the attribute value for INDICATION1 using the alias name Indication1.
     * @return the INDICATION1
     */
    public String getIndication1() {
        return (String) getAttributeInternal(INDICATION1);
    }

    /**
     * Sets <code>value</code> as attribute value for INDICATION1 using the alias name Indication1.
     * @param value value to set the INDICATION1
     */
    public void setIndication1(String value) {
        setAttributeInternal(INDICATION1, value);
    }

    /**
     * Gets the attribute value for INDICATION2 using the alias name Indication2.
     * @return the INDICATION2
     */
    public String getIndication2() {
        return (String) getAttributeInternal(INDICATION2);
    }

    /**
     * Sets <code>value</code> as attribute value for INDICATION2 using the alias name Indication2.
     * @param value value to set the INDICATION2
     */
    public void setIndication2(String value) {
        setAttributeInternal(INDICATION2, value);
    }

    /**
     * Gets the attribute value for INDICATION3 using the alias name Indication3.
     * @return the INDICATION3
     */
    public String getIndication3() {
        return (String) getAttributeInternal(INDICATION3);
    }

    /**
     * Sets <code>value</code> as attribute value for INDICATION3 using the alias name Indication3.
     * @param value value to set the INDICATION3
     */
    public void setIndication3(String value) {
        setAttributeInternal(INDICATION3, value);
    }

    /**
     * Gets the attribute value for INDICATION4 using the alias name Indication4.
     * @return the INDICATION4
     */
    public String getIndication4() {
        return (String) getAttributeInternal(INDICATION4);
    }

    /**
     * Sets <code>value</code> as attribute value for INDICATION4 using the alias name Indication4.
     * @param value value to set the INDICATION4
     */
    public void setIndication4(String value) {
        setAttributeInternal(INDICATION4, value);
    }

    /**
     * Gets the attribute value for INDICATION5 using the alias name Indication5.
     * @return the INDICATION5
     */
    public String getIndication5() {
        return (String) getAttributeInternal(INDICATION5);
    }

    /**
     * Sets <code>value</code> as attribute value for INDICATION5 using the alias name Indication5.
     * @param value value to set the INDICATION5
     */
    public void setIndication5(String value) {
        setAttributeInternal(INDICATION5, value);
    }

    /**
     * Gets the attribute value for INDICATION6 using the alias name Indication6.
     * @return the INDICATION6
     */
    public String getIndication6() {
        return (String) getAttributeInternal(INDICATION6);
    }

    /**
     * Sets <code>value</code> as attribute value for INDICATION6 using the alias name Indication6.
     * @param value value to set the INDICATION6
     */
    public void setIndication6(String value) {
        setAttributeInternal(INDICATION6, value);
    }

    /**
     * Gets the attribute value for INDICATION7 using the alias name Indication7.
     * @return the INDICATION7
     */
    public String getIndication7() {
        return (String) getAttributeInternal(INDICATION7);
    }

    /**
     * Sets <code>value</code> as attribute value for INDICATION7 using the alias name Indication7.
     * @param value value to set the INDICATION7
     */
    public void setIndication7(String value) {
        setAttributeInternal(INDICATION7, value);
    }

    /**
     * Gets the attribute value for INDICATION8 using the alias name Indication8.
     * @return the INDICATION8
     */
    public String getIndication8() {
        return (String) getAttributeInternal(INDICATION8);
    }

    /**
     * Sets <code>value</code> as attribute value for INDICATION8 using the alias name Indication8.
     * @param value value to set the INDICATION8
     */
    public void setIndication8(String value) {
        setAttributeInternal(INDICATION8, value);
    }

    /**
     * Gets the attribute value for PROGRAM_VERSION_ID using the alias name ProgramVersionId.
     * @return the PROGRAM_VERSION_ID
     */
    public BigDecimal getProgramVersionId() {
        return (BigDecimal) getAttributeInternal(PROGRAMVERSIONID);
    }

    /**
     * Sets <code>value</code> as attribute value for PROGRAM_VERSION_ID using the alias name ProgramVersionId.
     * @param value value to set the PROGRAM_VERSION_ID
     */
    public void setProgramVersionId(BigDecimal value) {
        setAttributeInternal(PROGRAMVERSIONID, value);
    }

    /**
     * Gets the attribute value for SUBCATEGORY_CODE using the alias name SubcategoryCode.
     * @return the SUBCATEGORY_CODE
     */
    public String getSubcategoryCode() {
        return (String) getAttributeInternal(SUBCATEGORYCODE);
    }

    /**
     * Sets <code>value</code> as attribute value for SUBCATEGORY_CODE using the alias name SubcategoryCode.
     * @param value value to set the SUBCATEGORY_CODE
     */
    public void setSubcategoryCode(String value) {
        setAttributeInternal(SUBCATEGORYCODE, value);
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
     * Gets the associated <code>Row</code> using master-detail link ProgramTopSubCategoryView.
     */
    public Row getProgramTopSubCategoryView() {
        return (Row) getAttributeInternal(PROGRAMTOPSUBCATEGORYVIEW);
    }

    /**
     * Sets the master-detail link ProgramTopSubCategoryView between this object and <code>value</code>.
     */
    public void setProgramTopSubCategoryView(Row value) {
        setAttributeInternal(PROGRAMTOPSUBCATEGORYVIEW, value);
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
