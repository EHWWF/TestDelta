package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSEntityImpl;
import com.bayer.ipms.model.base.IPMSViewRowImpl;

import com.bayer.ipms.model.views.common.ProjectTimelineViewRow;

import oracle.jbo.Row;
import oracle.jbo.domain.Date;
import oracle.jbo.server.AttributeDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Apr 15 10:06:46 EEST 2016
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ProjectTimelineViewRowImpl
  extends IPMSViewRowImpl implements ProjectTimelineViewRow
{
    public static final int ENTITY_PROJECT = 0;
    public static final int ENTITY_TIMELINE = 1;
    public static final int ENTITY_TIMELINETYPE = 2;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
  public enum AttributesEnum
  {
        Id {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getId();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        Name {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getName();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setName((String) value);
            }
        }
        ,
        ProjectId {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getProjectId();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        TypeCode {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getTypeCode();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        CreateDate {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getCreateDate();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        UpdateDate {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getUpdateDate();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        SyncDate {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getSyncDate();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        IsSyncing {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getIsSyncing();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setIsSyncing((Boolean) value);
            }
        }
        ,
        Comments {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getComments();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setComments((String) value);
            }
        }
        ,
        TypeName {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getTypeName();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        _TypeCode {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.get_TypeCode();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        ReferenceId {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getReferenceId();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        StartDate {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getStartDate();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setStartDate((Date) value);
            }
        }
        ,
        FinishDate {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getFinishDate();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setFinishDate((Date) value);
            }
        }
        ,
        Publish {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getPublish();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setPublish((String) value);
            }
        }
        ,
        SyncId {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getSyncId();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        Id1 {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getId1();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        Name1 {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getName1();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setName1((String) value);
            }
        }
        ,
        ProgramId {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getProgramId();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setProgramId((String) value);
            }
        }
        ,
        ProjectCode {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getProjectCode();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setProjectCode((String) value);
            }
        }
        ,
        ProjectDescription {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getProjectDescription();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setProjectDescription((String) value);
            }
        }
        ,
        PrjPrgId {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getPrjPrgId();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        ProjectIsActive {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getProjectIsActive();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        SandboxId {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getSandboxId();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        SandCode {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getSandCode();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        SandName {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getSandName();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        PrgId {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getPrgId();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        QualifiedName {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getQualifiedName();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ,
        ProjectView1 {
            public Object get(ProjectTimelineViewRowImpl obj) {
                return obj.getProjectView1();
            }

            public void put(ProjectTimelineViewRowImpl obj, Object value) {
                obj.setAttributeInternal(index(), value);
            }
        }
        ;
        static AttributesEnum[] vals = null;
        ;
        private static final int firstIndex = 0;

	 public abstract Object get(ProjectTimelineViewRowImpl object);

	 public abstract void put(ProjectTimelineViewRowImpl object, Object value);

	 public int index()
	 {
		return AttributesEnum.firstIndex() + ordinal();
	 }

	 public static final int firstIndex()
	 {
		return firstIndex;
	 }

	 public static int count()
	 {
		return AttributesEnum.firstIndex() + AttributesEnum.staticValues().length;
	 }

	 public static final AttributesEnum[] staticValues()
	 {
		if (vals == null)
		{
		  vals = AttributesEnum.values();
		}
		return vals;
	 }
  }


    public static final int ID = AttributesEnum.Id.index();
    public static final int NAME = AttributesEnum.Name.index();
    public static final int PROJECTID = AttributesEnum.ProjectId.index();
    public static final int TYPECODE = AttributesEnum.TypeCode.index();
    public static final int CREATEDATE = AttributesEnum.CreateDate.index();
    public static final int UPDATEDATE = AttributesEnum.UpdateDate.index();
    public static final int SYNCDATE = AttributesEnum.SyncDate.index();
    public static final int ISSYNCING = AttributesEnum.IsSyncing.index();
    public static final int COMMENTS = AttributesEnum.Comments.index();
    public static final int TYPENAME = AttributesEnum.TypeName.index();
    public static final int _TYPECODE = AttributesEnum._TypeCode.index();
    public static final int REFERENCEID = AttributesEnum.ReferenceId.index();
    public static final int STARTDATE = AttributesEnum.StartDate.index();
    public static final int FINISHDATE = AttributesEnum.FinishDate.index();
    public static final int PUBLISH = AttributesEnum.Publish.index();
    public static final int SYNCID = AttributesEnum.SyncId.index();
    public static final int ID1 = AttributesEnum.Id1.index();
    public static final int NAME1 = AttributesEnum.Name1.index();
    public static final int PROGRAMID = AttributesEnum.ProgramId.index();
    public static final int PROJECTCODE = AttributesEnum.ProjectCode.index();
    public static final int PROJECTDESCRIPTION = AttributesEnum.ProjectDescription.index();
    public static final int PRJPRGID = AttributesEnum.PrjPrgId.index();
    public static final int PROJECTISACTIVE = AttributesEnum.ProjectIsActive.index();
    public static final int SANDBOXID = AttributesEnum.SandboxId.index();
    public static final int SANDCODE = AttributesEnum.SandCode.index();
    public static final int SANDNAME = AttributesEnum.SandName.index();
    public static final int PRGID = AttributesEnum.PrgId.index();
    public static final int QUALIFIEDNAME = AttributesEnum.QualifiedName.index();
    public static final int PROJECTVIEW1 = AttributesEnum.ProjectView1.index();

    /**
     * This is the default constructor (do not remove).
     */
  public ProjectTimelineViewRowImpl()
  {
  }

  /**
   * Gets Project entity object.
   * @return the Project
   */
  public IPMSEntityImpl getProject()
  {
	 return (IPMSEntityImpl) getEntity(ENTITY_PROJECT);
  }

  /**
   * Gets Timeline entity object.
   * @return the Timeline
   */
  public IPMSEntityImpl getTimeline()
  {
	 return (IPMSEntityImpl) getEntity(ENTITY_TIMELINE);
  }

  /**
   * Gets TimelineType entity object.
   * @return the TimelineType
   */
  public IPMSEntityImpl getTimelineType()
  {
	 return (IPMSEntityImpl) getEntity(ENTITY_TIMELINETYPE);
  }

  /**
   * Gets the attribute value for ID using the alias name Id.
   * @return the ID
   */
  public String getId()
  {
	 return (String) getAttributeInternal(ID);
  }

  /**
   * Gets the attribute value for NAME using the alias name Name.
   * @return the NAME
   */
  public String getName()
  {
	 return (String) getAttributeInternal(NAME);
  }

  /**
   * Sets <code>value</code> as attribute value for NAME using the alias name Name.
   * @param value value to set the NAME
   */
  public void setName(String value)
  {
	 setAttributeInternal(NAME, value);
  }

  /**
   * Gets the attribute value for PROJECT_ID using the alias name ProjectId.
   * @return the PROJECT_ID
   */
  public String getProjectId()
  {
	 return (String) getAttributeInternal(PROJECTID);
  }

  /**
   * Gets the attribute value for TYPE_CODE using the alias name TypeCode.
   * @return the TYPE_CODE
   */
  public String getTypeCode()
  {
	 return (String) getAttributeInternal(TYPECODE);
  }

  /**
   * Gets the attribute value for CREATE_DATE using the alias name CreateDate.
   * @return the CREATE_DATE
   */
  public Date getCreateDate()
  {
	 return (Date) getAttributeInternal(CREATEDATE);
  }

  /**
   * Gets the attribute value for UPDATE_DATE using the alias name UpdateDate.
   * @return the UPDATE_DATE
   */
  public Date getUpdateDate()
  {
	 return (Date) getAttributeInternal(UPDATEDATE);
  }

  /**
   * Gets the attribute value for SYNC_DATE using the alias name SyncDate.
   * @return the SYNC_DATE
   */
  public Date getSyncDate()
  {
	 return (Date) getAttributeInternal(SYNCDATE);
  }

  /**
   * Gets the attribute value for IS_SYNCING using the alias name IsSyncing.
   * @return the IS_SYNCING
   */
  public Boolean getIsSyncing()
  {
	 return (Boolean) getAttributeInternal(ISSYNCING);
  }

    /**
     * Sets <code>value</code> as attribute value for IS_SYNCING using the alias name IsSyncing.
     * @param value value to set the IS_SYNCING
     */
    public void setIsSyncing(Boolean value) {
        setAttributeInternal(ISSYNCING, value);
    }

    /**
     * Gets the attribute value for COMMENTS using the alias name Comments.
     * @return the COMMENTS
     */
  public String getComments()
  {
	 return (String) getAttributeInternal(COMMENTS);
  }

  /**
   * Sets <code>value</code> as attribute value for COMMENTS using the alias name Comments.
   * @param value value to set the COMMENTS
   */
  public void setComments(String value)
  {
	 setAttributeInternal(COMMENTS, value);
  }

  /**
   * Gets the attribute value for NAME using the alias name TypeName.
   * @return the NAME
   */
  public String getTypeName()
  {
	 return (String) getAttributeInternal(TYPENAME);
  }

  /**
   * Gets the attribute value for CODE using the alias name _TypeCode.
   * @return the CODE
   */
  public String get_TypeCode()
  {
	 return (String) getAttributeInternal(_TYPECODE);
  }

  /**
   * Gets the attribute value for REFERENCE_ID using the alias name ReferenceId.
   * @return the REFERENCE_ID
   */
  public String getReferenceId()
  {
	 return (String) getAttributeInternal(REFERENCEID);
  }

  /**
   * Gets the attribute value for START_DATE using the alias name StartDate.
   * @return the START_DATE
   */
  public Date getStartDate()
  {
	 return (Date) getAttributeInternal(STARTDATE);
  }

  /**
   * Sets <code>value</code> as attribute value for START_DATE using the alias name StartDate.
   * @param value value to set the START_DATE
   */
  public void setStartDate(Date value)
  {
	 setAttributeInternal(STARTDATE, value);
  }

  /**
   * Gets the attribute value for FINISH_DATE using the alias name FinishDate.
   * @return the FINISH_DATE
   */
  public Date getFinishDate()
  {
	 return (Date) getAttributeInternal(FINISHDATE);
  }

  /**
   * Sets <code>value</code> as attribute value for FINISH_DATE using the alias name FinishDate.
   * @param value value to set the FINISH_DATE
   */
  public void setFinishDate(Date value)
  {
	 setAttributeInternal(FINISHDATE, value);
  }

  /**
   * Gets the attribute value for the calculated attribute Publish.
   * @return the Publish
   */
  public String getPublish()
  {
	 return (String) getAttributeInternal(PUBLISH);
  }

  /**
   * Sets <code>value</code> as the attribute value for the calculated attribute Publish.
   * @param value value to set the  Publish
   */
  public void setPublish(String value)
  {
	 setAttributeInternal(PUBLISH, value);
  }

  /**
   * Gets the attribute value for SYNC_ID using the alias name SyncId.
   * @return the SYNC_ID
   */
  public String getSyncId()
  {
	 return (String) getAttributeInternal(SYNCID);
  }

  /**
   * Gets the attribute value for ID using the alias name Id1.
   * @return the ID
   */
  public String getId1()
  {
	 return (String) getAttributeInternal(ID1);
  }

  /**
   * Gets the attribute value for NAME using the alias name Name1.
   * @return the NAME
   */
  public String getName1()
  {
	 return (String) getAttributeInternal(NAME1);
  }

  /**
   * Sets <code>value</code> as attribute value for NAME using the alias name Name1.
   * @param value value to set the NAME
   */
  public void setName1(String value)
  {
	 setAttributeInternal(NAME1, value);
  }

  /**
   * Gets the attribute value for PROGRAM_ID using the alias name ProgramId.
   * @return the PROGRAM_ID
   */
  public String getProgramId()
  {
	 return (String) getAttributeInternal(PROGRAMID);
  }

  /**
   * Sets <code>value</code> as attribute value for PROGRAM_ID using the alias name ProgramId.
   * @param value value to set the PROGRAM_ID
   */
  public void setProgramId(String value)
  {
	 setAttributeInternal(PROGRAMID, value);
  }

  /**
   * Gets the attribute value for CODE using the alias name ProjectCode.
   * @return the CODE
   */
  public String getProjectCode()
  {
	 return (String) getAttributeInternal(PROJECTCODE);
  }

  /**
   * Sets <code>value</code> as attribute value for CODE using the alias name ProjectCode.
   * @param value value to set the CODE
   */
  public void setProjectCode(String value)
  {
	 setAttributeInternal(PROJECTCODE, value);
  }

  /**
   * Gets the attribute value for DESCRIPTION using the alias name ProjectDescription.
   * @return the DESCRIPTION
   */
  public String getProjectDescription()
  {
	 return (String) getAttributeInternal(PROJECTDESCRIPTION);
  }

  /**
   * Sets <code>value</code> as attribute value for DESCRIPTION using the alias name ProjectDescription.
   * @param value value to set the DESCRIPTION
   */
  public void setProjectDescription(String value)
  {
	 setAttributeInternal(PROJECTDESCRIPTION, value);
  }

  /**
   * Gets the attribute value for the calculated attribute PrjPrgId.
   * @return the PrjPrgId
   */
  public String getPrjPrgId()
  {
	 return (String) getAttributeInternal(PRJPRGID);
  }

  /**
   * Gets the attribute value for the calculated attribute ProjectIsActive.
   * @return the ProjectIsActive
   */
  public String getProjectIsActive()
  {
	 return (String) getAttributeInternal(PROJECTISACTIVE);
  }

  /**
   * Gets the attribute value for the calculated attribute SandboxId.
   * @return the SandboxId
   */
  public String getSandboxId()
  {
	 return (String) getAttributeInternal(SANDBOXID);
  }

  /**
   * Gets the attribute value for the calculated attribute SandCode.
   * @return the SandCode
   */
  public String getSandCode()
  {
	 return (String) getAttributeInternal(SANDCODE);
  }

  /**
   * Gets the attribute value for the calculated attribute SandName.
   * @return the SandName
   */
  public String getSandName()
  {
	 return (String) getAttributeInternal(SANDNAME);
  }

  /**
   * Gets the attribute value for the calculated attribute PrgId.
   * @return the PrgId
   */
  public String getPrgId()
  {
	 return (String) getAttributeInternal(PRGID);
  }

  /**
   * Gets the attribute value for the calculated attribute QualifiedName.
   * @return the QualifiedName
   */
  public String getQualifiedName()
  {
	 return (String) getAttributeInternal(QUALIFIEDNAME);
  }

  /**
   * Gets the associated <code>Row</code> using master-detail link ProjectView1.
   */
  public Row getProjectView1()
  {
	 return (Row) getAttributeInternal(PROJECTVIEW1);
  }

  /**
   * Sets the master-detail link ProjectView1 between this object and <code>value</code>.
   */
  public void setProjectView1(Row value)
  {
	 setAttributeInternal(PROJECTVIEW1, value);
  }

  /**
   * getAttrInvokeAccessor: generated method. Do not modify.
   * @param index the index identifying the attribute
   * @param attrDef the attribute

   * @return the attribute value
   * @throws Exception
   */
  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef)
	 throws Exception
  {
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
  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef)
	 throws Exception
  {
        if ((index >= AttributesEnum.firstIndex()) && (index < AttributesEnum.count())) {
            AttributesEnum.staticValues()[index - AttributesEnum.firstIndex()].put(this, value);
            return;
        }
        super.setAttrInvokeAccessor(index, value, attrDef);
    }
  
}

