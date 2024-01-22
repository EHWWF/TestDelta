package com.bayer.ipms.model.base;


import com.redsam.audit.RedsamAuditVOImpl;

import java.util.ArrayList;
import java.util.Map;

import oracle.adf.share.logging.ADFLogger;

import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.Variable;
import oracle.jbo.ViewCriteria;
import oracle.jbo.ViewCriteriaItem;
import oracle.jbo.ViewCriteriaItemValue;
import oracle.jbo.ViewCriteriaManager;
import oracle.jbo.server.TransactionEvent;
import oracle.jbo.server.ViewRowImpl;


public class IPMSViewObjectImpl extends RedsamAuditVOImpl {
    private Key currentRowKey;
    private int currentRowIndex;
    protected final ADFLogger logger = ADFLogger.createADFLogger(getClass());
    private static final String CUSTOM_OPERATORS = "IN,";

    //    public IPMSViewObjectImpl(String string, ViewDefImpl viewDefImpl) {
    //        super(string, viewDefImpl);
    //    }

    public IPMSViewObjectImpl() {
        super();
    }

    @Override
    public void beforeRollback(TransactionEvent TransactionEvent) {
        if (this.isExecuted()) {
            ViewRowImpl currentRow = (ViewRowImpl) this.getCurrentRow();
            if (currentRow != null) {
                byte newRowState = currentRow.getNewRowState();
                if (newRowState != Row.STATUS_INITIALIZED && newRowState != Row.STATUS_NEW) {
                    currentRowKey = currentRow.getKey();
                    currentRowIndex = this.getRangeIndexOf(currentRow);
                    ;
                }
            }
        }

        super.beforeRollback(TransactionEvent);
    }

    @Override
    public void afterRollback(TransactionEvent TransactionEvent) {
        super.afterRollback(TransactionEvent);

        if (currentRowKey != null) {
            this.executeQuery();
            Key key = new Key(currentRowKey.getAttributeValues());
            Row[] found = this.findByKey(key, 1);
            if (found != null && found.length == 1) {
                Row row = this.getRow(key);
                // IPMSSUP-261: Newsflow Fehlermeldung. Surrounding the code by try/catch as a fix.
                // NullPointerException is thrown ONLY for CostsSophiaView. Reproducable ONLY on BHC environments (data?)
                try {
                    this.setCurrentRow(row);
                    if (currentRowIndex >= 0) {
                        this.scrollRangeTo(row, currentRowIndex);
                    }
                } catch (NullPointerException e) {
                    this.logger.warning(String.format("Could not set the current row back after rollback for %s: %s",
                                                      this.getDefFullName(), e.getMessage()));
                }
            }
        }
        currentRowKey = null;
    }

    @Override
    protected void executeQueryForCollection(Object qc, Object[] params, int noUserParams) {

        super.executeQueryForCollection(qc, params, noUserParams);
        // U.o("EXECUTING VO: " + this.getName());
    }

    protected void runStatement(String stt, boolean commit, String... args) {
        ((IPMSApplicationModule) getApplicationModule()).runStatement(stt, commit, args);
    }

    protected void runStatement(String stt, boolean commit, ArrayList<Map<String, Object>> pars) {
        ((IPMSApplicationModule) getApplicationModule()).runStatement(stt, commit, pars);
    }

    public void applyCriteria(String criteria) {
        ViewCriteriaManager mgr = getViewCriteriaManager();
        ViewCriteria crit = mgr.getViewCriteria(criteria);

        applyViewCriteria(crit);
        executeQuery();
    }

    public void removeCriteria(String criteria) {
        removeApplyViewCriteriaName(criteria);
        executeQuery();
    }

    /*public boolean isVOShared() {
        return getApplicationModule().getName().equals("SharedAppModule");
    }

    @Override
    public boolean isAutoRefreshEnabled() {
        return super.isAutoRefreshEnabled() && isVOShared();
    }*/


