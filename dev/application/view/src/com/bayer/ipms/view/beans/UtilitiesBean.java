package com.bayer.ipms.view.beans;


import com.bayer.ipms.model.base.IPMSLookupViewRow;
import com.bayer.ipms.model.services.common.PrivateAppModule;
import com.bayer.ipms.model.views.ProjectViewRowImpl;
import com.bayer.ipms.model.views.RoleViewImpl;
import com.bayer.ipms.model.views.RoleViewRowImpl;
import com.bayer.ipms.model.views.UserViewImpl;
import com.bayer.ipms.model.views.common.ProjectViewRow;
import com.bayer.ipms.model.views.lookups.StrategicBusinessEntityViewRowImpl;
import com.bayer.ipms.view.base.IPMSBean;
import com.bayer.ipms.view.utils.ViewUtils;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import java.math.BigDecimal;

import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.MissingResourceException;
import java.util.ResourceBundle;
import java.util.UUID;

import javax.el.ELContext;
import javax.el.ExpressionFactory;
import javax.el.ValueExpression;

import javax.faces.application.FacesMessage;
import javax.faces.component.UIComponent;
import javax.faces.component.UIViewRoot;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCDataControl;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.share.ADFContext;
import oracle.adf.view.faces.bi.component.pivotTable.UIPivotTable;
import oracle.adf.view.faces.bi.model.PivotTableModel;
import oracle.adf.view.rich.component.rich.data.RichColumn;
import oracle.adf.view.rich.component.rich.data.RichTable;
import oracle.adf.view.rich.component.rich.nav.RichCommandLink;
import oracle.adf.view.rich.component.rich.nav.RichGoLink;

import oracle.dss.util.BIBaseException;
import oracle.dss.util.DataAccess;

import oracle.javatools.resourcebundle.BundleFactory;

import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.RowIterator;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewObject;
import oracle.jbo.uicli.binding.JUCtrlHierBinding;
import oracle.jbo.uicli.binding.JUCtrlHierNodeBinding;

import org.apache.commons.lang.StringUtils;
import org.apache.myfaces.trinidad.component.UIXIterator;
import org.apache.myfaces.trinidad.component.UIXValue;
import org.apache.myfaces.trinidad.event.SelectionEvent;
import org.apache.myfaces.trinidad.model.CollectionModel;
import org.apache.myfaces.trinidad.model.RowKeySet;


/**
 * General application level utilities.
 */
public class UtilitiesBean extends IPMSBean {

    private static final Map<String, Integer> rowCountMap = Collections.unmodifiableMap(new HashMap<String, Integer>() {
        @Override
        public Integer get(Object key) {
            return (key != null ? key.toString().split("\\r\\n|\\n\\r|\\n|\\r").length : 1);
        }
    });

    private static final Map<RowIterator, List<SelectItem>> lookupMap =
        Collections.unmodifiableMap(new HashMap<RowIterator, List<SelectItem>>() {
            @Override
            public List<SelectItem> get(Object key) {
                List<SelectItem> all = new ArrayList<SelectItem>();

                RowIterator rows = (RowIterator) key;
                rows.reset();
                for (Row row = rows.first(); row != null; row = rows.next()) {
                    IPMSLookupViewRow lookup = (IPMSLookupViewRow) row;
                    all.add(new SelectItem(lookup.getCode(),
                                           (lookup.getName().length() > 100 ?
                                            lookup.getName().substring(0, 96).concat("...") : lookup.getName()),
                                           lookup.toString(), !lookup.isActive()));
                }

                return all;
            }
        });

    private static final Map<RowIterator, List<SelectItem>> lookupMapName =
        Collections.unmodifiableMap(new HashMap<RowIterator, List<SelectItem>>() {
            @Override
            public List<SelectItem> get(Object key) {
                List<SelectItem> all = new ArrayList<SelectItem>();

                RowIterator rows = (RowIterator) key;
                rows.reset();
                for (Row row = rows.first(); row != null; row = rows.next()) {
                    IPMSLookupViewRow lookup = (IPMSLookupViewRow) row;
                    all.add(new SelectItem(lookup.getName(),
                                           (lookup.getName().length() > 100 ?
                                            lookup.getName().substring(0, 96).concat("...") : lookup.getName()),
                                           lookup.toString(), !lookup.isActive()));
                }

                return all;
            }
        });

