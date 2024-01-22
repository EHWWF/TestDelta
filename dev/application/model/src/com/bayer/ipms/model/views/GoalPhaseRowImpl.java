package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSEntityImpl;
import com.bayer.ipms.model.base.IPMSViewRowImpl;

import com.bayer.ipms.model.views.common.GoalPhaseRow;

import oracle.jbo.server.AttributeDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue Nov 03 14:26:06 EET 2015
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class GoalPhaseRowImpl extends IPMSViewRowImpl implements GoalPhaseRow {


    public static final int ENTITY_CONFIGURATION = 0;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    public enum AttributesEnum {
        Code {
            public Object get(GoalPhaseRowImpl obj) {
                return obj.getCode();
            }

            public void put(GoalPhaseRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        GoalTrackYear {
            public Object get(GoalPhaseRowImpl obj) {
                return obj.getGoalTrackYear();
            }

            public void put(GoalPhaseRowImpl obj, Object value) {
                obj.setGoalTrackYear((String) value);
            }
        }
        ;
        static AttributesEnum[] vals = null;
        ;
        private static final int firstIndex = 0;

        public abstract Object get(GoalPhaseRowImpl object);

        public abstract void put(GoalPhaseRowImpl object, Object value);

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
    public static final int GOALTRACKYEAR = AttributesEnum.GoalTrackYear.index();

    /**
     * This is the default constructor (do not remove).
     */
    public GoalPhaseRowImpl() {
    }

    /**
     * Gets Configuration entity object.
     * @return the Configuration
     */
    public IPMSEntityImpl getConfiguration() {
        return (IPMSEntityImpl) getEntity(ENTITY_CONFIGURATION);
    }


    /**
     * Gets the attribute value for CODE using the alias name Code.
     * @return the CODE
     */
    public String getCode() {
        return (String) getAttributeInternal(CODE);
    }


    /**
     * Gets the attribute value for the calculated attribute GoalTrackYear.
     * @return the GoalTrackYear
     */
    public String getGoalTrackYear() {
        return (String) getAttributeInternal(GOALTRACKYEAR);
    }

    /**
     * Sets <code>value</code> as the attribute value for the calculated attribute GoalTrackYear.
     * @param value value to set the  GoalTrackYear
     */
    public void setGoalTrackYear(String value) {
        setAttributeInternal(GOALTRACKYEAR, value);
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

    public void updateRefDate() {
        runStatement("begin goal_pkg.update_ref_date_after_config; end;", true);

        this.refresh();
    }
}

