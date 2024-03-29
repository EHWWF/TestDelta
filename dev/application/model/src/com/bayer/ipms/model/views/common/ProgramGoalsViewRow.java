package com.bayer.ipms.model.views.common;

import java.sql.Date;

import oracle.jbo.Row;
import oracle.jbo.RowSet;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Sat Jun 27 21:11:32 EEST 2015
// ---------------------------------------------------------------------
public interface ProgramGoalsViewRow extends Row {
    void refresh();


    RowSet getGoalStatus();

    RowSet getGoalTypes();

    RowSet getProgramAppModule_GoalTypes();

    RowSet getProgramAppModule_GoalTypesLOV();

    RowSet getProgramAppModule_ProjectView1();

    RowSet getProjectView();

    Date getAchievedDate();

    String getCode();

    String getGoal1();

    Integer getId();

    String getPlanReference();


    String getProgramId();

    String getProjectId();

    Date getRevisedDate();

    String getStatus();

    String getStudyId();

    Date getTargetDate();

    String getType();

    void setAchievedDate(Date value);

    void setGoal1(String value);

    void setPlanReference(String value);

    void setProjectId(String value);

    void setRevisedDate(Date value);

    void setStatus(String value);

    void setStudyId(String value);

    void setTargetDate(Date value);

    void setType(String value);

    RowSet getProgramAppModule_ProgramGoalTargetYearView();
}

