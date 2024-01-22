package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.views.common.LeadStudyInstanceViewRow;
import com.bayer.ipms.view.dbnotification.DCNManager;
import com.bayer.ipms.view.dbnotification.DCNParams;
import com.bayer.ipms.view.utils.ViewUtils;

import javax.faces.event.ActionEvent;

import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.component.rich.data.RichTable;
import oracle.adf.view.rich.component.rich.output.RichPanelCollection;
import oracle.adf.view.rich.render.ClientEvent;

public class LeadStudiesBean
{
  public LeadStudiesBean()
  {
  }


  public void onRefresh(ActionEvent actionEvent)
  {
	 ViewUtils.getIteratorBinding("LeadStudyMapViewIterator").executeQuery();
	 ViewUtils.reloadUiComponent("t3");
  }

  private LeadStudyInstanceViewRow getLsiRow()
  {

	 DCIteratorBinding lsiIt =
		  (DCIteratorBinding) ViewUtils.runValueEl("#{data.com_bayer_ipms_view_maintain_lead_studies_setup_lead_study_CreateWithParametersPageDef.LeadStudyInstanceViewIterator}");
	 return (LeadStudyInstanceViewRow) lsiIt.getViewObject().getCurrentRow();

  }


  public void receiveLeadStudies()
  {

	 final LeadStudyInstanceViewRow lsiRow = getLsiRow();

	 class DCNParamsLeadStudyReceive
		extends DCNParams

	 {
		@Override
		public void executeLogic()
		{
		  lsiRow.receiveLeadStudies();
		}
	 }

	 DCNParamsLeadStudyReceive params = new DCNParamsLeadStudyReceive();
	 params.setNotifyingSelectStmt("select id from lead_study_instance lsi where lsi.notify_id='" + lsiRow.getId() +
											 ":READY'");
	 params.setLockedObject(this);
	 params.setTimeout(180);
	 DCNManager.run(params);

  }

  public void submitLeadStudies()
  {


	 final LeadStudyInstanceViewRow lsiRow = getLsiRow();


	 class DCNParamsLeadStudySend
		extends DCNParams

	 {
		@Override
		public void executeLogic()
		{
		  lsiRow.submitLeadStudies();
		}
	 }

	 DCNParamsLeadStudySend params = new DCNParamsLeadStudySend();
	 params.setNotifyingSelectStmt("select id from lead_study_instance lsi where lsi.notify_id='" + lsiRow.getId() +
											 ":DONE'");
	 params.setLockedObject(this);
	 params.setTimeout(180);
	 DCNManager.run(params);


  }

  public void onPageLoad(ClientEvent clientEvent)
  {

	 String currActivityId = ViewUtils.getCurrTrainActivityId();

	 switch (currActivityId)
	 {

		case "receive-data":
		  ViewUtils.handleNavigation("receive");
		  break;
		case "maintain":
		  ViewUtils.getIteratorBinding("LeadStudyMapViewIterator").executeQuery();
		  ((RichPanelCollection) ViewUtils.getUiComponent("pc1")).setVisible(true);
		  ViewUtils.reloadUiComponent("pc1");
		  break;
		case "submit":
		  ViewUtils.handleNavigation("submit");
		  ViewUtils.reloadUiComponent("t3");
		  break;
		case "complete":
		  ViewUtils.getIteratorBinding("LeadStudyMapViewIterator").executeQuery();
		  ((RichPanelCollection) ViewUtils.getUiComponent("pc1")).setVisible(true);
		  ViewUtils.reloadUiComponent("pc1");
		  break;

	 }


  }


//  public boolean isReceiveSkip()
//  {
//	 String currStop = getCurrTrainActivityId();
//
//	 if ("maintain".equals(currStop) ||"submit".equals(currStop) || "complete".equals(currStop))
//	 {
//		return true;
//	 }
//	 return false;
//  }
//
//  public boolean isMaintainSkip()
//  {
//	 String currStop = getCurrTrainActivityId();
//
//	 if ("submit".equals(currStop) || "complete".equals(currStop))
//	 {
//		return true;
//	 }
//	 return false;
//  }
//  
//  public boolean isSubmitSkip()
//  {
//	 String currStop = getCurrTrainActivityId();
//
//	 if ("complete".equals(currStop))
//	 {
//		return true;
//	 }
//	 return false;
//  }

  public String getCurrTrainActivityId()
  {
	 return ViewUtils.getCurrTrainActivityId();

  }

}
