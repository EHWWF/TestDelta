package com.bayer.ipms.view.utils;


import com.bayer.ipms.model.services.PrivateAppModuleImpl;
import com.bayer.ipms.model.services.common.PrivateAppModule;

import java.io.IOException;

import java.sql.SQLException;
import java.sql.Timestamp;

import java.text.MessageFormat;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.ResourceBundle;

import javax.el.ELContext;
import javax.el.ExpressionFactory;
import javax.el.MethodExpression;
import javax.el.ValueExpression;

import javax.faces.application.FacesMessage;
import javax.faces.application.NavigationHandler;
import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionListener;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import oracle.adf.controller.ControllerContext;
import oracle.adf.controller.TaskFlowContext;
import oracle.adf.controller.TaskFlowTrainModel;
import oracle.adf.controller.TaskFlowTrainStopModel;
import oracle.adf.controller.ViewPortContext;
import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCControlBinding;
import oracle.adf.model.binding.DCDataControl;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.model.events.EventDispatcher;
import oracle.adf.share.logging.ADFLogger;
import oracle.adf.view.rich.component.rich.data.RichTree;
import oracle.adf.view.rich.component.rich.data.RichTreeTable;
import oracle.adf.view.rich.context.AdfFacesContext;

import oracle.binding.AttributeBinding;
import oracle.binding.BindingContainer;
import oracle.binding.OperationBinding;

import oracle.jbo.ApplicationModule;
import oracle.jbo.JboWarning;
import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.RowIterator;
import oracle.jbo.ViewObject;
import oracle.jbo.uicli.binding.JUCtrlHierBinding;
import oracle.jbo.uicli.binding.JUCtrlHierNodeBinding;
import oracle.jbo.uicli.binding.JUEventBinding;

import org.apache.myfaces.trinidad.model.CollectionModel;
import org.apache.myfaces.trinidad.model.RowKeySet;
import org.apache.myfaces.trinidad.model.RowKeySetImpl;
import org.apache.myfaces.trinidad.render.ExtendedRenderKitService;
import org.apache.myfaces.trinidad.util.Service;


public final class ViewUtils {
    private static final ADFLogger logger = ADFLogger.createADFLogger(ViewUtils.class);

    private ViewUtils() {
    }

    public static Object runMethodEl(String el) {
        return runMethodEl(el, new Class<?>[0], new Object[0]);
    }

    public static void runJavaScript(String script) {
        FacesContext fctx = FacesContext.getCurrentInstance();
        ExtendedRenderKitService erks = Service.getRenderKitService(fctx, ExtendedRenderKitService.class);
        erks.addScript(fctx, script);
    }

    public static Object runMethodEl(String el, Class[] paramTypes, Object[] params) {
        FacesContext facesContext = FacesContext.getCurrentInstance();
        ELContext elContext = facesContext.getELContext();
        ExpressionFactory elFactory = facesContext.getApplication().getExpressionFactory();
        MethodExpression exp = elFactory.createMethodExpression(elContext, el, Object.class, paramTypes);
        return exp.invoke(elContext, params);
    }

    public static Object runValueEl(String el) {
        FacesContext facesContext = FacesContext.getCurrentInstance();
        ELContext elContext = facesContext.getELContext();
        ExpressionFactory elFactory = facesContext.getApplication().getExpressionFactory();
        ValueExpression exp = elFactory.createValueExpression(elContext, el, Object.class);
        return exp.getValue(elContext);
    }

    public static DCDataControl getDataControl(String name) {
        FacesContext fctx = FacesContext.getCurrentInstance();
        BindingContext bindingContext = BindingContext.getCurrent();
        return bindingContext.findDataControl(name);
    }

    public static DCIteratorBinding getIteratorBinding(String name) {
        return (DCIteratorBinding) BindingContext.getCurrent().getCurrentBindingsEntry().get(name);
    }

    public static <T> T getCurrentRow(String iterator) {
        return (T) getIteratorBinding(iterator).getCurrentRow();
    }

    public static void executeIterators(String... iterators) {
        for (String iterator : iterators) {
            getIteratorBinding(iterator).executeQuery();
        }
    }

    public static DCControlBinding getControlBinding(String name) {
        return (DCControlBinding) BindingContext.getCurrent().getCurrentBindingsEntry().getControlBinding(name);
    }

    public static UIComponent getUiComponent(String name) {
        FacesContext facesCtx = FacesContext.getCurrentInstance();
        return findUiComponent(facesCtx.getViewRoot(), name);
    }

    public static OperationBinding getOperationBinding(String operation) {
        BindingContainer bindingContainer = BindingContext.getCurrent().getCurrentBindingsEntry();
        return bindingContainer.getOperationBinding(operation);
    }

