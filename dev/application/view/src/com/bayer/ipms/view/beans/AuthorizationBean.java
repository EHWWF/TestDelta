package com.bayer.ipms.view.beans;


import com.bayer.ipms.model.views.common.ProgramViewRow;
import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.model.views.common.RoleView;
import com.bayer.ipms.view.base.IPMSBean;

import com.bayer.ipms.view.utils.ViewUtils;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import oracle.adf.share.ADFContext;
import oracle.adf.share.security.SecurityContext;

import org.apache.commons.collections.CollectionUtils;


public class AuthorizationBean extends IPMSBean {
    private final Map<ProgramViewRow, Map<String, Boolean>> programRoles =
        Collections.unmodifiableMap(new HashMap<ProgramViewRow, Map<String, Boolean>>() {
            @Override
            public Map<String, Boolean> get(Object key) {
                final ProgramViewRow program = (ProgramViewRow)key;
                return Collections.unmodifiableMap(new HashMap<String, Boolean>() {
                        @Override
                        public Boolean get(Object key) {
                            String role = (String)key;
                            SecurityContext securityContext = ADFContext.getCurrent().getSecurityContext();
                            RoleView roles = (RoleView)program.getRoleView().getViewObject();

                            return (securityContext.isUserInRole(role) &&
                                    CollectionUtils.containsAny(program.getRoles(securityContext.getUserName()),
                                                                roles.getRoles(role)));
                        }
                    });
            }
        });

    private final Map<ProjectViewRow, Map<String, Boolean>> projectRoles =
        Collections.unmodifiableMap(new HashMap<ProjectViewRow, Map<String, Boolean>>() {
            @Override
            public Map<String, Boolean> get(Object key) {
                ProjectViewRow project = (ProjectViewRow)key;

                return programRoles.get(project.getProgramView());
            }
        });


    public AuthorizationBean() {
        super();
    }

    public Map<ProgramViewRow, Map<String, Boolean>> getProgramRoles() {
        return programRoles;
    }

    public Map<ProjectViewRow, Map<String, Boolean>> getProjectRoles() {
        return projectRoles;
    }

