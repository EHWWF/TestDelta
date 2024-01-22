package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSViewRowImpl;

import com.bayer.ipms.model.views.common.TimelinePublishCommentsViewRow;

import java.sql.Date;

import oracle.jbo.server.AttributeDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Thu Apr 14 19:10:31 EEST 2016
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class TimelinePublishCommentsViewRowImpl
  extends IPMSViewRowImpl
  implements TimelinePublishCommentsViewRow
{
  /**
   * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
   */
  public enum AttributesEnum
  {
	 Id
	 {
		public Object get(TimelinePublishCommentsViewRowImpl obj)
		{
		  return obj.getId();
		}

		public void put(TimelinePublishCommentsViewRowImpl obj, Object value)
		{
		  obj.setAttributeInternal(index(), value);
		}
	 }
	 ,
	 ProjectId
	 {
		public Object get(TimelinePublishCommentsViewRowImpl obj)
		{
		  return obj.getProjectId();
		}

		public void put(TimelinePublishCommentsViewRowImpl obj, Object value)
		{
		  obj.setAttributeInternal(index(), value);
		}
	 }
	 ,
	 Comments
	 {
		public Object get(TimelinePublishCommentsViewRowImpl obj)
		{
		  return obj.getComments();
		}

		public void put(TimelinePublishCommentsViewRowImpl obj, Object value)
		{
		  obj.setComments((String) value);
		}
	 }
	 ,
	 CreateDate
	 {
		public Object get(TimelinePublishCommentsViewRowImpl obj)
		{
		  return obj.getCreateDate();
		}

		public void put(TimelinePublishCommentsViewRowImpl obj, Object value)
		{
		  obj.setAttributeInternal(index(), value);
		}
	 }
	 ;
	 private static AttributesEnum[] vals = null;
	 private static final int firstIndex = 0;

	 public abstract Object get(TimelinePublishCommentsViewRowImpl object);

	 public abstract void put(TimelinePublishCommentsViewRowImpl object, Object value);

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
  public static final int COMMENTS = AttributesEnum.Comments.index();
  public static final int CREATEDATE = AttributesEnum.CreateDate.index();

  /**
   * This is the default constructor (do not remove).
   */
  public TimelinePublishCommentsViewRowImpl()
  {
  }

  /**
   * Gets the attribute value for the calculated attribute Id.
   * @return the Id
   */
  public String getId()
  {
	 return (String) getAttributeInternal(ID);
  }


  /**
   * Gets the attribute value for the calculated attribute ProjectId.
   * @return the ProjectId
   */
  public String getProjectId()
  {
	 return (String) getAttributeInternal(PROJECTID);
  }

  /**
   * Gets the attribute value for the calculated attribute Comments.
   * @return the Comments
   */
  public String getComments()
  {
	 return (String) getAttributeInternal(COMMENTS);
  }

  /**
   * Sets <code>value</code> as the attribute value for the calculated attribute Comments.
   * @param value value to set the  Comments
   */
  public void setComments(String value)
  {
	 setAttributeInternal(COMMENTS, value);
  }

  /**
   * Gets the attribute value for the calculated attribute CreateDate.
   * @return the CreateDate
   */
  public Date getCreateDate()
  {
	 return (Date) getAttributeInternal(CREATEDATE);
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
}
