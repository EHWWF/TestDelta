package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSEntityImpl;
import com.bayer.ipms.model.base.IPMSViewRowImpl;


import com.bayer.ipms.model.views.common.TppCategoryViewRow;

import java.sql.Date;

import oracle.jbo.RowIterator;
import oracle.jbo.server.AttributeDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed Jul 08 15:59:45 EEST 2015
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class TppCategoryViewRowImpl extends IPMSViewRowImpl implements TppCategoryViewRow {


    public static final int ENTITY_TPPCATEGORY = 0;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    public enum AttributesEnum {
        Code {
            public Object get(TppCategoryViewRowImpl obj) {
                return obj.getCode();
            }

            public void put(TppCategoryViewRowImpl obj, Object value) {
                obj.setCode((String) value);
            }
        }
        ,
        Name {
            public Object get(TppCategoryViewRowImpl obj) {
                return obj.getName();
            }

            public void put(TppCategoryViewRowImpl obj, Object value) {
                obj.setName((String) value);
            }
        }
        ,
        Description {
            public Object get(TppCategoryViewRowImpl obj) {
                return obj.getDescription();
            }

            public void put(TppCategoryViewRowImpl obj, Object value) {
                obj.setDescription((String) value);
            }
        }
        ,
        IsActive {
            public Object get(TppCategoryViewRowImpl obj) {
                return obj.getIsActive();
            }

            public void put(TppCategoryViewRowImpl obj, Object value) {
                obj.setIsActive((Boolean) value);
            }
        }
        ,
        ModifyDate {
            public Object get(TppCategoryViewRowImpl obj) {
                return obj.getModifyDate();
            }

            public void put(TppCategoryViewRowImpl obj, Object value) {
                obj.setModifyDate((Date) value);
            }
        }
        ,
        TppSubcategoryView {
            public Object get(TppCategoryViewRowImpl obj) {
                return obj.getTppSubcategoryView();
            }

            public void put(TppCategoryViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ;
        static AttributesEnum[] vals = null;
        ;
        private static final int firstIndex = 0;

        public abstract Object get(TppCategoryViewRowImpl object);

        public abstract void put(TppCategoryViewRowImpl object, Object value);

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
    public static final int DESCRIPTION = AttributesEnum.Description.index();
    public static final int ISACTIVE = AttributesEnum.IsActive.index();
    public static final int MODIFYDATE = AttributesEnum.ModifyDate.index();
    public static final int TPPSUBCATEGORYVIEW = AttributesEnum.TppSubcategoryView.index();

    /**
     * This is the default constructor (do not remove).
     */
    public TppCategoryViewRowImpl() {
    }

    /**
     * Gets TppCategory entity object.
     * @return the TppCategory
     */
    public IPMSEntityImpl getTppCategory() {
        return (IPMSEntityImpl) getEntity(ENTITY_TPPCATEGORY);
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
     * Gets the attribute value for MODIFY_DATE using the alias name ModifyDate.
     * @return the MODIFY_DATE
     */
    public Date getModifyDate() {
        return (Date) getAttributeInternal(MODIFYDATE);
    }

    /**
     * Sets <code>value</code> as attribute value for MODIFY_DATE using the alias name ModifyDate.
     * @param value value to set the MODIFY_DATE
     */
    public void setModifyDate(Date value) {
        setAttributeInternal(MODIFYDATE, value);
    }

    /**
     * Gets the associated <code>RowIterator</code> using master-detail link TppSubcategoryView.
     */
    public RowIterator getTppSubcategoryView() {
        return (RowIterator) getAttributeInternal(TPPSUBCATEGORYVIEW);
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