    private static final Map<RowIterator, List<SelectItem>> lookupSBEMap =
        Collections.unmodifiableMap(new HashMap<RowIterator, List<SelectItem>>() {
            @Override
            public List<SelectItem> get(Object key) {
                List<SelectItem> all = new ArrayList<SelectItem>();

                RowIterator rows = (RowIterator) key;
                rows.reset();
                for (Row row = rows.first(); row != null; row = rows.next()) {
                    StrategicBusinessEntityViewRowImpl lookup = (StrategicBusinessEntityViewRowImpl) row;
                    all.add(new SelectItem(lookup.getCode(),
                                           (lookup.getName().length() > 100 ?
                                            lookup.getName().substring(0, 96).concat("...") : lookup.getName()),
                                           lookup.toString(), !lookup.getIsVisible()));
                }

                return all;
            }
        });


    private static final Map<RowIterator, List<SelectItem>> projectMap =
        Collections.unmodifiableMap(new HashMap<RowIterator, List<SelectItem>>() {
            @Override
            public List<SelectItem> get(Object key) {
                List<SelectItem> all = new ArrayList<SelectItem>();

                RowIterator rows = (RowIterator) key;
                rows.reset();
                for (Row row = rows.first(); row != null; row = rows.next()) {
                    ProjectViewRow lookup = (ProjectViewRow) row;
                    all.add(new SelectItem(lookup.getId(), lookup.getName(), lookup.toString(), false));
                }

                return all;
            }
        });

    private static final Map<RowIterator, List<SelectItem>> allProjectMap =
        Collections.unmodifiableMap(new HashMap<RowIterator, List<SelectItem>>() {
            @Override
            public List<SelectItem> get(Object key) {
                List<SelectItem> all = new ArrayList<SelectItem>();

                RowIterator rows = (RowIterator) key;
                rows.reset();
                for (Row row = rows.first(); row != null; row = rows.next()) {
                    ProjectViewRowImpl lookup = (ProjectViewRowImpl) row;
                    all.add(new SelectItem(lookup.getId(), lookup.getName(), lookup.toString(),
                                           Boolean.FALSE.equals(lookup.getIsActive())));
                }

                return all;
            }
        });


    private static final Map<RowIterator, List<SelectItem>> lookupMapQualified =
        Collections.unmodifiableMap(new HashMap<RowIterator, List<SelectItem>>() {
            @Override
            public List<SelectItem> get(Object key) {
                List<SelectItem> all = new ArrayList<SelectItem>();
                String value;

                RowIterator rows = (RowIterator) key;
                rows.reset();
                for (Row row = rows.first(); row != null; row = rows.next()) {
                    IPMSLookupViewRow lookup = (IPMSLookupViewRow) row;

                    value =
                        lookup.getName().length() > 100 ? lookup.getName().substring(0, 96).concat("...") :
                        lookup.getName();
                    value = value + " (" + lookup.getCode() + ")";

                    all.add(new SelectItem(lookup.getCode(), value, lookup.toString(), !lookup.isActive()));
                }

                return all;
            }
        });

    private static final Map<RowIterator, Row> currentRowMap =
        Collections.unmodifiableMap(new HashMap<RowIterator, Row>() {
            @Override
            public Row get(Object key) {
                RowIterator it = (RowIterator) key;

                if (it.getCurrentRow() == null) {
                    it.first();
                }

                return it.getCurrentRow();
            }
        });

    private static final Map<RowIterator, List<Row>> allRowsMap =
        Collections.unmodifiableMap(new HashMap<RowIterator, List<Row>>() {
            @Override
            public List<Row> get(Object key) {
                return ViewUtils.getRows((RowIterator) key);
            }
        });


    public Map<RowIterator, List<SelectItem>> getAllUsersLookup() {
        return allUsersMap;
    }

    public static final Map<String, String> projectAreaCodeId;

    private static final String LINEBREAK = "\n";

    private static final String NEXTCELL = "\t";

    static {
        projectAreaCodeId = new HashMap<String, String>();

        projectAreaCodeId.put("PRE-POT", "Dev");
        projectAreaCodeId.put("POST-POT", "Dev");
        projectAreaCodeId.put("PRD-MNT", "PrdMnt");
        projectAreaCodeId.put("D1", "D1");
        projectAreaCodeId.put("D2-PRJ", "D2Prj");
        projectAreaCodeId.put("D3-TR", "D3Tr");
        projectAreaCodeId.put("RS", "Rs");
        projectAreaCodeId.put("LG", "Lg");
        projectAreaCodeId.put("LO", "Lo");
        projectAreaCodeId.put("CO", "Co");
        projectAreaCodeId.put("SAMD", "SAMD");
    }

    public UtilitiesBean() {
        super();
    }

    public Map<String, Integer> getRowCount() {
        return rowCountMap;
    }

