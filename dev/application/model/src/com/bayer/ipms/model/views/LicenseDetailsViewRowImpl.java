package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSEntityImpl;
import com.bayer.ipms.model.base.IPMSViewRowImpl;

import com.bayer.ipms.model.views.common.LicenseDetailsViewRow;

import java.sql.Date;

import oracle.jbo.RowSet;
import oracle.jbo.server.AttributeDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Mon Nov 29 12:06:09 CET 2021
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class LicenseDetailsViewRowImpl extends IPMSViewRowImpl implements LicenseDetailsViewRow {


    public static final int ENTITY_LICENSEDETAILS = 0;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        Id {
            protected Object get(LicenseDetailsViewRowImpl obj) {
                return obj.getId();
            }

            protected void put(LicenseDetailsViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        ProjectId {
            protected Object get(LicenseDetailsViewRowImpl obj) {
                return obj.getProjectId();
            }

            protected void put(LicenseDetailsViewRowImpl obj, Object value) {
                obj.setProjectId((String) value);
            }
        }
        ,
        LicenseAgreementDate {
            protected Object get(LicenseDetailsViewRowImpl obj) {
                return obj.getLicenseAgreementDate();
            }

            protected void put(LicenseDetailsViewRowImpl obj, Object value) {
                obj.setLicenseAgreementDate((Date) value);
            }
        }
        ,
        LicenseComment {
            protected Object get(LicenseDetailsViewRowImpl obj) {
                return obj.getLicenseComment();
            }

            protected void put(LicenseDetailsViewRowImpl obj, Object value) {
                obj.setLicenseComment((String) value);
            }
        }
        ,
        UpdateUserId {
            protected Object get(LicenseDetailsViewRowImpl obj) {
                return obj.getUpdateUserId();
            }

            protected void put(LicenseDetailsViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        CreateUserId {
            protected Object get(LicenseDetailsViewRowImpl obj) {
                return obj.getCreateUserId();
            }

            protected void put(LicenseDetailsViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        CreateDate {
            protected Object get(LicenseDetailsViewRowImpl obj) {
                return obj.getCreateDate();
            }

            protected void put(LicenseDetailsViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        UpdateDate {
            protected Object get(LicenseDetailsViewRowImpl obj) {
                return obj.getUpdateDate();
            }

            protected void put(LicenseDetailsViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        LicenseTypeCode {
            protected Object get(LicenseDetailsViewRowImpl obj) {
                return obj.getLicenseTypeCode();
            }

            protected void put(LicenseDetailsViewRowImpl obj, Object value) {
                obj.setLicenseTypeCode((String) value);
            }
        }
        ,
        LicenseeCode {
            protected Object get(LicenseDetailsViewRowImpl obj) {
                return obj.getLicenseeCode();
            }

            protected void put(LicenseDetailsViewRowImpl obj, Object value) {
                obj.setLicenseeCode((String) value);
            }
        }
        ,
        LicensorCode {
            protected Object get(LicenseDetailsViewRowImpl obj) {
                return obj.getLicensorCode();
            }

            protected void put(LicenseDetailsViewRowImpl obj, Object value) {
                obj.setLicensorCode((String) value);
            }
        }
        ,
        PartnerView {
            protected Object get(LicenseDetailsViewRowImpl obj) {
                return obj.getPartnerView();
            }

            protected void put(LicenseDetailsViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        LicenseDetailTypeView {
            protected Object get(LicenseDetailsViewRowImpl obj) {
                return obj.getLicenseDetailTypeView();
            }

            protected void put(LicenseDetailsViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ;
        private static AttributesEnum[] vals = null;
        ;
        private static final int firstIndex = 0;

        protected abstract Object get(LicenseDetailsViewRowImpl object);

        protected abstract void put(LicenseDetailsViewRowImpl object, Object value);

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
    public static final int LICENSEAGREEMENTDATE = AttributesEnum.LicenseAgreementDate.index();
    public static final int LICENSECOMMENT = AttributesEnum.LicenseComment.index();
    public static final int UPDATEUSERID = AttributesEnum.UpdateUserId.index();
    public static final int CREATEUSERID = AttributesEnum.CreateUserId.index();
    public static final int CREATEDATE = AttributesEnum.CreateDate.index();
    public static final int UPDATEDATE = AttributesEnum.UpdateDate.index();
    public static final int LICENSETYPECODE = AttributesEnum.LicenseTypeCode.index();
    public static final int LICENSEECODE = AttributesEnum.LicenseeCode.index();
    public static final int LICENSORCODE = AttributesEnum.LicensorCode.index();
    public static final int PARTNERVIEW = AttributesEnum.PartnerView.index();
    public static final int LICENSEDETAILTYPEVIEW = AttributesEnum.LicenseDetailTypeView.index();

    /**
     * This is the default constructor (do not remove).
     */
    public LicenseDetailsViewRowImpl() {
    }

    /**
     * Gets LicenseDetails entity object.
     * @return the LicenseDetails
     */
    public IPMSEntityImpl getLicenseDetails() {
        return (IPMSEntityImpl) getEntity(ENTITY_LICENSEDETAILS);
    }

    /**
     * Gets the attribute value for ID using the alias name Id.
     * @return the ID
     */
    public Integer getId() {
        return (Integer) getAttributeInternal(ID);
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
     * Gets the attribute value for LICENSE_AGREEMENT_DATE using the alias name LicenseAgreementDate.
     * @return the LICENSE_AGREEMENT_DATE
     */
    public Date getLicenseAgreementDate() {
        return (Date) getAttributeInternal(LICENSEAGREEMENTDATE);
    }

    /**
     * Sets <code>value</code> as attribute value for LICENSE_AGREEMENT_DATE using the alias name LicenseAgreementDate.
     * @param value value to set the LICENSE_AGREEMENT_DATE
     */
    public void setLicenseAgreementDate(Date value) {
        setAttributeInternal(LICENSEAGREEMENTDATE, value);
    }


    /**
     * Gets the attribute value for LICENSE_COMMENT using the alias name LicenseComment.
     * @return the LICENSE_COMMENT
     */
    public String getLicenseComment() {
        return (String) getAttributeInternal(LICENSECOMMENT);
    }

    /**
     * Sets <code>value</code> as attribute value for LICENSE_COMMENT using the alias name LicenseComment.
     * @param value value to set the LICENSE_COMMENT
     */
    public void setLicenseComment(String value) {
        setAttributeInternal(LICENSECOMMENT, value);
    }

    /**
     * Gets the attribute value for UPDATE_USER_ID using the alias name UpdateUserId.
     * @return the UPDATE_USER_ID
     */
    public String getUpdateUserId() {
        return (String) getAttributeInternal(UPDATEUSERID);
    }

    /**
     * Gets the attribute value for CREATE_USER_ID using the alias name CreateUserId.
     * @return the CREATE_USER_ID
     */
    public String getCreateUserId() {
        return (String) getAttributeInternal(CREATEUSERID);
    }

    /**
     * Gets the attribute value for CREATE_DATE using the alias name CreateDate.
     * @return the CREATE_DATE
     */
    public Date getCreateDate() {
        return (Date) getAttributeInternal(CREATEDATE);
    }

    /**
     * Gets the attribute value for UPDATE_DATE using the alias name UpdateDate.
     * @return the UPDATE_DATE
     */
    public Date getUpdateDate() {
        return (Date) getAttributeInternal(UPDATEDATE);
    }


    /**
     * Gets the attribute value for LICENSE_TYPE_CODE using the alias name LicenseTypeCode.
     * @return the LICENSE_TYPE_CODE
     */
    public String getLicenseTypeCode() {
        return (String) getAttributeInternal(LICENSETYPECODE);
    }

    /**
     * Sets <code>value</code> as attribute value for LICENSE_TYPE_CODE using the alias name LicenseTypeCode.
     * @param value value to set the LICENSE_TYPE_CODE
     */
    public void setLicenseTypeCode(String value) {
        setAttributeInternal(LICENSETYPECODE, value);
    }

    /**
     * Gets the attribute value for LICENSEE_CODE using the alias name LicenseeCode.
     * @return the LICENSEE_CODE
     */
    public String getLicenseeCode() {
        return (String) getAttributeInternal(LICENSEECODE);
    }

    /**
     * Sets <code>value</code> as attribute value for LICENSEE_CODE using the alias name LicenseeCode.
     * @param value value to set the LICENSEE_CODE
     */
    public void setLicenseeCode(String value) {
        setAttributeInternal(LICENSEECODE, value);
    }

    /**
     * Gets the attribute value for LICENSOR_CODE using the alias name LicensorCode.
     * @return the LICENSOR_CODE
     */
    public String getLicensorCode() {
        return (String) getAttributeInternal(LICENSORCODE);
    }

    /**
     * Sets <code>value</code> as attribute value for LICENSOR_CODE using the alias name LicensorCode.
     * @param value value to set the LICENSOR_CODE
     */
    public void setLicensorCode(String value) {
        setAttributeInternal(LICENSORCODE, value);
    }

    /**
     * Gets the view accessor <code>RowSet</code> PartnerView.
     */
    public RowSet getPartnerView() {
        return (RowSet) getAttributeInternal(PARTNERVIEW);
    }

    /**
     * Gets the view accessor <code>RowSet</code> LicenseDetailTypeView.
     */
    public RowSet getLicenseDetailTypeView() {
        return (RowSet) getAttributeInternal(LICENSEDETAILTYPEVIEW);
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