    /**
     * Check if a given criteria item tries to use an 'IN' operator using a bind parameter (comma seperated list of strings).
     * Create special SQL clause for 'IN' operator
     * @param aVCI Criteria item
     * @return where clause part for the criteria item
     */
    @Override
    public String getCriteriaItemClause(ViewCriteriaItem aVCI) {
        // we only handle the SQL 'IN' operator
        String sqloperator = aVCI.getOperator();
        // add comma to operator as delimiter
        boolean customOp = CUSTOM_OPERATORS.indexOf(sqloperator.concat(",")) >= 0;
        customOp |= sqloperator.indexOf("NVL") >= 0;
        if (customOp) {
            ArrayList<ViewCriteriaItemValue> lArrayList = aVCI.getValues();
            if (lArrayList != null && !lArrayList.isEmpty()) {
                // check if the criteria item has bind parameters (only the first if of interest here as the IN clause onlyallows one parameter)
                ViewCriteriaItemValue itemValue = (ViewCriteriaItemValue) lArrayList.get(0);
                if (itemValue.getIsBindVar()) {
                    // get variable and check if null values should be ignored for bind parameters
                    Variable lBindVariable = itemValue.getBindVariable();
                    Object obj = ensureVariableManager().getVariableValue(lBindVariable.getName());
                    boolean b = aVCI.isGenerateIsNullClauseForBindVariables();
                    if (b && obj == null) {
                        // if null values for bind variables should be ignored, use the default getCriteriaItemClause
                        return super.getCriteriaItemClause(aVCI);
                    }

                    try {
                        // we only handle strings data types for bind variables
                        String val = (String) obj;
                    } catch (Exception e) {
                        // the bind variabel has the wrong type! Only Strings are allowed

                        String s = ":" + lBindVariable.getName() + " = :" + lBindVariable.getName();
                        return s;
                    }

                    // only handle queries send to the db
                    if (aVCI.getViewCriteria().getRootViewCriteria().isCriteriaForQuery()) {
                        String sql_clause = null;
                        switch (sqloperator) {
                        case "IN":
                            sql_clause = createINClause(aVCI, lBindVariable);
                            break;
                        default:

                            break;
                        }

                        return sql_clause;
                    } else {
                        // bind variable not set or
                        // for in memory we don't need to anything so just return '1=1'
                        return "1=1";
                    }
                }
            }
        }

        return super.getCriteriaItemClause(aVCI);
    }

    private String createINClause(ViewCriteriaItem aVCI, Variable lBindVariable) {
        // start build the sql 'IN' where clause (COLUMN is the name of the column, bindParam the name of the bind variable):
        // COLUMN IN (SELECT regexp_substr(:bindParam,'[^,]+',1,level) FROM dual CONNECT BY regexp_substr(:bindParam,'[^,]+',1,level) IS NOT NULL
        // get flagg to create an sql where clause which ignores the case of the bind parameter
        boolean upper = aVCI.isUpperColumns();
        String sql_in_clause = null;
        StringBuilder sql = new StringBuilder();
        if (upper) {
            sql.append("UPPER(");
        }
        sql.append(aVCI.getColumnNameForQuery());
        if (upper) {
            sql.append(")");
        }
        sql.append(" ").append(aVCI.getOperator());
        sql.append(" (select regexp_substr(");
        if (upper) {
            sql.append("UPPER(");
        }
        sql.append(":");
        sql.append(lBindVariable.getName());
        if (upper) {
            sql.append(")");
        }
        sql.append(",'[^,]+', 1, level) from dual connect by regexp_substr(");
        if (upper) {
            sql.append("UPPER(");
        }
        sql.append(":").append(lBindVariable.getName());
        if (upper) {
            sql.append(")");
        }
        sql.append(", '[^,]+', 1, level) is not null)");
        sql_in_clause = sql.toString();


        return sql_in_clause;
    }
}