    public Map<RowIterator, List<SelectItem>> getLookupAll() {
        return lookupMapAll;
    }

    public Map<RowIterator, List<SelectItem>> getLookup() {
        return lookupMap;
    }

    public Map<RowIterator, List<SelectItem>> getLookupName() {
        return lookupMapName;
    }

    public Map<RowIterator, List<SelectItem>> getLookupSBE() {
        return lookupSBEMap;
    }

    public Map<RowIterator, List<SelectItem>> getProjectLookup() {
        return projectMap;
    }

    public Map<RowIterator, List<SelectItem>> getAllProjectLookup() {
        return allProjectMap;
    }

    public Map<RowIterator, List<SelectItem>> getLookupQualified() {
        return lookupMapQualified;
    }

    public Map<RowIterator, Row> getCurrentRow() {
        return currentRowMap;
    }

    public Map<RowIterator, List<Row>> getAllRows() {
        return allRowsMap;
    }

    public void onValChange(ValueChangeEvent vce) {
        UIComponent comp = vce.getComponent();
        comp.processUpdates(FacesContext.getCurrentInstance());
    }

    public void onValueChange(ValueChangeEvent vce) {
        vce.getComponent().processUpdates(FacesContext.getCurrentInstance());
        FacesContext.getCurrentInstance().renderResponse();
    }

    public void onDelete(ActionEvent event) {
        // Take target table
        RichTable table =
            (RichTable) ViewUtils.getUiComponent((String) event.getComponent().getAttributes().get("table"));
        RowKeySet keySet = table.getSelectedRowKeys();

        // Take target iterator
        DCIteratorBinding iterator = (DCIteratorBinding) event.getComponent().getAttributes().get("iterator");
        RowSetIterator rowSetIterator = iterator.getRowSetIterator();

        // loop through selected rows
        for (Iterator it = keySet.iterator(); it.hasNext();) {
            List<Key> keys = (List<Key>) it.next();
            // Check if the selected row exists...
            if (rowSetIterator.getRow(keys.get(0)) == null)
                continue;

            if (!isDeleteAllowed(rowSetIterator.getRow(keys.get(0)))) {
                ViewUtils.addFacesMessage(FacesMessage.SEVERITY_ERROR, "Error",
                                          ResourceBundle.getBundle("com.bayer.ipms.view.bundles.viewBundle").getString("errorRemovingSelectedValueForbidden"));
                continue;
            }

            iterator.removeRowWithKey(keys.get(0).toStringFormat(true));
        }
    }

    private static final Map<RowIterator, List<SelectItem>> allUsersMap =
        Collections.unmodifiableMap(new HashMap<RowIterator, List<SelectItem>>() {
            @Override
            public List<SelectItem> get(Object key) {
                List<SelectItem> all = new ArrayList<SelectItem>();

                List<UserViewImpl.Usr> rows = (List<UserViewImpl.Usr>) key;
                Iterator it = rows.iterator();
                while (it.hasNext()) {
                    UserViewImpl.Usr lookup = (UserViewImpl.Usr) it.next();
                    String displayName = lookup.getName();

                    if (lookup.getDisplayName() != null) {
                        displayName = lookup.getDisplayName() + " (" + lookup.getName() + ")";
                    }
                    all.add(new SelectItem(lookup.getName(), displayName, displayName, false));
                }
                return all;
            }
        });


    private static final Map<RowIterator, List<SelectItem>> lookupMapAll =
        Collections.unmodifiableMap(new HashMap<RowIterator, List<SelectItem>>() {
            @Override
            public List<SelectItem> get(Object key) {
                List<SelectItem> all = new ArrayList<SelectItem>();

                RowIterator rows = (RowIterator) key;
                rows.reset();
                for (Row row = rows.first(); row != null; row = rows.next()) {
                    IPMSLookupViewRow lookup = (IPMSLookupViewRow) row;
                    all.add(new SelectItem(lookup.getCode(),
                                           (lookup.getName().length() > 100 ?
                                            lookup.getName().substring(0, 96).concat("...") : lookup.getName()),
                                           lookup.toString()));
                }

                return all;
            }
        });


    public boolean isDeleteAllowed(Row row) {
        if ("com.bayer.ipms.model.views.CostsProbabilitySpecificViewRowImpl".equals(row.getClass().getName())) {
            if (row.getAttribute("SbeCode") == null && row.getAttribute("SubstanceTypeCode") == null
                // Should allow deleting newly added rows which were never saved yet.
                && row.getAttribute("CreateDate") != null) {
                return false;
            }
        }
        return true;
    }

