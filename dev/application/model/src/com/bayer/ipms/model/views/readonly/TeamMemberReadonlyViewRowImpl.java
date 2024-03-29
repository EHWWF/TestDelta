package com.bayer.ipms.model.views.readonly;

import com.bayer.ipms.model.base.IPMSViewRowImpl;


import java.sql.Date;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Oct 29 18:53:03 IST 2021
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class TeamMemberReadonlyViewRowImpl extends IPMSViewRowImpl {
    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        Id {
            protected Object get(TeamMemberReadonlyViewRowImpl obj) {
                return obj.getAttributeInternal(index());
            }

            protected void put(TeamMemberReadonlyViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        ProgramId {
            protected Object get(TeamMemberReadonlyViewRowImpl obj) {
                return obj.getAttributeInternal(index());
            }

            protected void put(TeamMemberReadonlyViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        EmployeeCode {
            protected Object get(TeamMemberReadonlyViewRowImpl obj) {
                return obj.getAttributeInternal(index());
            }

            protected void put(TeamMemberReadonlyViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        RoleCode {
            protected Object get(TeamMemberReadonlyViewRowImpl obj) {
                return obj.getAttributeInternal(index());
            }

            protected void put(TeamMemberReadonlyViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        CreateUserId {
            protected Object get(TeamMemberReadonlyViewRowImpl obj) {
                return obj.getAttributeInternal(index());
            }

            protected void put(TeamMemberReadonlyViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        CreateDate {
            protected Object get(TeamMemberReadonlyViewRowImpl obj) {
                return obj.getAttributeInternal(index());
            }

            protected void put(TeamMemberReadonlyViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        UpdateUserId {
            protected Object get(TeamMemberReadonlyViewRowImpl obj) {
                return obj.getAttributeInternal(index());
            }

            protected void put(TeamMemberReadonlyViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        UpdateDate {
            protected Object get(TeamMemberReadonlyViewRowImpl obj) {
                return obj.getAttributeInternal(index());
            }

            protected void put(TeamMemberReadonlyViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        UniqueAssignment {
            protected Object get(TeamMemberReadonlyViewRowImpl obj) {
                return obj.getAttributeInternal(index());
            }

            protected void put(TeamMemberReadonlyViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ;
        private static AttributesEnum[] vals = null;
        private static final int firstIndex = 0;

        protected abstract Object get(TeamMemberReadonlyViewRowImpl object);

        protected abstract void put(TeamMemberReadonlyViewRowImpl object, Object value);

        protected int index() {
            return TeamMemberReadonlyViewRowImpl.AttributesEnum.firstIndex() + ordinal();
        }

        protected static final int firstIndex() {
            return firstIndex;
        }

        protected static int count() {
            return TeamMemberReadonlyViewRowImpl.AttributesEnum.firstIndex() + TeamMemberReadonlyViewRowImpl.AttributesEnum
                                                                                                            .staticValues().length;
        }

        protected static final AttributesEnum[] staticValues() {
            if (vals == null) {
                vals = TeamMemberReadonlyViewRowImpl.AttributesEnum.values();
            }
            return vals;
        }
    }


    public static final int ID = AttributesEnum.Id.index();
    public static final int PROGRAMID = AttributesEnum.ProgramId.index();
    public static final int EMPLOYEECODE = AttributesEnum.EmployeeCode.index();
    public static final int ROLECODE = AttributesEnum.RoleCode.index();
    public static final int CREATEUSERID = AttributesEnum.CreateUserId.index();
    public static final int CREATEDATE = AttributesEnum.CreateDate.index();
    public static final int UPDATEUSERID = AttributesEnum.UpdateUserId.index();
    public static final int UPDATEDATE = AttributesEnum.UpdateDate.index();
    public static final int UNIQUEASSIGNMENT = AttributesEnum.UniqueAssignment.index();

    /**
     * This is the default constructor (do not remove).
     */
    public TeamMemberReadonlyViewRowImpl() {
    }
}

