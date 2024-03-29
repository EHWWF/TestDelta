package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSEntityImpl;
import com.bayer.ipms.model.base.IPMSViewRowImpl;
import com.bayer.ipms.model.views.common.ProjectRelatedDevViewRow;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Thu Jan 13 11:07:53 CET 2022
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ProjectRelatedDevViewRowImpl extends IPMSViewRowImpl implements ProjectRelatedDevViewRow {


    public static final int ENTITY_PROJECTRELATEDDEV = 0;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        Id,
        ProjectId,
        DevProjectId;
        private static AttributesEnum[] vals = null;
        ;
        private static final int firstIndex = 0;

        protected int index() {
            return AttributesEnum.firstIndex() + ordinal();
        }

        protected static final int firstIndex() {
            return firstIndex;
        }

        protected static int count() {
            return AttributesEnum.firstIndex() + AttributesEnum.staticValues().length;
        }

        protected static final AttributesEnum[] staticValues() {
            if (vals == null) {
                vals = AttributesEnum.values();
            }
            return vals;
        }
    }


    public static final int ID = AttributesEnum.Id.index();
    public static final int PROJECTID = AttributesEnum.ProjectId.index();
    public static final int DEVPROJECTID = AttributesEnum.DevProjectId.index();

    /**
     * This is the default constructor (do not remove).
     */
    public ProjectRelatedDevViewRowImpl() {
    }

    /**
     * Gets ProjectRelatedDev entity object.
     * @return the ProjectRelatedDev
     */
    public IPMSEntityImpl getProjectRelatedDev() {
        return (IPMSEntityImpl) getEntity(ENTITY_PROJECTRELATEDDEV);
    }

    /**
     * Gets the attribute value for ID using the alias name Id.
     * @return the ID
     */
    public String getId() {
        return (String) getAttributeInternal(ID);
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
     * Gets the attribute value for DEV_PROJECT_ID using the alias name DevProjectId.
     * @return the DEV_PROJECT_ID
     */
    public String getDevProjectId() {
        return (String) getAttributeInternal(DEVPROJECTID);
    }

    /**
     * Sets <code>value</code> as attribute value for DEV_PROJECT_ID using the alias name DevProjectId.
     * @param value value to set the DEV_PROJECT_ID
     */
    public void setDevProjectId(String value) {
        setAttributeInternal(DEVPROJECTID, value);
    }
}

