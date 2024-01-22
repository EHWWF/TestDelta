package com.bayer.ipms.view.beans;

import com.bayer.ipms.model.base.IPMSApplicationModule;
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

import javax.faces.event.ActionEvent;

import javax.faces.model.SelectItem;

import oracle.adf.view.rich.context.AdfFacesContext;
import oracle.adf.view.rich.model.ListOfValuesModel;

import oracle.jbo.Row;
import oracle.jbo.RowIterator;
import oracle.jbo.ViewObject;


public class ProjectTeamBean extends IPMSBean implements Serializable {

    public ProjectTeamBean() {
    }

    public void requery() {
        ViewObject prgVo = ViewUtils.getIteratorBinding("ProjectMemberViewIterator").getViewObject();
        prgVo.executeQuery();
    }
    
    
    public void initScreen() {
        //System.err.println("project team task flow start");
    }

   
   
}