    public static void prefillProjectPredecessor(ProjectViewRow srcPrjRow, ProjectViewRow dstPrjRow) {
        dstPrjRow.setIpownerCode(srcPrjRow.getIpownerCode());
        dstPrjRow.setCategoryCode(srcPrjRow.getCategoryCode());
        dstPrjRow.setProposedSbeCode(srcPrjRow.getProposedSbeCode());
        dstPrjRow.setSubstanceTypeCode(srcPrjRow.getSubstanceTypeCode());
        dstPrjRow.setSourceCode(srcPrjRow.getSourceCode());
        dstPrjRow.setTargetGeneCode(srcPrjRow.getTargetGeneCode());
    }

    public void processExport(ActionEvent event) {

        FacesContext context = FacesContext.getCurrentInstance();
        BindingContext bindingContext = BindingContext.getCurrent();
        DCDataControl dc = bindingContext.findDataControl("PrivateAppModuleDataControl");
        PrivateAppModule appModule = (PrivateAppModule) dc.getDataProvider();
        appModule.runStatement("begin job_pkg.export; end;", true);
    }

    public Map<String, String> getElementLabel() {
        return new HashMap<String, String>() {
            // Get the model resource bundle
            ResourceBundle bundle = BundleFactory.getBundle("com.bayer.ipms.model.bundles.modelBundle");

            @Override
            public String get(Object key) {
                // Return the label from the model resource bundle for the given element.
                // If the corresponding label is not found, then just return the given element name.
                String label = (String) key;

                try {
                    return bundle.getString(label);
                } catch (MissingResourceException error) {
                    // do nothing
                }

                return label;
            }
        };
    }

    public Map<String, String> getBrFormattedString() {
        return new HashMap<String, String>() {
            @Override
            public String get(Object key) {
                String str = (String) key;
                str = str.replaceAll("(\\r|\\n|\\r\\n)+", "<br>");
                return str;
            }
        };

    }

    @SuppressWarnings("unchecked")
    public static void setBaCode(String code) {
        Map session = ADFContext.getCurrent().getSessionScope();

        session.put("baCode", code != null ? code : "");
        session.put("uuid", code != null ? UUID.randomUUID().toString() : "");
    }

    public void setBaCode2(String code) {
        setBaCode(code);
    }

    public void clearBaCode() {
        setBaCode(null);
    }

