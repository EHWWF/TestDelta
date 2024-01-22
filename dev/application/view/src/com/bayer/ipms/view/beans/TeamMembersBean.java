package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.base.IPMSApplicationModule;
import com.bayer.ipms.model.views.ProjectViewImpl;
import com.bayer.ipms.model.views.TeamMemberViewImpl;
import com.bayer.ipms.model.views.TeamMemberViewRowImpl;
import com.bayer.ipms.model.views.common.ProgramView;
import com.bayer.ipms.model.views.common.TeamMemberViewRow;
import com.bayer.ipms.view.base.IPMSBean;
import com.bayer.ipms.view.etc.ListOfValuesModelTeamMemberEx;
import com.bayer.ipms.view.utils.ViewUtils;

import java.io.Serializable;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.faces.model.SelectItem;

import oracle.adf.share.ADFContext;
import oracle.adf.view.rich.component.rich.input.RichInputText;
import oracle.adf.view.rich.context.AdfFacesContext;
import oracle.adf.view.rich.model.ListOfValuesModel;

import oracle.binding.OperationBinding;

import oracle.jbo.Row;
import oracle.jbo.RowIterator;
import oracle.jbo.VariableValueManager;

import org.apache.myfaces.trinidad.event.SelectionEvent;

public class TeamMembersBean extends IPMSBean implements Serializable {

    private final String TM_VIEW_IT = "TeamMemberViewIterator";
    private final String PROJECT_VIEW_IT = "ProjectViewIterator";
    private transient RichInputText projectFilterIT;
    private  String projectFilterValue = "";

    public TeamMembersBean() {
    }

    public void clearProgramViewCriteria() {
        ProgramView prgVo = (ProgramView) ViewUtils.getIteratorBinding("ProgramViewIterator").getViewObject();
        prgVo.getViewCriteriaManager().clearViewCriterias();
        prgVo.setNamedWhereClauseParam("SearchProgramIsEmptyVar", true);
        prgVo.executeQuery();
        
        String projectId = (String)AdfFacesContext.getCurrentInstance().getPageFlowScope().get("projectId");
        String programId = (String)AdfFacesContext.getCurrentInstance().getPageFlowScope().get("programId");
            if(projectId != null) {
            //opening the screen in EDIT mode, automatically
            AdfFacesContext.getCurrentInstance().getPageFlowScope().put("editable", "teammember");
            this.setModalModeOn(true);
            
            TeamMemberViewImpl tmVO = (TeamMemberViewImpl) ViewUtils.getIteratorBinding("TeamMemberViewIterator").getViewObject();
            tmVO.setprojectIdBindVar(projectId);    
        }
        
        
        
    }
    
    public void programMenuChangedEventConsumer(String param) {
        
        Map session = ADFContext.getCurrent().getSessionScope();

        String projectId = (String)session.get("projectId");
        String programId = (String)session.get("programId");
        System.err.println("programMenuChangedEventConsumer EVENT RECEIVED" +
              "................:programId=" + programId +
              "................:projectId=" + projectId );
        
        if(programId != null && !programId.isEmpty()) {
            
            TeamMemberViewImpl tmVO = (TeamMemberViewImpl) ViewUtils.getIteratorBinding("TeamMemberViewIterator").getViewObject();
            tmVO.setprojectIdBindVar(null);    
            
            OperationBinding ob = ViewUtils.getOperationBinding("setCurrentRowWithKeyValue");
            ob.getParamsMap().put("rowKey", programId);
            ob.execute();
            
        }
        
    }
    
    public void reQuery() {
        System.err.println("requery the v");
        TeamMemberViewImpl vo = (TeamMemberViewImpl) ViewUtils.getIteratorBinding(TM_VIEW_IT).getViewObject();
        vo.executeQuery();

    }
    

    public void onCommit(ActionEvent actionEvent) {
        if(this.getAssignedProjects() == null || this.getAssignedProjects().length == 0) {
            String errorMessage ="You must make at least one selection.";
            FacesMessage fm = new FacesMessage(FacesMessage.SEVERITY_ERROR, errorMessage, null);
            FacesContext.getCurrentInstance().addMessage(null, fm);
            return;
        }
        
        AdfFacesContext.getCurrentInstance().getPageFlowScope().put("editable", null);
        TeamMemberViewImpl vo = (TeamMemberViewImpl) ViewUtils.getIteratorBinding(TM_VIEW_IT).getViewObject();
        vo.updateAssignedProjects();
        this.setModalModeOff(false);
    }

    public ListOfValuesModel getPopupLovModel() {

        IPMSApplicationModule appModule =
            ((IPMSApplicationModule) ViewUtils.getIteratorBinding(TM_VIEW_IT).getViewObject().getApplicationModule());

        ListOfValuesModel model =
            (ListOfValuesModel) ViewUtils.runValueEl("#{bindings.EmployeeCode.listOfValuesModel}");

        TeamMemberViewRow tmRow =
            (TeamMemberViewRow) ViewUtils.getIteratorBinding(TM_VIEW_IT).getViewObject().getCurrentRow();

        ListOfValuesModelTeamMemberEx modelEx = new ListOfValuesModelTeamMemberEx(model, appModule, tmRow);

        return modelEx;
    }
    
    
    public void commit() {
        ViewUtils.runValueEl("#{bindings.Commit.execute}");
        this.setModalModeOff(false);
    }
                  
