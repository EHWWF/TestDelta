package com.bayer.ipms.model.services;

import com.bayer.ipms.model.base.IPMSApplicationModuleImpl;
import com.bayer.ipms.model.base.IPMSViewObjectImpl;
import com.bayer.ipms.model.services.common.ReportAppModule;
import com.bayer.ipms.model.views.ProjectViewImpl;

import oracle.jbo.server.ViewLinkImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Sep 18 18:51:16 EEST 2015
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ReportAppModuleImpl extends IPMSApplicationModuleImpl implements ReportAppModule {
    /**
     * This is the default constructor (do not remove).
     */
    public ReportAppModuleImpl() {
    }

    /**
     * Container's getter for ProjectView.
     * @return ProjectView
     */
    public ProjectViewImpl getProjectView() {
        return (ProjectViewImpl) findViewObject("ProjectView");
    }

    /**
     * Container's getter for TimelineView.
     * @return TimelineView
     */
    public IPMSViewObjectImpl getTimelineView() {
        return (IPMSViewObjectImpl) findViewObject("TimelineView");
    }

    /**
     * Container's getter for LogView.
     * @return LogView
     */
    public IPMSViewObjectImpl getLogView() {
        return (IPMSViewObjectImpl) findViewObject("LogView");
    }

    /**
     * Container's getter for TraceView.
     * @return TraceView
     */
    public IPMSViewObjectImpl getTraceView() {
        return (IPMSViewObjectImpl) findViewObject("TraceView");
    }

    /**
     * Container's getter for NoticeView.
     * @return NoticeView
     */
    public IPMSViewObjectImpl getNoticeView() {
        return (IPMSViewObjectImpl) findViewObject("NoticeView");
    }

    /**
     * Container's getter for FPSLogView.
     * @return FPSLogView
     */
    public IPMSViewObjectImpl getFPSLogView() {
        return (IPMSViewObjectImpl) findViewObject("FPSLogView");
    }

    /**
     * Container's getter for ProjectTimelines.
     * @return ProjectTimelines
     */
    public ViewLinkImpl getProjectTimelines() {
        return (ViewLinkImpl) findViewLink("ProjectTimelines");
    }

    public String getName() {
        return super.getName();
    }

    /**
     * Container's getter for GlobalBALogView1.
     * @return GlobalBALogView1
     */
    public IPMSViewObjectImpl getGlobalBALogView() {
        return (IPMSViewObjectImpl) findViewObject("GlobalBALogView");
    }
}