    public void exportToExcel(FacesContext facesContext, OutputStream os, Boolean mustHandleSuffixG) throws IOException,
                                                                                                            NoSuchMethodException,
                                                                                                            InvocationTargetException,
                                                                                                            IllegalAccessException {
        Map<String, Object> varDetails = ADFContext.getCurrent().getViewScope();
        String expId = (String) varDetails.get("exportId"); // export table id
        String thStyle = (String) varDetails.get("tableHeaderStyle"); // style class for <th>
        String tdStyle = (String) varDetails.get("tableDataStyle"); // style class for  <td>
        boolean showHiddenCols =
            "true".equals(varDetails.get("exporter.showHiddenColumns")); // define if hidden columns should be shown
        boolean forceColWidth = "true".equals(varDetails.get("exporter.forceColumnWidth")); // force width of columns

        // get the table from absoulte path
        UIViewRoot vr = facesContext.getViewRoot();
        RichTable table = (RichTable) ViewUtils.getUiComponent(expId);

        // get columns of table
        List<RichColumn> cols = new ArrayList<RichColumn>();
        for (UIComponent co : table.getChildren()) {
            if (co instanceof RichColumn) {
                RichColumn col = (RichColumn) co;
                // if showHiddenCols is true shows all columns, otherwise shows only rendered and visible columns
                if (showHiddenCols || (col.isRendered() && col.isVisible()))
                    cols.add(col);
            }
        }

        OutputStreamWriter expData = new OutputStreamWriter(os);
        expData.append("<html><head><meta charset=\"UTF-8\"></head><body>");
        expData.append("<table>");
        expData.append("<tr>");
        for (RichColumn col : cols) {
            // render <th> with style, align, width and nowrap attributes
            expData.append("<th");
            if (StringUtils.isNotEmpty(thStyle))
                expData.append(String.format(" style='%s'", thStyle));
            expData.append(String.format(" align='%s'", StringUtils.defaultString(col.getAlign(), "left")));
            if (forceColWidth && StringUtils.isNotEmpty(col.getWidth()))
                expData.append(String.format(" width='%s'", col.getWidth()));
            if (col.isHeaderNoWrap())
                expData.append(" nowrap");
            expData.append(">");
            expData.append(StringUtils.defaultString(col.getHeaderText()));
            expData.append("</th>");
        }
        expData.append("</tr>");

        ELContext elContext = facesContext.getELContext();
        ExpressionFactory expressionFactory = facesContext.getApplication().getExpressionFactory();
        if (StringUtils.isNotEmpty(table.getVarStatus())) {
            // create varStatusMap
            Method m = UIXIterator.class.getDeclaredMethod("createVarStatusMap", new Class[0]);
            m.setAccessible(true);
            Object varStatus = m.invoke(table, new Object[0]);
            String el = String.format("#{%s}", table.getVarStatus());
            ValueExpression exp = expressionFactory.createValueExpression(elContext, el, Object.class);
            exp.setValue(elContext, varStatus);
        }

        CollectionModel model = (CollectionModel) table.getValue();
        int rowcount = model.getRowCount();
        for (int i = 0; i < rowcount; i++) {
            model.setRowIndex(i);
            JUCtrlHierNodeBinding row = (JUCtrlHierNodeBinding) model.getRowData();
            if (StringUtils.isNotEmpty(table.getVar())) {
                String el = String.format("#{%s}", table.getVar());
                ValueExpression exp = expressionFactory.createValueExpression(elContext, el, Object.class);
                exp.setValue(elContext, row);
            }

            expData.append("<tr>");
            for (RichColumn col : cols) {
                // get value from some column attributes
                ValueExpression inlineStyleVE = col.getValueExpression("inlineStyle");
                ValueExpression alignVE = col.getValueExpression("align");
                String style =
                    inlineStyleVE == null ? "" : (String) inlineStyleVE.getValue(facesContext.getELContext());
                String align = alignVE == null ? "" : (String) alignVE.getValue(facesContext.getELContext());

                // render <td> with style, align, width and nowrap attributes
                expData.append("<td");
                if (StringUtils.isNotEmpty(tdStyle) || StringUtils.isNotEmpty(style))
                    expData.append(String.format(" style='%s;%s'", StringUtils.defaultString(tdStyle),
                                                 StringUtils.defaultString(style)));
                if (StringUtils.isNotEmpty(align))
                    expData.append(String.format(" align='%s'", align));
                if (forceColWidth && StringUtils.isNotEmpty(col.getWidth()))
                    expData.append(String.format(" width='%s'", col.getWidth()));
                if (col.isNoWrap())
                    expData.append(" nowrap");
                expData.append(">");

                DateFormat oldDateFormat = new SimpleDateFormat("dd-MMM-yyyy");
                String oldDateFormatRegexp = "([0-9]{2})-([a-zA-Z]{3})-([0-9]{4})( ([0-9]{2}):([0-9]{2}):([0-9]{2}))?";
                DateFormat newDateFormat = new SimpleDateFormat("dd.MM.yyyy");
                String suffixG = " G";

                // render the content of <td> using the value or text of its children (depending on the type of component)
                // note that you can add other UIComponent types and render using different criteria, and also you can convert value (Date, Double, etc)
                for (UIComponent co : col.getChildren()) {
                    if (co.isRendered()) {
                        if (co instanceof UIXValue) {
                            UIXValue uixValue = (UIXValue) co;
                            if (uixValue.getValue() != null) {
                                String value = uixValue.getValue().toString();
                                // if value 'seems like date' (checking format using oldDateFormatRegexp),
                                // then change date format to avoid bugs of switching between different regional settings (see CUC-350).
                                // Note: there can be multiple dates, separated by commas.
                                String oldValue = value;
                                String newValue = "";
                                try {
                                    String separator = "";
                                    for (String oldValueFragment : oldValue.split(", ")) {
                                        Boolean valueHadG = mustHandleSuffixG && oldValueFragment.endsWith(suffixG);
                                        if (valueHadG) {
                                            oldValueFragment =
                                                oldValueFragment.substring(0,
                                                                           oldValueFragment.length() -
                                                                           suffixG.length());
                                        }
                                        String newValueFragment = oldValueFragment;
                                        if (oldValueFragment.matches(oldDateFormatRegexp)) {
                                            newValueFragment =
                                                newDateFormat.format(oldDateFormat.parse(oldValueFragment));
                                        }
                                        if (valueHadG) {
                                            newValueFragment += suffixG;
                                        }

                                        newValue += separator + newValueFragment;
                                        separator = ", ";
                                    }
                                } catch (ParseException exc) {
                                    newValue = oldValue;
                                }

                                expData.append(newValue);
                            }
                        } else if (co instanceof RichCommandLink) {
                            RichCommandLink commandLink = (RichCommandLink) co;
                            if (commandLink.getText() != null)
                                expData.append(commandLink.getText());
                        } else if (co instanceof RichGoLink) {
                            RichGoLink goLink = (RichGoLink) co;
                            if (goLink.getText() != null)
                                expData.append(String.format("<a href='%s'>%s</a>", goLink.getDestination(),
                                                             goLink.getText()));
                        }
                    }
                }
                expData.append("</td>");
            }
            expData.append("</tr>");
        }
        expData.append("</table>");
        expData.append("</body></html>");
        expData.close();
    }

