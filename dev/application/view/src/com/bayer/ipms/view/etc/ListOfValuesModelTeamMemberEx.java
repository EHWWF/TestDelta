package com.bayer.ipms.view.etc;

import com.bayer.ipms.model.base.IPMSApplicationModule;
import com.bayer.ipms.model.views.common.TeamMemberViewRow;
import com.bayer.ipms.view.dbnotification.CountDownLatchEx;
import com.bayer.ipms.view.dbnotification.DBChangeNotification;
import com.bayer.ipms.view.dbnotification.DCNManager;
import com.bayer.ipms.view.dbnotification.DCNParams;
import com.bayer.ipms.view.dbnotification.PromisDBResource;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;
import javax.faces.validator.ValidatorException;

import oracle.adf.share.logging.ADFLogger;
import oracle.adf.view.rich.model.AttributeCriterion;
import oracle.adf.view.rich.model.ColumnDescriptor;
import oracle.adf.view.rich.model.ConjunctionCriterion;
import oracle.adf.view.rich.model.Criterion;
import oracle.adf.view.rich.model.ListOfValuesModel;
import oracle.adf.view.rich.model.QueryDescriptor;
import oracle.adf.view.rich.model.QueryModel;
import oracle.adf.view.rich.model.TableModel;

import oracle.jdbc.NotificationRegistration.RegistrationState;


public class ListOfValuesModelTeamMemberEx
  extends ListOfValuesModel
{

  protected static ADFLogger logger = ADFLogger.createADFLogger(ListOfValuesModelTeamMemberEx.class);
  private ListOfValuesModel model;
  private IPMSApplicationModule appModule;
  private TeamMemberViewRow tmRow;

  public ListOfValuesModelTeamMemberEx()
  {
	 super();

  }

  public ListOfValuesModelTeamMemberEx(ListOfValuesModel md, IPMSApplicationModule am, TeamMemberViewRow tmRowPar)
  {
	 model = md;
	 appModule = am;
	 tmRow = tmRowPar;
  }

  public QueryDescriptor getQueryDescriptor()
  {
	 return model.getQueryDescriptor();
  }

  public QueryModel getQueryModel()
  {
	 return model.getQueryModel();
  }

  public TableModel getTableModel()
  {
	 return model.getTableModel();
  }

  public List<? extends Object> getItems()
  {
	 return model.getItems();
  }

  public List<? extends Object> getRecentItems()
  {
	 return model.getRecentItems();
  }

  public boolean isAutoCompleteEnabled()
  {
	 return false;
  }

  public void performQuery(QueryDescriptor qd)
  {

	 logger.finest("***** LOV Query requested");

	 boolean isValid = false;
	 final String uuid = UUID.randomUUID().toString();

	 final Map<String, String> criterias = new HashMap<String, String>();

	 ConjunctionCriterion cq = qd.getConjunctionCriterion();

	 for (Criterion c: cq.getCriterionList())
	 {
		AttributeCriterion acr = (AttributeCriterion) c;
		List<? extends Object> list = acr.getValues();

		if (list.get(0) != null)
		{

		  criterias.put(acr.getAttribute().getName(), list.get(0).toString());

		  if (list.get(0).toString().length() >= 3)
		  {
			 isValid = true;
		  }
		}
	 }

	 if (!isValid)
	 {
		FacesContext ctx = FacesContext.getCurrentInstance();
		ResourceBundle viewBundle = ResourceBundle.getBundle("com.bayer.ipms.view.bundles.viewBundle");

		FacesMessage errorMessage =
				new FacesMessage(FacesMessage.SEVERITY_ERROR, viewBundle.getString("globalValidationError"),
									  viewBundle.getString("teamMemberErrorCriteriaLengthConstraint"));
		ctx.addMessage(null, errorMessage);
		throw new ValidatorException(errorMessage);
	 }


	 class DCNParamsLDAPSearch
		extends DCNParams

	 {
		@Override
		public void executeLogic()
		{
		  appModule.runStatement("begin import_employees_pkg.search_ad(?,?,?,?); end;", false, uuid, criterias.get("Code"),
										 criterias.get("Forename"), criterias.get("Surname"));
		}
	 }

	 DCNParamsLDAPSearch params = new DCNParamsLDAPSearch();
	 params.setNotifyingSelectStmt("select guid from employee where guid='" + uuid + "'");
	 params.setLockedObject(this);
	 params.setTimeout(180);
	 DCNManager.run(params);

	 logger.finest("***** Performing query...");
	 model.performQuery(qd);
  }

  public List<Object> autoCompleteValue(Object value)
  {
	 return Collections.emptyList();
  }

  public void valueSelected(Object value)
  {
	 model.valueSelected(value);
  }

  public Object getValueFromSelection(Object selectedRow)
  {

	 return model.getValueFromSelection(selectedRow);
  }

  public List<ColumnDescriptor> getItemDescriptors()
  {
	 return model.getItemDescriptors();
  }

}