package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSViewObjectImpl;

import com.bayer.ipms.model.utils.IPMSArrayList;
import com.bayer.ipms.model.utils.ModelUtils;
import com.bayer.ipms.model.views.common.RoleView;

import java.sql.ResultSet;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import java.util.SortedSet;

import java.util.TreeSet;

import java.security.Principal;

import oracle.jbo.server.ViewRowImpl;
import oracle.jbo.server.ViewRowSetImpl;


import oracle.security.jps.service.policystore.ApplicationPolicy;

import oracle.security.jps.service.policystore.info.AppRoleEntry;


// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Sep 05 16:43:55 EEST 2014
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class RoleViewImpl extends IPMSViewObjectImpl implements RoleView {

    protected List<Role> list = null;
    protected Map<String, Set<String>> grants = null;

    private static final String newRole_GPM_GPH = "edit";
    private static final String newRole_GPT = "read only";
    private static final String oldRole_GPM_GPH = "GPM_GPH";
    private static final String oldRole_GPT = "GPT";

    /**
     * This is the default constructor (do not remove).
     */
    public RoleViewImpl() {
    }

    protected List<Role> load() {
        SortedSet<Role> roles = new TreeSet<Role>(new RoleComparator());
        this.grants = new HashMap<String, Set<String>>();

        try {
            ApplicationPolicy appPolicy = ModelUtils.getApplicationPolicy();

            // load granted app roles
            for (AppRoleEntry role : appPolicy.searchAppRoles("*Assigned*")) {
                Set<String> groups = new HashSet<String>();

                for (Principal pr : appPolicy.getAppRolesMembers(role.getName())) {
                    roles.add(new Role(pr.getName(), role.getName()));
                    groups.add(pr.getName());
                }
                this.grants.put(role.getName(), groups);
            }
        } catch (Exception exc) {
            logger.severe(exc.getMessage());
        }
        return new ArrayList<Role>(roles);
    }

    /**
     * Store the current fetch position in the user data context
     */
    protected void setFetchPos(Object rowset, int pos) {
        if (pos == this.list.size()) {
            setFetchCompleteForCollection(rowset, true);
        }
        setUserDataForCollection(rowset, new Integer(pos));
    }

    /**
     * Get the current fetch position from the user data context
     */
    protected int getFetchPos(Object rowset) {
        return ((Integer)getUserDataForCollection(rowset)).intValue();
    }


    /**
     * executeQueryForCollection - overridden for custom java data source support.
     */
    protected void executeQueryForCollection(Object qc, Object[] params, int noUserParams) {

        if (this.list == null) {
            this.list = load();
        }

        setFetchPos(qc, 0);

        super.executeQueryForCollection(qc, params, noUserParams);
    }

    /**
     * hasNextForCollection - overridden for custom java data source support.
     */
    protected boolean hasNextForCollection(Object qc) {
        return (getFetchPos(qc) < this.list.size());
    }

    /**
     * createRowFromResultSet - overridden for custom java data source support.
     */
    protected ViewRowImpl createRowFromResultSet(Object qc, ResultSet resultSet) {

        RoleViewRowImpl r = (RoleViewRowImpl)createNewRowForCollection(qc);
        int pos = getFetchPos(qc);

        Role row = this.list.get(pos);

        if (row.getPrincipalName().equals(oldRole_GPM_GPH)) {
                populateAttributeForRow(r, 0, row.getPrincipalName());
                populateAttributeForRow(r, 1, newRole_GPM_GPH);
                populateAttributeForRow(r, 2, row.getRoleName());
            }
        else if(row.getPrincipalName().equals(oldRole_GPT)){
                populateAttributeForRow(r, 0, row.getPrincipalName());
                populateAttributeForRow(r, 1, newRole_GPT);
                populateAttributeForRow(r, 2, row.getRoleName());
            }
        setFetchPos(qc, pos + 1);
        return r;

    }

    /**
     * getQueryHitCount - overridden for custom java data source support.
     */
    public long getQueryHitCount(ViewRowSetImpl viewRowSet) {
        long value = super.getQueryHitCount(viewRowSet);
        return value;
    }

    public Set<String> getRoles(String right) {
        if (this.grants == null) {
            load();
        }

        if (this.grants.containsKey(right)) {
            return this.grants.get(right);
        } else {
            return Collections.emptySet();
        }
    }

    /**
     * Returns the variable value for RoleNameVar.
     * @return variable value for RoleNameVar
     */
    public String getRoleNameVar() {
        return (String)ensureVariableManager().getVariableValue("RoleNameVar");
    }

    /**
     * Sets <code>value</code> for variable RoleNameVar.
     * @param value value to bind as RoleNameVar
     */
    public void setRoleNameVar(String value) {
        ensureVariableManager().setVariableValue("RoleNameVar", value);
    }


    public static class Role {

        private String principalName;
        private String roleName;

        public Role(String principalName, String roleName) {
            this.principalName = principalName;
            this.roleName = roleName;
        }

        public String getPrincipalName() {
            return principalName;
        }

        public String getRoleName() {
            return roleName;
        }

    }

    protected static class RoleComparator implements Comparator<Role> {
        @Override
        public int compare(Role x, Role y) {

            int comPr = x.getPrincipalName().toLowerCase().compareTo(y.getPrincipalName().toLowerCase());
            return comPr == 0 ? x.getRoleName().toLowerCase().compareTo(y.getRoleName().toLowerCase()) : comPr;
        }
    }


}