    public void exportToExcelWithSuffixG(FacesContext facesContext, OutputStream os) throws IOException,
                                                                                            NoSuchMethodException,
                                                                                            InvocationTargetException,
                                                                                            IllegalAccessException {
        exportToExcel(facesContext, os, true);
    }

    public void exportToExcelNoSuffixG(FacesContext facesContext, OutputStream os) throws IOException,
                                                                                          NoSuchMethodException,
                                                                                          InvocationTargetException,
                                                                                          IllegalAccessException {
        exportToExcel(facesContext, os, false);
    }


    private String htmlHCell(Object value, String style, int rowspan, int colspan) {
        if (rowspan < 1 || colspan < 1)
            return null;

        StringBuffer html = new StringBuffer();
        html.append("<th");
        if (StringUtils.isNotEmpty(style))
            html.append(String.format(" style='%s'", style));
        if (rowspan > 1)
            html.append(String.format(" rowspan='%d'", rowspan));
        if (colspan > 1)
            html.append(String.format(" colspan='%d'", colspan));
        html.append(">");

        if (value != null) {
            html.append(value.toString());
        } else {
            html.append("&nbsp;");
        }
        html.append("</th>");
        return html.toString();
    }

    private String htmlCell(Object value, String style, int rowspan) {
        StringBuffer html = new StringBuffer();

        if (value != null) {
            try {
                Long.parseLong(value.toString());
                style += ";mso-number-format:\"0\"";
            } catch (NumberFormatException nxInteger) {
                try {
                    Double.parseDouble(value.toString());
                    style += ";mso-number-format:\"0\\.00\"";
                } catch (NumberFormatException nxDouble) {

                }
            }
        }

        html.append("<td");
        if (StringUtils.isNotEmpty(style))
            html.append(String.format(" style='%s'", style));
        if (rowspan > 1)
            html.append(String.format(" rowspan='%d'", rowspan));
        html.append(">");

        if (value != null) {
            html.append(value.toString());
        } else {
            html.append("&nbsp;");
        }
        html.append("</td>");
        return html.toString();
    }


