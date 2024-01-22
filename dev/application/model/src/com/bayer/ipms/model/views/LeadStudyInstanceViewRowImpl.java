package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSEntityImpl;
import com.bayer.ipms.model.base.IPMSViewRowImpl;

import com.bayer.ipms.model.views.common.LeadStudyInstanceViewRow;

import java.sql.Date;

import oracle.jbo.Row;
import oracle.jbo.RowIterator;
import oracle.jbo.server.AttributeDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue Mar 08 14:36:34 EET 2016
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class LeadStudyInstanceViewRowImpl
  extends IPMSViewRowImpl
  implements LeadStudyInstanceViewRow
{


  public static final int ENTITY_LEADSTUDYINSTANCE = 0;

  /**
   * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
   */
  public enum AttributesEnum
  {
	 Id
	 {
		public Object get(LeadStudyInstanceViewRowImpl obj)
		{
		  return obj.getId();
		}

		public void put(LeadStudyInstanceViewRowImpl obj, Object value)
		{
		  obj.setAttributeInternal(index(), value);
		}
	 }
	 ,
	 ProjectId
	 {
		public Object get(LeadStudyInstanceViewRowImpl obj)
		{
		  return obj.getProjectId();
		}

		public void put(LeadStudyInstanceViewRowImpl obj, Object value)
		{
		  obj.setProjectId((String) value);
		}
	 }
	 ,
	 ProjectView
	 {
		public Object get(LeadStudyInstanceViewRowImpl obj)
		{
		  return obj.getProjectView();
		}

		public void put(LeadStudyInstanceViewRowImpl obj, Object value)
		{
		  obj.setAttributeInternal(index(), value);
		}
	 }
	 ,
	 LeadStudiesView
	 {
		public Object get(LeadStudyInstanceViewRowImpl obj)
		{
		  return obj.getLeadStudiesView();
		}

		public void put(LeadStudyInstanceViewRowImpl obj, Object value)
		{
		  obj.setAttributeInternal(index(), value);
		}
	 }
	 ;
	 static AttributesEnum[] vals = null;
	 ;
	 private static final int firstIndex = 0;

	 public abstract Object get(LeadStudyInstanceViewRowImpl object);

	 public abstract void put(LeadStudyInstanceViewRowImpl object, Object value);

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
  public static final int PROJECTID = AttributesEnum.ProjectId.index();
  public static final int PROJECTVIEW = AttributesEnum.ProjectView.index();
  public static final int LEADSTUDIESVIEW = AttributesEnum.LeadStudiesView.index();

  /**
   * This is the default constructor (do not remove).
   */
  public LeadStudyInstanceViewRowImpl()
  {
  }

  /**
   * Gets LeadStudyInstance entity object.
   * @return the LeadStudyInstance
   */
  public IPMSEntityImpl getLeadStudyInstance()
  {
	 return (IPMSEntityImpl) getEntity(ENTITY_LEADSTUDYINSTANCE);
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
   * Gets the attribute value for PROJECT_ID using the alias name ProjectId.
   * @return the PROJECT_ID
   */
  public String getProjectId()
  {
	 return (String) getAttributeInternal(PROJECTID);
  }

  /**
   * Sets <code>value</code> as attribute value for PROJECT_ID using the alias name ProjectId.
   * @param value value to set the PROJECT_ID
   */
  public void setProjectId(String value)
  {
	 setAttributeInternal(PROJECTID, value);
  }


  /**
   * Gets the associated <code>Row</code> using master-detail link ProjectView.
   */
  public Row getProjectView()
  {
	 return (Row) getAttributeInternal(PROJECTVIEW);
  }

  /**
   * Sets the master-detail link ProjectView between this object and <code>value</code>.
   */
  public void setProjectView(Row value)
  {
	 setAttributeInternal(PROJECTVIEW, value);
  }


  /**
   * Gets the associated <code>RowIterator</code> using master-detail link LeadStudiesView.
   */
  public RowIterator getLeadStudiesView()
  {
	 return (RowIterator) getAttributeInternal(LEADSTUDIESVIEW);
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
	 if ((index >= AttributesEnum.firstIndex()) && (index < AttributesEnum.count()))
	 {
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
	 if ((index >= AttributesEnum.firstIndex()) && (index < AttributesEnum.count()))
	 {
		AttributesEnum.staticValues()[index - AttributesEnum.firstIndex()].put(this, value);
		return;
	 }
	 super.setAttrInvokeAccessor(index, value, attrDef);
  }
  
  public void receiveLeadStudies(){
	   runStatement("begin lead_studies_pkg.receive(?); end;", true, getId().toString());
	 }
  
  public void submitLeadStudies(){
		runStatement("begin lead_studies_pkg.send(?); end;", true, getId().toString());
	 }
  
}