    public void rollback() {
     ViewUtils.runValueEl("#{bindings.Rollback.execute}");
        this.setModalModeOff(false);
    }
    


    public Map<Row, List<SelectItem>> getRolesLookup() {

        return new HashMap<Row, List<SelectItem>>() {
            @Override
            public List<SelectItem> get(Object key) {

                TeamMemberViewRow tmRow = (TeamMemberViewRow) key;
                RowIterator tmRI = null;

                switch ((String) ViewUtils.runValueEl("#{pageFlowScope.projectType}")) {
                case "Dev":
                    tmRI = (RowIterator) tmRow.getDevTeamRoleView();
                    break;
                case "PrdMnt":
                    tmRI = (RowIterator) tmRow.getPrdMntTeamRoleView();
                    break;
                case "D2Prj":
                    tmRI = (RowIterator) tmRow.getD2PrjTeamRoleView();
                    break;
                case "SAMD":
                    tmRI = (RowIterator) tmRow.getSAMDTeamRoleView();
                    break;                
                }

                return (new UtilitiesBean()).getLookup().get(tmRI);
            }

        };

    }

    public String[] getAssignedProjects() {

        
        TeamMemberViewRow tmRow =
            (TeamMemberViewRow) ViewUtils.getIteratorBinding("TeamMemberViewIterator").getViewObject().getCurrentRow();
        if (tmRow != null) {

            return tmRow.getAssignedProjects();
        }
        return new String[0];

    }

    public void setAssignedProjects(String[] projectIds) {
        
        TeamMemberViewRow tmRow =
            (TeamMemberViewRow) ViewUtils.getIteratorBinding("TeamMemberViewIterator").getViewObject().getCurrentRow();
        if (projectIds != null)
            tmRow.setAssignedProjects(projectIds);
        else
            tmRow.setAssignedProjects(null);
    }

    public void onDeleteTeamMember(ActionEvent event) {

        TeamMemberViewRow tmRow =
            (TeamMemberViewRow) ViewUtils.getIteratorBinding(TM_VIEW_IT).getViewObject().getCurrentRow();
        if (tmRow != null) {
            tmRow.deleteAssignment();
            ViewUtils.getOperationBinding("TeamMemberDelete").execute();
            ViewUtils.reloadUiComponent("tblTeam");
        }
    }

    public void onRollback(ActionEvent actionEvent) {
        TeamMemberViewRowImpl tmRow =
            (TeamMemberViewRowImpl) ViewUtils.getIteratorBinding("TeamMemberViewIterator").getViewObject().getCurrentRow();
        
        if(tmRow != null)
            tmRow.setAssignedProjectIds(null);
        projectResetAL(null);
        this.setModalModeOff(false);
        
       
    }
    
    public void projectResetAL(ActionEvent actionEvent) {
        
            ProjectViewImpl projectVO = (ProjectViewImpl)ViewUtils.getIteratorBinding("ProjectViewIterator").getViewObject();
            projectVO.removeApplyViewCriteriaName("ProjectFilter");
            projectVO.executeQuery();
            projectFilterValue = null ;
            getProjectFilterIT().resetValue();
//            this.getAssignedProjects();
            ViewUtils.reloadUiComponent("NameSearchid");
            ViewUtils.reloadUiComponent("sms_asgprojects");    
        }
                
                
    public void projectSearchAL(ActionEvent actionEvent) {
            if(!projectFilterValue.isEmpty()){
               
//            ProjectReadOnlyVOImpl projectVO = (ProjectReadOnlyVOImpl)ViewUtils.getIteratorBinding("ProjectReadOnlyVOIterator").getViewObject();
            ProjectViewImpl projectVO = (ProjectViewImpl)ViewUtils.getIteratorBinding("ProjectViewIterator").getViewObject();
            VariableValueManager projectVM = projectVO.getVariableManager();
       
        if(getAssignedProjects().length >0){
                String whereClause = "" ;
                int i = getAssignedProjects().length;
                int loop = 0;
                for (String id : getAssignedProjects()){
                    loop++;
                whereClause = whereClause + id ;
                        if (i > loop){
                            whereClause = whereClause + "," ;
                        } else{
                            whereClause = whereClause  ;
                        }
                    }
                  projectVM.setVariableValue("pIdBind",whereClause);
                } 
       
            projectVM.setVariableValue("pNameBind",projectFilterValue);
        
            projectVO.setApplyViewCriteriaName("ProjectFilter");
            projectVO.executeQuery();
            projectVO.getRowCount();
            ViewUtils.reloadUiComponent("sms_asgprojects");  
            }else{
                this.projectResetAL(actionEvent);
            }
           
        }


    public void setProjectFilterIT(RichInputText projectFilterIT) {
        this.projectFilterIT = projectFilterIT;
    }

    public RichInputText getProjectFilterIT() {
        return projectFilterIT;
    }

    public void setProjectFilterValue(String projectFilterValue) {
        this.projectFilterValue = projectFilterValue;
    }

    public String getProjectFilterValue() {
        return projectFilterValue;
    }

    public void TeamMemberTableSL(SelectionEvent selectionEvent) {
        UtilitiesBean.makeCurrent(selectionEvent);
        projectResetAL(null);
        
    }
}
