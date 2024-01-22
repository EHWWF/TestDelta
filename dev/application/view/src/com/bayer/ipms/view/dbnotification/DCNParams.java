package com.bayer.ipms.view.dbnotification;


public class DCNParams
 
{
  public DCNParams()
  {
	 super();
  }

  // Class object which waits for notification
  private Object lockedObject;
  // SQL statement which reflect change in data which should trigger notification
  private String notifyingSelectStmt;
  // Time to wait for notification. When elapsed, execution is resumed
  private long timeout = 180;

  // Some code which needs to be executed to initiate any process which will raise notification
  public void executeLogic()
  {
  }

  public void setNotifyingSelectStmt(String stmt)
  {
	 notifyingSelectStmt = stmt;
  }

  public String getNotifyingSelectStmt()
  {
	 return notifyingSelectStmt;
  }


  public void setLockedObject(Object obj)
  {
	 lockedObject = obj;
  }

  public Object getLockedObject()
  {
	 return lockedObject;
  }

  public void setTimeout(long tm)
  {
	 timeout = tm;
  }

  public long getTimeout()
  {
	 return timeout;
  }


}
