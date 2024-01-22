package com.bayer.ipms.model.views.lookups;

import com.bayer.ipms.model.base.IPMSLookupViewRowImpl;
import com.bayer.ipms.model.base.IPMSViewRowImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed Mar 23 14:42:40 EET 2016
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class BusinessActivityViewRowImpl extends IPMSLookupViewRowImpl {


    public static final int ENTITY_BUSINESSACTIVITY = 0;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    public enum AttributesEnum {
        BackendName {
            public Object get(BusinessActivityViewRowImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(BusinessActivityViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        FrontendName {
            public Object get(BusinessActivityViewRowImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(BusinessActivityViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        CategoryId {
            public Object get(BusinessActivityViewRowImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(BusinessActivityViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        BaLogBackendName {
            public Object get(BusinessActivityViewRowImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(BusinessActivityViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        BusinessActivityCategoryView {
            public Object get(BusinessActivityViewRowImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(BusinessActivityViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ;
        static AttributesEnum[] vals = null;
        ;
        private static final int firstIndex = 0;

        public abstract Object get(BusinessActivityViewRowImpl object);

        public abstract void put(BusinessActivityViewRowImpl object, Object value);

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


    public static final int BACKENDNAME = AttributesEnum.BackendName.index();
    public static final int FRONTENDNAME = AttributesEnum.FrontendName.index();
    public static final int CATEGORYID = AttributesEnum.CategoryId.index();
    public static final int BALOGBACKENDNAME = AttributesEnum.BaLogBackendName.index();
    public static final int BUSINESSACTIVITYCATEGORYVIEW = AttributesEnum.BusinessActivityCategoryView.index();

    /**
     * This is the default constructor (do not remove).
     */
    public BusinessActivityViewRowImpl() {
    }
}