    public void exportToExcelPivot(FacesContext facesContext, OutputStream os) throws IOException,
                                                                                      NoSuchMethodException,
                                                                                      InvocationTargetException,
                                                                                      IllegalAccessException {
        Map<String, Object> varDetails = ADFContext.getCurrent().getViewScope();
        String expId = (String) varDetails.get("exportId"); // export table id
        String thStyle = (String) varDetails.get("tableHeaderStyle"); // style class for <th>
        String tdStyle = (String) varDetails.get("tableDataStyle"); // style class for  <td>
        boolean showHiddenCols =
            "true".equals(varDetails.get("exporter.showHiddenColumns")); // define if hidden columns should be shown
        boolean forceColWidth = "true".equals(varDetails.get("exporter.forceColumnWidth")); // force width of columns

        // get the table from absoulte path
        UIViewRoot vr = facesContext.getViewRoot();
        UIPivotTable table = (UIPivotTable) ViewUtils.getUiComponent(expId);

        OutputStreamWriter expData = new OutputStreamWriter(os);
        PivotTableModel model = (PivotTableModel) table.getValue();
        DataAccess da = model.getDataAccess();

        try {
            int colHeaderCnt = da.getLayerCount(0);
            int rowDataCnt = da.getEdgeExtent(0);
            int rowHeaderCnt = da.getLayerCount(1);
            int colDataCnt = da.getEdgeExtent(1);

            // ----------------- HTML table ---- START ----------------
            expData.append("\n<table>");

            //  Table header --
            for (int rIdx = 0; rIdx < colHeaderCnt - 1; rIdx++) {
                expData.append("\n<tr>");
                expData.append(htmlHCell(null, thStyle, 1, rowHeaderCnt - 1));
                expData.append(htmlHCell(da.getLayerMetadata(0, rIdx, "layerName"), thStyle, 1, 1));
                int colspan = 0;
                for (int rdIdx = 0; rdIdx < rowDataCnt; rdIdx++) {
                    if (colspan == 0) {
                        colspan = da.getMemberExtent(0, rIdx, rdIdx);
                        expData.append(htmlHCell(da.getMemberMetadata(0, rIdx, rdIdx, "label"), thStyle, 1, colspan));
                    }
                    colspan--;
                }
                expData.append("</tr>");
            }
            // -- Last header row --
            expData.append("\n<tr>");
            for (int rhIdx = 0; rhIdx < rowHeaderCnt; rhIdx++) {
                expData.append(htmlHCell(da.getLayerMetadata(1, rhIdx, "layerName"), thStyle, 1, 1));
            }
            if (colHeaderCnt > 0) {
                for (int rdIdx = 0; rdIdx < rowDataCnt; rdIdx++) {
                    expData.append(htmlHCell(da.getMemberMetadata(0, colHeaderCnt - 1, rdIdx, "label"), thStyle, 1, 1));
                }
            }
            expData.append("</tr>");


            // Table rows
            int[] rowspan = new int[rowHeaderCnt];
            for (int rIdx = 0; rIdx < colDataCnt; rIdx++) {
                expData.append("\n<tr>");
                // --- row header ---
                for (int rhIdx = 0; rhIdx < rowHeaderCnt; rhIdx++) {
                    if (rowspan[rhIdx] == 0) {
                        rowspan[rhIdx] = da.getMemberExtent(1, rhIdx, rIdx);
                        expData.append(htmlCell(da.getMemberMetadata(1, rhIdx, rIdx, "label"), tdStyle,
                                                rowspan[rhIdx]));
                    }
                    rowspan[rhIdx]--;
                }

                // --- row data ---
                for (int cIdx = 0; cIdx < rowDataCnt; cIdx++) {
                    expData.append(htmlCell(da.getValue(rIdx, cIdx, "dataValue"), tdStyle, 1));
                }
                expData.append("</tr>");
            }
            expData.append("</table>");
            // ----------------- HTML table ----- END -----------------

        } catch (BIBaseException bbex) {
            expData.append("\nERROR: " + bbex);
        }

        expData.close();
    }


    public static boolean isUserInRole(String role) {
        return ADFContext.getCurrent().getSecurityContext().isUserInRole(role);
    }

    public void exportVOCostProfitToExcel(FacesContext facesContext, OutputStream outputStream) throws IOException {
        NumberFormat nf = NumberFormat.getNumberInstance(Locale.GERMAN);
        DecimalFormat df = (DecimalFormat) nf;
        df.setMaximumFractionDigits(8);

        DCBindingContainer dc = (DCBindingContainer) BindingContext.getCurrent().getCurrentBindingsEntry();
        DCIteratorBinding binding = dc.findIteratorBinding("CostProfitPivotExportViewIterator");
        ViewObject vo = binding.getViewObject();
        StringBuilder sb = new StringBuilder();
        sb.append("Project ID").append(NEXTCELL).append("Project Name").append(NEXTCELL).append("Study ID").append(NEXTCELL).append("Study Name").append(NEXTCELL).append("Function ID").append(NEXTCELL).append("Function Name").append(NEXTCELL).append("Year").append(NEXTCELL).append("Cost Type (ACT / RR / FCT / BGT / LE)").append(NEXTCELL).append("INT/EXT").append(NEXTCELL).append("DET/PROB").append(NEXTCELL).append("Cost Value").append(NEXTCELL).append(LINEBREAK);
        vo.setCurrentRow(vo.first());
        Row current = vo.getCurrentRow();
        while (current != null) {
            String projectId = (String) current.getAttribute("ProjectCode");
            String projectName = (String) current.getAttribute("ProjectName");
            String studyId = (String) current.getAttribute("StudyCode");
            String studyName = (String) current.getAttribute("StudyName");
            String functionId = (String) current.getAttribute("FunctionId");
            String functionName = (String) current.getAttribute("FunctionName");
            BigDecimal year = (BigDecimal) current.getAttribute("Year");
            String typeCode = (String) current.getAttribute("TypeCode");
            String scopeCode = (String) current.getAttribute("ScopeCode");
            String methodCode = (String) current.getAttribute("MethodCode");
            BigDecimal cost = (BigDecimal) current.getAttribute("Cost");
            sb.append(projectId).append(NEXTCELL).append(projectName).append(NEXTCELL).append(studyId).append(NEXTCELL).append(studyName).append(NEXTCELL).append(functionId).append(NEXTCELL).append(functionName).append(NEXTCELL).append(year).append(NEXTCELL).append(typeCode).append(NEXTCELL).append(scopeCode).append(NEXTCELL).append(methodCode).append(NEXTCELL).append(df.format(cost)).append(NEXTCELL).append(LINEBREAK);
            current = vo.next();
        }
        outputStream.write(sb.toString().getBytes());
        outputStream.flush();
    }