    public static void runOperation(String operation) {
        getOperationBinding(operation).execute();
    }

    public static void reloadUiComponent(String... names) {
        for (String name : names) {
            AdfFacesContext.getCurrentInstance().addPartialTarget(getUiComponent(name));
        }
    }

    private static UIComponent findUiComponent(UIComponent base, String id) {
        if (id.equals(base.getId())) {
            return base;
        }

        Iterator<?> childrens = base.getFacetsAndChildren();
        while (childrens.hasNext()) {
            UIComponent children = (UIComponent) childrens.next();
            UIComponent result = findUiComponent(children, id);
            if (result != null) {
                return result;
            }
        }

        return null;
    }


    public static BindingContainer getBindingContainer() {
        return BindingContext.getCurrent().getCurrentBindingsEntry();
    }

    public static AttributeBinding getAttributeBinding(String name) {
        BindingContainer bindingContainer = BindingContext.getCurrent().getCurrentBindingsEntry();
        return (AttributeBinding) bindingContainer.get(name);
    }

    public static Object getAttributeValue(String name) {
        return getAttributeBinding(name).getInputValue();
    }

    public void setAttributeValue(String name, Object value) {
        getAttributeBinding(name).setInputValue(value);
    }

    public static String getAttributeValueAsString(String name) {
        return (String) ViewUtils.getAttributeValue(name);
    }