    //Project view
    public boolean isProjectViewDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectViewDev'] or  rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ProjectViewAssignedDev']) and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }
    
    public boolean isProjectViewPrdMnt() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectViewPrdMnt'] or  rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ProjectViewAssignedPrdMnt']) and bindings.AreaCode eq 'PRD-MNT'}");
    }
    
    public boolean isProjectViewD2Prj() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectViewD2Prj'] or  rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ProjectViewAssignedD2Prj']) and bindings.AreaCode eq 'D2-PRJ'}");
    }
    
    public boolean isProjectViewSAMD() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectViewSAMD'] or  rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ProjectViewAssignedSAMD']) and bindings.AreaCode eq 'SAMD'}");
    }

    // Editing project

    public boolean isProjectEditDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectEditDev'] or  rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ProjectEditAssignedDev']) and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }
    public boolean isProjectEditPreviousNames() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectEditPreviousNames']}");
    }
    

    public boolean isProjectEditDevOnlyGlobal() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectEditDev'] and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }

    public boolean isProjectEditPrdMnt() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectEditPrdMnt'] or  rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ProjectEditAssignedPrdMnt']) and bindings.AreaCode eq 'PRD-MNT'}");
    }

    public boolean isProjectEditPrdMntOnlyGlobal() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectEditPrdMnt'] and bindings.AreaCode eq 'PRD-MNT'}");
    }

    public boolean isProjectEditD2Prj() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectEditD2Prj'] and bindings.AreaCode eq 'D2-PRJ'}");
    }
    
    public boolean isProjectEditSAMD() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectEditSAMD'] and bindings.AreaCode eq 'SAMD'}");
    }

    public boolean isProjectEditD3Tr() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectEditD3Tr'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ProjectEditAssignedD3Tr']) and bindings.AreaCode eq 'D3-TR'}");
    }

    public boolean isProjectEditD3TrOnlyGlobal() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectEditD3Tr'] and bindings.AreaCode eq 'D3-TR'}");
    }

    public boolean isProjectEditRs() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectEditRs'] and bindings.AreaCode eq 'RS'}");
    }

    public boolean isProjectEditLg() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectEditLg'] and bindings.AreaCode eq 'LG'}");
    }

    public boolean isProjectEditCo() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectEditCo'] and bindings.AreaCode eq 'CO'}");
    }

    public boolean isProjectEditLo() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectEditLo'] and bindings.AreaCode eq 'LO'}");
    }

    // Edit project PMO comments

    public boolean isProjectCommentsPMODev() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectCommentsPMODev']  and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }

    public boolean isProjectCommentsPMOPrdMnt() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectCommentsPMOPrdMnt']  and (bindings.AreaCode eq 'PRD-MNT')}");
    }
    
    public boolean isProjectCommentsPMOD2Prj() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectCommentsPMOD2Prj']  and (bindings.AreaCode eq 'D2-PRJ')}");
    }
    
    public boolean isProjectCommentsPMOSAMD() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectCommentsPMOSAMD']  and (bindings.AreaCode eq 'SAMD')}");
    }

    // Deleting project

    public boolean isProjectDeleteDev() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectDeleteDev']  and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }

    public boolean isProjectDeleteD2Prj() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectDeleteD2Prj'] and bindings.AreaCode eq 'D2-PRJ'}");
    }
    
    public boolean isProjectDeleteSAMD() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectDeleteSAMD'] and bindings.AreaCode eq 'SAMD'}");
    }

    //Moving project

    public boolean isProjectMoveDev() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectMoveDev']  and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }

    public boolean isProjectRestoreD2Prj() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectRestoreD2Prj']  and bindings.AreaCode eq 'D2-PRJ'}");
    }
    
    public boolean isProjectRestoreSAMD() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectRestoreSAMD']  and bindings.AreaCode eq 'SAMD'}");
    }

    //Typify project

    public boolean isProjectTypified() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectTypify']  and (bindings.AreaCode ne 'PRE-POT' and bindings.AreaCode ne 'POST-POT' and bindings.AreaCode ne 'D2-PRJ' and bindings.AreaCode ne 'SAMD')}");
    }

    // Releasing project

    public boolean isProjectReleaseDev() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectReleaseDev']  and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT' or bindings.AreaCode eq 'D2-PRJ' or bindings.AreaCode eq 'SAMD') and bindings.IsPidt.inputValue}");
    }

    public boolean isProjectReleaseD2Prj() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectReleaseD2Prj']  and bindings.AreaCode eq 'D2-PRJ' and bindings.IsPidt.inputValue}");
    }
    
    public boolean isProjectReleaseSAMD() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectReleaseSAMD']  and bindings.AreaCode eq 'SAMD' and bindings.IsPidt.inputValue}");
    }

    //Identifying project

    public boolean isProjectIdentifyDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectIdentifyDev'] or  rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ProjectIdentifyAssignedDev']) and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }
    
    public boolean isProjectCreateSamdDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['projectCreateSamdDev']) and (bindings.AreaCode eq 'SAMD')}");
    }

    //Import

    public boolean isImportRunDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ImportRunDev'] or  rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ImportRunAssignedDev']) and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }

    public boolean isImportRunFpsDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ImportRunFpsDev'] or  rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ImportRunFpsAssignedDev']) and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }

    public boolean isImportRunFpsD3Tr() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ImportRunFpsD3Tr'] and bindings.AreaCode eq 'D3-TR'}");
    }

    public boolean isImportRunPrdMnt() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ImportRunPrdMnt'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ImportRunAssignedPrdMnt']) and bindings.AreaCode eq 'PRD-MNT'}");
    }

    public boolean isImportRunD2Prj() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ImportRunD2Prj'] and bindings.AreaCode eq 'D2-PRJ'}");
    }

    public boolean isImportRunFpsD2Prj() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ImportRunFpsD2Prj'] and bindings.AreaCode eq 'D2-PRJ'}");
    }
    
    public boolean isImportRunSAMD() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ImportRunSAMD'] and bindings.AreaCode eq 'SAMD'}");
    }

    public boolean isImportRunFpsSAMD() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ImportRunFpsSAMD'] and bindings.AreaCode eq 'SAMD'}");
    }

    public boolean isImportRunD3Tr() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ImportRunD3Tr'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ImportRunAssignedD3Tr']) and bindings.AreaCode eq 'D3-TR'}");
    }

    public boolean isImportRunConfigureDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ImportRunConfigureDev'] or  rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ImportRunConfigureAssignedDev']) and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }

    // Forecasting

    public boolean isProjectForecastDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectForecastDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ProjectForecastAssignedDev']) and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }

    public boolean isProjectForecastPrdMnt() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectForecastPrdMnt'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ProjectForecastAssignedPrdMnt']) and  bindings.AreaCode eq 'PRD-MNT'}");
    }

    public boolean isProjectForecastD3Tr() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectForecastD3Tr'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ProjectForecastAssignedD3Tr']) and  bindings.AreaCode eq 'D3-TR'}");
    }

    public boolean isProjectForecastD2Prj() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectForecastD2Prj'] and  bindings.AreaCode eq 'D2-PRJ'}");
    }
    
    public boolean isProjectForecastSAMD() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectForecastSAMD'] and  bindings.AreaCode eq 'SAMD'}");
    }

    //Integration

    public boolean isMaintainIntegration() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['MaintainIntegration'] and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT' or bindings.AreaCode eq 'D2-PRJ' or bindings.AreaCode eq 'SAMD' or bindings.AreaCode eq 'D3-TR' or bindings.AreaCode eq 'PRD-MNT')}");
    }

    public boolean isLoggedChangesView() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['LoggedChangesView']}");
    }

    //Program edit

    public boolean isProgramEditDev() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProgramEditDev'] and  pageFlowScope.projectType eq 'Dev'}");
    }

    public boolean isProgramDeleteDev() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProgramDeleteDev'] and  pageFlowScope.projectType eq 'Dev'}");
    }

    public boolean isProgramDeletePrdMnt() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProgramDeletePrdMnt'] and  pageFlowScope.projectType eq 'PrdMnt'}");
    }

    public boolean isProgramTeamDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProgramTeamDev'] or rolesBean.programRoles[bindings.ProgramViewIterator.currentRow]['ProgramTeamAssignedDev']) and  pageFlowScope.projectType eq 'Dev'}");
    }

    public boolean isProgramTeamPrdMnt() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProgramTeamPrdMnt'] or rolesBean.programRoles[bindings.ProgramViewIterator.currentRow]['ProgramTeamAssignedPrdMnt']) and  pageFlowScope.projectType eq 'PrdMnt'}");
    }

    public boolean isProgramTeamD2Prj() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProgramTeamD2Prj'] and  pageFlowScope.projectType eq 'D2Prj'}");
    }
    
    public boolean isProgramTeamSAMD() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProgramTeamSAMD'] and  pageFlowScope.projectType eq 'SAMD'}");
    }

    public boolean isProgramRolesPrdMnt() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProgramRolesPrdMnt'] or rolesBean.programRoles[bindings.ProgramViewIterator.currentRow]['ProgramRolesAssignedPrdMnt']) and  pageFlowScope.projectType eq 'PrdMnt'}");
    }

    public boolean isProgramRolesDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProgramRolesDev'] or rolesBean.programRoles[bindings.ProgramViewIterator.currentRow]['ProgramRolesAssignedDev']) and  pageFlowScope.projectType eq 'Dev'}");
    }

    public boolean isProjectRolesD3Tr() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectRolesD3Tr'] or rolesBean.programRoles[bindings.ProgramViewIterator.currentRow]['ProjectRolesAssignedD3Tr']) and  pageFlowScope.projectType eq 'D3Tr'}");
    }

    public boolean isProgramMaintainIntegration() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['MaintainIntegration'] and (pageFlowScope.projectType eq 'Dev' or pageFlowScope.projectType eq 'PrdMnt')}");
    }

    public boolean isProjectCreateDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectCreateDev'] or rolesBean.programRoles[bindings.ProgramViewIterator.currentRow]['ProjectCreateAssignedDev']) and  pageFlowScope.projectType eq 'Dev'}");
    }

    public boolean isProjectLeadDev() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectLeadDev'] and  pageFlowScope.projectType eq 'Dev'}");
    }

    //Project timeline 

    public boolean isTimelinePublishDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['TimelinePublishDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['TimelinePublishAssignedDev']) and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }

    public boolean isTimelinePublishPrdMnt() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['TimelinePublishPrdMnt'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['TimelinePublishAssignedPrdMnt']) and bindings.AreaCode eq 'PRD-MNT'}");
    }

    public boolean isTimelinePublishD2Prj() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['TimelinePublishD2Prj'] and bindings.AreaCode eq 'D2-PRJ'}");
    }
    
    public boolean isTimelinePublishSAMD() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['TimelinePublishSAMD'] and bindings.AreaCode eq 'SAMD'}");
    }

    public boolean isTimelinePublishD3Tr() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['TimelinePublishD3Tr'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['TimelinePublishAssignedD3Tr']) and bindings.AreaCode eq 'D3-TR'}");
    }

    public boolean isProjectPublishAll() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['ProjectPublishDev'] or securityContext.userInRole['ProjectPublishPrdMnt'] or securityContext.userInRole['ProjectPublishD3Tr'] or securityContext.userInRole['ProjectPublishD2Prj'] or securityContext.userInRole['ProjectPublishSAMD'] or securityContext.userInRole['ProjectPublishRs'] or securityContext.userInRole['ProjectPublishLg'] or securityContext.userInRole['ProjectPublishLo'] or securityContext.userInRole['ProjectPublishCo']}");
    }

    //Program Sandbox

    public boolean isSandboxPlanCreateDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['SandboxPlanCreateDev'] or rolesBean.programRoles[bindings.ProgramViewIterator.currentRow]['SandboxPlanCreateAssignedDev']) and  pageFlowScope.projectType eq 'Dev'}");
    }
    
    public boolean isSandboxPlanViewDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['SandboxPlanViewDev'] or rolesBean.programRoles[bindings.ProgramViewIterator.currentRow]['SandboxPlanViewAssignedDev']) and  pageFlowScope.projectType eq 'Dev'}");
    }

    public boolean isSandboxPlanModifyDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['SandboxPlanModifyDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['SandboxPlanModifyAssignedDev']) and  pageFlowScope.projectType eq 'Dev'}");
    }

    public boolean isSandboxPlanDeleteDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['SandboxPlanDeleteDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['SandboxPlanDeleteAssignedDev']) and  pageFlowScope.projectType eq 'Dev'}");
    }

    public boolean isSandboxPlanIntegrateDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['SandboxPlanIntegrateDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['SandboxPlanIntegrateAssignedDev']) and  pageFlowScope.projectType eq 'Dev'}");
    }
    
    public boolean isSandboxPlanImportPlanDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['SandboxPlanImportPlanDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['SandboxPlanImportPlanAssignedDev']) and  pageFlowScope.projectType eq 'Dev'}");
    }
    
    public boolean isSandboxPlanImportActualsDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['SandboxPlanImportActualsDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['SandboxPlanImportActualsAssignedDev']) and  pageFlowScope.projectType eq 'Dev'}");
    }

    //Long-term cost planning

    public boolean isProvideLtcDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['LongTermCostPlanningProvideDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['LongTermCostPlanningProvideAssignedDev']) and (pageFlowScope.projectType eq 'Dev' or bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }

    //Program goals

    public boolean isGoalsCreateDev() {
        return (Boolean) ViewUtils.runValueEl("#{(securityContext.userInRole['GoalsCreateDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['GoalsCreateAssignedDev'])}");
    }

    public boolean isTOPEditDevGlobal() {
        return (Boolean) ViewUtils.runValueEl("#{(securityContext.userInRole['TOPEditDev'])}");
    }

    public boolean isMaintainGoalsPhase() {
        return (Boolean) ViewUtils.runValueEl("#{(securityContext.userInRole['MaintainGoalsPhase']) }");
    }

    public boolean isGoalsEditDev() {
        return (Boolean) ViewUtils.runValueEl("#{(securityContext.userInRole['GoalsEditDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['GoalsEditAssignedDev'])}");
    }

    public boolean isGoalsViewDev() {
        return (Boolean) ViewUtils.runValueEl("#{(securityContext.userInRole['GoalsViewDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['GoalsViewAssignedDev'])}");
    }
    
    public boolean isProgramTOPViewDev() {
        return (Boolean) ViewUtils.runValueEl("#{(securityContext.userInRole['TOPViewDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['TOPViewAssignedDev'])}");
    }
    
    public boolean isGoalsDeleteDev() {
        return (Boolean) ViewUtils.runValueEl("#{securityContext.userInRole['GoalsDeleteDev']}");
    }
    
    //Project Target Product Profile (TPP)
    public boolean isTPPViewDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['TPPViewDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['TPPViewAssignedDev']) and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }

    public boolean isTPPEditDevGlobal() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['TPPEditDev'] and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }

    public boolean isTPPEditDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['TPPEditDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['TPPEditAssignedDev']) and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }

    // Program TOP
    public boolean isTOPEditDev() {
        return (Boolean) ViewUtils.runValueEl("#{(securityContext.userInRole['TOPEditDev'] or rolesBean.programRoles[bindings.ProgramViewIterator.currentRow]['TOPEditAssignedDev']) and pageFlowScope.projectType eq 'Dev'}");
    }

    public boolean isTOPEditD2Prj() {
        return (Boolean) ViewUtils.runValueEl("#{(securityContext.userInRole['TOPEditD2Prj'] or rolesBean.programRoles[bindings.ProgramViewIterator.currentRow]['TOPEditAssignedD2Prj']) and pageFlowScope.projectType eq 'D2Prj'}");
    }

    //View program Target Opportunity Profile (TOP) on a DEV project
    public boolean isTOPViewDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['TOPViewDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['TOPViewAssignedDev']) and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }

    public boolean isTOPViewD2Prj() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['TOPViewD2Prj'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['TOPViewAssignedD2Prj']) and (bindings.AreaCode eq 'D2-PRJ')}");
    }
    
   // GDD Reporting
    
    public boolean isProjectViewD1() {
        return (Boolean) ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectViewD1']) }");
    }

    public boolean isProjectImportD1() {
        return (Boolean) ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectImportD1']) }");
    }

    public boolean isProjectEditD1() {
        return (Boolean) ViewUtils.runValueEl("#{(securityContext.userInRole['ProjectEditD1']) }");
    }

    public boolean isMaintainGoalFactors() {
        return (Boolean) ViewUtils.runValueEl("#{(securityContext.userInRole['MaintainGoalFactors']) }");
    }
    
    //Project discrepancies
    
    public boolean isDiscrepancyViewDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['DiscrepancyViewDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['DiscrepancyViewAssignedDev']) and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }
    
    // Project Import Missing Studies
    public boolean isImportMissingStudies() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ImportStudyDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ImportStudyAssignedDev']) and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }
    
    // Project Maintain Baselines
    public boolean isMaintainBaselinesDev() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['MaintainBaselinesDev'] and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
    }
  
	 // Project Maintain Lead Studies
	 public boolean isMaintainLeadStudiesDev() {
	   return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['MaintainLeadStudyDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['MaintainLeadStudyAssignedDev']) and (bindings.AreaCode eq 'PRE-POT' or bindings.AreaCode eq 'POST-POT')}");
	 }
    
    public boolean isMaintainBaselinesPrdMnt() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['MaintainBaselinesPrdMnt'] and pageFlowScope.projectType eq 'PrdMnt'}");
    }
    
    public boolean isMaintainBaselinesD3Tr() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['MaintainBaselinesD3Tr'] and bindings.AreaCode eq 'D3-TR'}");
    }
    
    public boolean isMaintainBaselinesD2Prj() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['MaintainBaselinesD2Prj'] and bindings.AreaCode eq 'D2-PRJ'}");
    }
    
    public boolean isMaintainBaselinesSAMD() {
        return (Boolean)ViewUtils.runValueEl("#{securityContext.userInRole['MaintainBaselinesSAMD'] and bindings.AreaCode eq 'SAMD'}");
    }
    
    public boolean isMaintainBaselines() {
        return isMaintainBaselinesDev() || isMaintainBaselinesPrdMnt() || isMaintainBaselinesD3Tr() || isMaintainBaselinesD2Prj() || isMaintainBaselinesSAMD();
    }
    
    public boolean isActivityBasedPlanningViewDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ActivityBasedPlanningViewDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ActivityBasedPlanningViewAssignedDev']) and  pageFlowScope.projectType eq 'Dev'}");
    }
    
    public boolean isActivityBasedPlanningMaintainMapingDev() {
        return (Boolean)ViewUtils.runValueEl("#{(securityContext.userInRole['ActivityBasedPlanningMaintainMappingDev'] or rolesBean.projectRoles[bindings.ProjectViewIterator.currentRow]['ActivityBasedPlanningMaintainMappingAssignedDev']) and  pageFlowScope.projectType eq 'Dev'}");
    }
}
