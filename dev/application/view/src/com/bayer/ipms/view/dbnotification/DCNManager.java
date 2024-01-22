package com.bayer.ipms.view.dbnotification;

import com.bayer.ipms.view.beans.LeadStudiesBean;

import java.util.concurrent.TimeUnit;

import oracle.adf.share.logging.ADFLogger;

import oracle.jdbc.NotificationRegistration.RegistrationState;

public class DCNManager
{
  public DCNManager()
  {
	 super();
  }

  protected static ADFLogger logger = ADFLogger.createADFLogger(DCNManager.class);

  public static void run(DCNParams params)
  {

	 final CountDownLatchEx latch = new CountDownLatchEx(1);
	 DBChangeNotification notification = new DBChangeNotification();
	 try
	 {
		notification.subscribeForDBChanges(latch, params.getNotifyingSelectStmt());

		synchronized (params.getLockedObject())
		{
		  logger.finest("******* Stopped " + params.getClass().getName() + ", waiting for notification from DB");
		  params.executeLogic();


		  latch.await(params.getTimeout(), TimeUnit.SECONDS);
		}
		logger.finest("******* Resumed " + params.getClass().getName());

		if (latch.getDcr().getState().equals(RegistrationState.ACTIVE))
		{
		  PromisDBResource.unregisterDCN(latch.getDcr());
		}

	 }
	 catch (Exception e)
	 {

		logger.severe("******* Unable to register DB Notification");
		logger.severe(e);
	 }

  };

}