    public static void addFacesMessage(FacesMessage.Severity severity, String summary, String details) {
        FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(severity, summary, details));
    }

    public static void addFacesMessage(Throwable exc) {
        addFacesMessage(FacesMessage.SEVERITY_ERROR, "Unexpected Error", getLocalizedError(exc));
    }

    public static String getLocalizedError(Throwable exception) {
        Timestamp timeStamp = new Timestamp((new java.util.Date()).getTime());
        ResourceBundle bundle = ResourceBundle.getBundle("com.bayer.ipms.view.bundles.viewBundle");

        if (exception instanceof SQLException) {
            SQLException sqlExc = (SQLException) exception;
            String key = MessageFormat.format("errorORA-{0,number,00000}", sqlExc.getErrorCode());

            return MessageFormat.format(bundle.getString(bundle.containsKey(key) ? key : "errorORA"),
                                        "ORA-" + sqlExc.getErrorCode(), timeStamp);
        } else if (exception.getCause() != null) {
            return getLocalizedError(exception.getCause());
        } else if (exception instanceof JboWarning) {
            JboWarning jboExc = (JboWarning) exception;
            String key = "error" + jboExc.getProductCode() + "-" + jboExc.getErrorCode();

            return MessageFormat.format(bundle.getString(bundle.containsKey(key) ? key : "errorJBO"),
                                        jboExc.getProductCode() + "-" + jboExc.getErrorCode(), timeStamp);
        } else {
            return exception.getLocalizedMessage() + " (" + timeStamp + ")";
        }
    }

    public static void sendForward(HttpServletRequest request, HttpServletResponse response, String forwardUrl) {
        FacesContext ctx = FacesContext.getCurrentInstance();
        RequestDispatcher dispatcher = request.getRequestDispatcher(forwardUrl);
        try {
            dispatcher.forward(request, response);
        } catch (ServletException se) {
            logger.severe("Could not forward to '" + forwardUrl + "'", se);
            ViewUtils.addFacesMessage(se);
        } catch (IOException ie) {
            logger.severe("Could not forward to '" + forwardUrl + "'", ie);
            addFacesMessage(ie);
        }
        ctx.responseComplete();
    }

    public static List<Row> getRows(RowIterator rows) {
        List<Row> all = new ArrayList<Row>();
        rows.reset();
        for (Row row = rows.first(); row != null; row = rows.next()) {
            all.add(row);
        }

        return all;
    }

    public static void discloseTree(RichTree tree) {
        if (tree.getRowCount() <= 0) {
            return;
        }

        tree.setRowIndex(tree.getFirst());

        JUCtrlHierNodeBinding firstNode = (JUCtrlHierNodeBinding) tree.getRowData();
        if (firstNode.getParent().getChildren() != null) {
            RowKeySet keySet = new RowKeySetImpl();
            for (Object member : firstNode.getParent().getChildren()) {
                JUCtrlHierNodeBinding node = (JUCtrlHierNodeBinding) member;
                keySet.add(Arrays.asList(node.getRow().getKey()));
            }
            tree.setDisclosedRowKeys(keySet);
        }
    }

    public static void closeTree(RichTree tree) {
        tree.getDisclosedRowKeys().clear();
    }

    public static void publishEvent(String event, Object payload) {
        JUEventBinding eventBinding = (JUEventBinding) ViewUtils.getBindingContainer().get(event);
        EventDispatcher eventDispatcher =
            ((DCBindingContainer) BindingContext.getCurrent().getCurrentBindingsEntry()).getEventDispatcher();
        eventDispatcher.queueEvent(eventBinding, payload);
    }

    public static void publishEvent(String event) {
        JUEventBinding eventBinding = (JUEventBinding) ViewUtils.getBindingContainer().get(event);
        ActionListener listener = (ActionListener) eventBinding.getListener();
        listener.processAction(null);
    }

    public static int getLookupCodeIndex(String lookupVOInstanceName, String code) {
        ApplicationModule sharedAppModule =
            (ApplicationModule) ViewUtils.getDataControl("SharedAppModuleDataControl").getDataProvider();
        ViewObject vo = sharedAppModule.findViewObject(lookupVOInstanceName);
        Row vr = vo.getRowSet().findByKey(new Key(new Object[] { code }), 1)[0];
        vo.setCurrentRow(vr);
        return vo.getCurrentRowIndex();
    }


    //    public static String getVOIndexCode(String dataControlName, String vOInstanceName,
    //                                            int ind, String returnAttrName){
    //
    //            ApplicationModule sharedAppModule =
    //                (ApplicationModule)ViewUtils.getDataControl(dataControlName).getDataProvider();
    //            ViewObject vo = sharedAppModule.findViewObject(vOInstanceName);
    //            int rs =vo.getRangeSize();
    //            vo.setRangeSize(-1);
    //            Row vr = vo.getRowSet().getRowAtRangeIndex(ind);
    //            vo.setRangeSize(rs);
    //            return (String)vr.getAttribute(returnAttrName);
    //        }

    public static String getLookupIndexCode(String lookupVOInstanceName, int ind) {
        ApplicationModule sharedAppModule =
            (ApplicationModule) ViewUtils.getDataControl("SharedAppModuleDataControl").getDataProvider();
        ViewObject vo = sharedAppModule.findViewObject(lookupVOInstanceName);
        Row vr = vo.getRowSet().getRowAtRangeIndex(ind);
        return (String) vr.getAttribute("Code");
    }
    
    public static String getManagementLookupIndexCode(String lookupVOInstanceName, int ind) {
        PrivateAppModuleImpl privateAppModule =
            (PrivateAppModuleImpl) ViewUtils.getDataControl("PrivateAppModuleDataControl").getDataProvider();

        ViewObject vo = privateAppModule.getManagementAppModule().findViewObject(lookupVOInstanceName);
        Row vr = vo.getRowSet().getRowAtRangeIndex(ind);
        return (String) vr.getAttribute("Code");
    }

    public static void collectAllNodes(JUCtrlHierNodeBinding nodeBinding, RowKeySetImpl disclosedKeys) {
        List<JUCtrlHierNodeBinding> childNodes = nodeBinding.getChildren();
        ArrayList newKeys = new ArrayList();

        if (childNodes != null) {
            for (JUCtrlHierNodeBinding _node : childNodes) {
                newKeys.add(_node.getKeyPath());
                collectAllNodes(_node, disclosedKeys);
            }
        }

        disclosedKeys.addAll(newKeys);
    }

    public static void discloseAllTreeTableNodes(String id) {

        RowKeySetImpl rowKeys = new RowKeySetImpl();
        RichTreeTable treeTable = (RichTreeTable) ViewUtils.getUiComponent(id);
        CollectionModel model = (CollectionModel) treeTable.getValue();

        if (model != null) {
            JUCtrlHierBinding treeBinding = (JUCtrlHierBinding) model.getWrappedData();
            JUCtrlHierNodeBinding nodeBinding = treeBinding.getRootNodeBinding();
            collectAllNodes(nodeBinding, rowKeys);
        }
        
        treeTable.setDisclosedRowKeys(rowKeys);
    }
	 
		 
	public static void handleNavigation(String outcome){
	    FacesContext context = FacesContext.getCurrentInstance();
	    NavigationHandler handler = context.getApplication().getNavigationHandler();
	    handler.handleNavigation(context, null, outcome);
	    context.renderResponse();
	  }
	
  public static String getCurrTrainActivityId()
  {

	 ControllerContext controlCtxt = ControllerContext.getInstance();
	 ViewPortContext viewPortCtxt = controlCtxt.getCurrentViewPort();
	 TaskFlowContext taskFlowCtxt = viewPortCtxt.getTaskFlowContext();
	 TaskFlowTrainModel trainModel = taskFlowCtxt.getTaskFlowTrainModel();
	 TaskFlowTrainStopModel currentStop = trainModel.getCurrentStop();

	 return currentStop.getLocalActivityId();

  }

}
