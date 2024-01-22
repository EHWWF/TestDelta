package com.bayer.ipms.model.entities;

import com.bayer.ipms.model.base.IPMSEntityImpl;

import oracle.jbo.Key;
import oracle.jbo.server.EntityDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed Oct 02 18:05:28 EEST 2019
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class GoalImpl extends IPMSEntityImpl {
    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    public enum AttributesEnum {
        Id {
            public Object get(GoalImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(GoalImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        ProjectId {
            public Object get(GoalImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(GoalImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        Goal {
            public Object get(GoalImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(GoalImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        Type {
            public Object get(GoalImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(GoalImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        StudyId {
            public Object get(GoalImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(GoalImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        PlanReference {
            public Object get(GoalImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(GoalImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        PlanReferenceDate {
            public Object get(GoalImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(GoalImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        Status {
            public Object get(GoalImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(GoalImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        TargetDate {
            public Object get(GoalImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(GoalImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        AchievedDate {
            public Object get(GoalImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(GoalImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        RevisedDate {
            public Object get(GoalImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(GoalImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        Comments {
            public Object get(GoalImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(GoalImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        IsManualStatus {
            public Object get(GoalImpl obj) {
                return obj.getAttributeInternal(index());
            }

            public void put(GoalImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ;
        private static AttributesEnum[] vals = null;
        private static final int firstIndex = 0;

        public abstract Object get(GoalImpl object);

        public abstract void put(GoalImpl object, Object value);

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
    public static final int PROJECTID = AttributesEnum.ProjectId.index();
    public static final int GOAL = AttributesEnum.Goal.index();
    public static final int TYPE = AttributesEnum.Type.index();
    public static final int STUDYID = AttributesEnum.StudyId.index();
    public static final int PLANREFERENCE = AttributesEnum.PlanReference.index();
    public static final int PLANREFERENCEDATE = AttributesEnum.PlanReferenceDate.index();
    public static final int STATUS = AttributesEnum.Status.index();
    public static final int TARGETDATE = AttributesEnum.TargetDate.index();
    public static final int ACHIEVEDDATE = AttributesEnum.AchievedDate.index();
    public static final int REVISEDDATE = AttributesEnum.RevisedDate.index();
    public static final int COMMENTS = AttributesEnum.Comments.index();
    public static final int ISMANUALSTATUS = AttributesEnum.IsManualStatus.index();

    /**
     * This is the default constructor (do not remove).
     */
    public GoalImpl() {
    }

    /**
     * @param id key constituent

     * @return a Key object based on given key constituents.
     */
    public static Key createPrimaryKey(Integer id) {
        return new Key(new Object[] { id });
    }

    /**
     * @return the definition object for this instance class.
     */
    public static synchronized EntityDefImpl getDefinitionObject() {
        return EntityDefImpl.findDefObject("com.bayer.ipms.model.entities.Goal");
    }


}

