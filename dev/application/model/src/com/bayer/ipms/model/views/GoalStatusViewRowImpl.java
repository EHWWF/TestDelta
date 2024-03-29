package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSEntityImpl;
import com.bayer.ipms.model.base.IPMSViewRowImpl;

import com.bayer.ipms.model.views.common.GoalStatusViewRow;

import java.math.BigDecimal;

import oracle.jbo.server.AttributeDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Jun 26 09:14:20 EEST 2015
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class GoalStatusViewRowImpl extends IPMSViewRowImpl implements GoalStatusViewRow {


    public static final int ENTITY_GOALSTATUS = 0;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    public enum AttributesEnum {
        Code {
            public Object get(GoalStatusViewRowImpl obj) {
                return obj.getCode();
            }

            public void put(GoalStatusViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        IsActive {
            public Object get(GoalStatusViewRowImpl obj) {
                return obj.getIsActive();
            }

            public void put(GoalStatusViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        Name {
            public Object get(GoalStatusViewRowImpl obj) {
                return obj.getName();
            }

            public void put(GoalStatusViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        TrueFlag {
            public Object get(GoalStatusViewRowImpl obj) {
                return obj.getTrueFlag();
            }

            public void put(GoalStatusViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ;
        static AttributesEnum[] vals = null;
        ;
        private static final int firstIndex = 0;

        public abstract Object get(GoalStatusViewRowImpl object);

        public abstract void put(GoalStatusViewRowImpl object, Object value);

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
    public static final int ISACTIVE = AttributesEnum.IsActive.index();
    public static final int NAME = AttributesEnum.Name.index();
    public static final int TRUEFLAG = AttributesEnum.TrueFlag.index();

    /**
     * This is the default constructor (do not remove).
     */
    public GoalStatusViewRowImpl() {
    }

    /**
     * Gets GoalStatus entity object.
     * @return the GoalStatus
     */
    public IPMSEntityImpl getGoalStatus() {
        return (IPMSEntityImpl) getEntity(ENTITY_GOALSTATUS);
    }

    /**
     * Gets the attribute value for CODE using the alias name Code.
     * @return the CODE
     */
    public String getCode() {
        return (String) getAttributeInternal(CODE);
    }

    /**
     * Gets the attribute value for IS_ACTIVE using the alias name IsActive.
     * @return the IS_ACTIVE
     */
    public Integer getIsActive() {
        return (Integer) getAttributeInternal(ISACTIVE);
    }

    /**
     * Gets the attribute value for NAME using the alias name Name.
     * @return the NAME
     */
    public String getName() {
        return (String) getAttributeInternal(NAME);
    }


    /**
     * Gets the attribute value for the calculated attribute TrueFlag.
     * @return the TrueFlag
     */
    public BigDecimal getTrueFlag() {
        return (BigDecimal) getAttributeInternal(TRUEFLAG);
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