    public void exportVOCostFPSToExcel(FacesContext facesContext, OutputStream outputStream) throws IOException {
        NumberFormat nf = NumberFormat.getNumberInstance(Locale.GERMAN);
        DecimalFormat df = (DecimalFormat) nf;
        df.setMaximumFractionDigits(8);

        DCBindingContainer dc = (DCBindingContainer) BindingContext.getCurrent().getCurrentBindingsEntry();
        DCIteratorBinding binding = dc.findIteratorBinding("CostSophiaPivotExportViewIterator");
        ViewObject vo = binding.getViewObject();
        StringBuilder sb = new StringBuilder();
        sb.append("Project ID").append(NEXTCELL).append("Project Name").append(NEXTCELL).append("Study ID").append(NEXTCELL).append("Study Name").append(NEXTCELL).append("Function ID").append(NEXTCELL).append("Function Name").append(NEXTCELL).append("Activity ID").append(NEXTCELL).append("Activity Name").append(NEXTCELL).append("Year").append(NEXTCELL).append("Cost Type (ACT / RR / FCT)").append(NEXTCELL).append("INT/EXT").append(NEXTCELL).append("DET/PROB").append(NEXTCELL).append("Cost Value").append(NEXTCELL).append(LINEBREAK);
        vo.setCurrentRow(vo.first());
        Row current = vo.getCurrentRow();
        while (current != null) {
            String projectId = (String) current.getAttribute("ProjectCode");
            String projectName = (String) current.getAttribute("ProjectName");
            String studyId = (String) current.getAttribute("StudyCode");
            String studyName = (String) current.getAttribute("StudyName");
            String functionCode = (String) current.getAttribute("FunctionCode");
            String functionName = (String) current.getAttribute("FunctionName");
            String projectActivityId = (String) current.getAttribute("ProjectActivityIdExp");
            if (projectActivityId != null)
                projectActivityId = projectActivityId.replace("null", " ");
            String projectActivityName = (String) current.getAttribute("ProjectActivityId");
            if (projectActivityName != null)
                projectActivityName = projectActivityName.replace("null", " ");
            BigDecimal year = (BigDecimal) current.getAttribute("Year");
            String typeCode = (String) current.getAttribute("TypeCode");
            String scopeCode = (String) current.getAttribute("ScopeCode");
            String methodCode = (String) current.getAttribute("MethodCode");
            BigDecimal cost = (BigDecimal) current.getAttribute("Cost");
            sb.append(projectId).append(NEXTCELL).append(projectName).append(NEXTCELL).append(studyId).append(NEXTCELL).append(studyName).append(NEXTCELL).append(functionCode).append(NEXTCELL).append(functionName).append(NEXTCELL).append(projectActivityId).append(NEXTCELL).append(projectActivityName).append(NEXTCELL).append(year).append(NEXTCELL).append(typeCode).append(NEXTCELL).append(scopeCode).append(NEXTCELL).append(methodCode).append(NEXTCELL).append(df.format(cost)).append(NEXTCELL).append(LINEBREAK);
            current = vo.next();
        }
        outputStream.write(sb.toString().getBytes());
        outputStream.flush();
    }

    public static void makeCurrent(SelectionEvent selectionEvent) {

        RichTable _table = (RichTable) selectionEvent.getSource();
        //the Collection Model is the object that provides the
        //structured data
        //for the table to render
        CollectionModel _tableModel = (CollectionModel) _table.getValue();
        //the ADF object that implements the CollectionModel is
        //JUCtrlHierBinding. It is wrapped by the CollectionModel API
        JUCtrlHierBinding _adfTableBinding = (JUCtrlHierBinding) _tableModel.getWrappedData();
        //Acess the ADF iterator binding that is used with
        //ADF table binding
        DCIteratorBinding _tableIteratorBinding = _adfTableBinding.getDCIteratorBinding();


        //selection with the selection in the ADF model
        Object _selectedRowData = _table.getSelectedRowData();
        //cast to JUCtrlHierNodeBinding, which is the ADF object
        //that represents a row
        JUCtrlHierNodeBinding _nodeBinding = (JUCtrlHierNodeBinding) _selectedRowData;
        //get the row key from the node binding and set it
        //as the current row in the iterator
        Key _rwKey = _nodeBinding.getRowKey();
        _tableIteratorBinding.setCurrentRowWithKey(_rwKey.toStringFormat(true));
    }

}
