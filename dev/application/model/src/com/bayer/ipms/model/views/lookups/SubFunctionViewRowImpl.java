package com.bayer.ipms.model.views.lookups;

import com.bayer.ipms.model.base.IPMSEntityImpl;
import com.bayer.ipms.model.base.IPMSLookupViewRowImpl;


import com.bayer.ipms.model.views.lookups.common.SubFunctionViewRow;

import oracle.jbo.RowSet;
import oracle.jbo.server.AttributeDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri May 09 13:56:11 EEST 2014
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class SubFunctionViewRowImpl extends IPMSLookupViewRowImpl implements SubFunctionViewRow {
    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    public enum AttributesEnum {
        Code {
            public Object get(SubFunctionViewRowImpl obj) {
                return obj.getCode();
            }

            public void put(SubFunctionViewRowImpl obj, Object value) {
                obj.setCode((String)value);
            }
        }
        ,
        FunctionCode {
            public Object get(SubFunctionViewRowImpl obj) {
                return obj.getFunctionCode();
            }

            public void put(SubFunctionViewRowImpl obj, Object value) {
                obj.setFunctionCode((String)value);
            }
        }
        ,
        Name {
            public Object get(SubFunctionViewRowImpl obj) {
                return obj.getName();
            }

            public void put(SubFunctionViewRowImpl obj, Object value) {
                obj.setName((String)value);
            }
        }
        ,
        IsActive {
            public Object get(SubFunctionViewRowImpl obj) {
                return obj.getIsActive();
            }

            public void put(SubFunctionViewRowImpl obj, Object value) {
                obj.setIsActive((Boolean)value);
            }
        }
        ,
        FunctionView {
            public Object get(SubFunctionViewRowImpl obj) {
                return obj.getFunctionView();
            }

            public void put(SubFunctionViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ;
        private static AttributesEnum[] vals = null;
        private static final int firstIndex = 0;

        public abstract Object get(SubFunctionViewRowImpl object);

        public abstract void put(SubFunctionViewRowImpl object, Object value);

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
    public static final int FUNCTIONCODE = AttributesEnum.FunctionCode.index();
    public static final int NAME = AttributesEnum.Name.index();
    public static final int ISACTIVE = AttributesEnum.IsActive.index();
    public static final int FUNCTIONVIEW = AttributesEnum.FunctionView.index();

    /**
     * This is the default constructor (do not remove).
     */
    public SubFunctionViewRowImpl() {
    }

    /**
     * Gets SubFunction entity object.
     * @return the SubFunction
     */
    public IPMSEntityImpl getSubFunction() {
        return (IPMSEntityImpl)getEntity(0);
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
     * Gets the attribute value for FUNCTION_CODE using the alias name FunctionCode.
     * @return the FUNCTION_CODE
     */
    public String getFunctionCode() {
        return (String) getAttributeInternal(FUNCTIONCODE);
    }

    /**
     * Sets <code>value</code> as attribute value for FUNCTION_CODE using the alias name FunctionCode.
     * @param value value to set the FUNCTION_CODE
     */
    public void setFunctionCode(String value) {
        setAttributeInternal(FUNCTIONCODE, value);
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
     * Gets the view accessor <code>RowSet</code> FunctionView.
     */
    public RowSet getFunctionView() {
        return (RowSet)getAttributeInternal(FUNCTIONVIEW);
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
    protected void setAttrInvokeAccessor(int index, Object value,
                                         AttributeDefImpl attrDef) throws Exception {
        if ((index >= AttributesEnum.firstIndex()) && (index < AttributesEnum.count())) {
            AttributesEnum.staticValues()[index - AttributesEnum.firstIndex()].put(this, value);
            return;
        }
        super.setAttrInvokeAccessor(index, value, attrDef);
    }
}
