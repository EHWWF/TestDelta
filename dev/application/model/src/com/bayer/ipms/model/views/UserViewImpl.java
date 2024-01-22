package com.bayer.ipms.model.views;


import com.bayer.ipms.model.base.IPMSViewObjectImpl;
import com.bayer.ipms.model.utils.ModelUtils;

import com.bayer.ipms.model.views.common.UserView;

import java.security.Principal;

import java.sql.ResultSet;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;

import oracle.adf.share.logging.ADFLogger;

import oracle.jbo.server.ViewRowImpl;
import oracle.jbo.server.ViewRowSetImpl;

import oracle.security.idm.ComplexSearchFilter;
import oracle.security.idm.IMException;
import oracle.security.idm.Identity;
import oracle.security.idm.IdentityStore;
import oracle.security.idm.ObjectNotFoundException;
import oracle.security.idm.Role;
import oracle.security.idm.RoleProfile;
import oracle.security.idm.SearchParameters;
import oracle.security.idm.SearchResponse;
import oracle.security.idm.SimpleSearchFilter;
import oracle.security.idm.User;
import oracle.security.idm.UserProfile;
import oracle.security.jps.JpsException;
import oracle.security.jps.principals.JpsApplicationRole;
import oracle.security.jps.service.policystore.ApplicationPolicy;
import oracle.security.jps.service.policystore.info.AppRoleEntry;



import weblogic.security.spi.WLSGroup;
import weblogic.security.spi.WLSUser;


// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Mar 08 16:33:59 CET 2013
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class UserViewImpl extends IPMSViewObjectImpl implements UserView {
    protected static ADFLogger logger = ADFLogger.createADFLogger(UserViewImpl.class);
    protected List<Usr> list = null;
    protected List<String> roleList = new ArrayList() {
        {
            add("ProgramViewAssignedDev");
            add("ProgramViewAssignedPrdMnt");
            add("ProjectViewAssignedD3Tr");
        }
    };
    private String roleName;

    /**
     * This is the default constructor (do not remove).
     */
    public UserViewImpl() {
        
    }


    protected List<Usr> load() {
        HashMap<String, Usr> users = new HashMap<String,Usr>();

        try {
            ApplicationPolicy appPolicy = ModelUtils.getApplicationPolicy();
            IdentityStore idStore = ModelUtils.getIdentityStore();

            for (String rn : roleList) {
                roleName = rn;
                collect(appPolicy, idStore, roleName, users);
            }

            idStore.close();
        } catch (Exception exc) {
            logger.severe(exc.getMessage());
        }
        
        
        return new ArrayList<Usr>(users.values());
    }

    private void collect(ApplicationPolicy appPolicy, IdentityStore idStore, String role, HashMap<String, Usr> users) throws JpsException, IMException {

        User identUser;


        for (Principal pr : appPolicy.getAppRolesMembers(role)) {
            if (pr instanceof JpsApplicationRole) {
                collect(appPolicy, idStore, pr.getName(), users);
            } else if (pr instanceof WLSUser) {
            	try {
	                identUser = idStore.searchUser(IdentityStore.SEARCH_BY_NAME, pr.getName());
	                users.put(identUser.getPrincipal().getName().toLowerCase(), new Usr(identUser.getPrincipal().getName(), identUser.getDisplayName(), roleName));
            	} catch (ObjectNotFoundException exc) {
                    logger.severe(exc.getMessage());
                }
            } else if (pr instanceof WLSGroup) {
                try {
	            	Role rol = idStore.searchRole(IdentityStore.SEARCH_BY_NAME, pr.getName());
	                SearchResponse sr = rol.getRoleProfile().getGrantees(null, false);
	                while (sr.hasNext()) {
	                    Identity id = (Identity)sr.next();
	                    if (id instanceof User) {
	                        users.put(id.getPrincipal().getName() ,new Usr(id.getPrincipal().getName(), id.getDisplayName(), roleName));
	                    }
	                }
	                sr.close();
                } catch (ObjectNotFoundException exc) {
                    logger.severe(exc.getMessage());
                }
            }
        }
    }


    /**
     * executeQueryForCollection - overridden for custom java data source support.
     */
    protected void executeQueryForCollection(Object qc, Object[] params, int noUserParams) {
        this.list = load();

        setFetchPos(qc, 0);

        super.executeQueryForCollection(qc, params, noUserParams);
    }
    
    public List getUserList() {
        if(this.list == null)
            this.list = load();
        return this.list;
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
     * hasNextForCollection - overridden for custom java data source support.
     */
    protected boolean hasNextForCollection(Object qc) {
        return (getFetchPos(qc) < this.list.size());
    }

    /**
     * createRowFromResultSet - overridden for custom java data source support.
     */
    protected ViewRowImpl createRowFromResultSet(Object qc, ResultSet resultSet) {
        UserViewRowImpl r = (UserViewRowImpl)createNewRowForCollection(qc);
        int pos = getFetchPos(qc);

        Usr user = this.list.get(pos);
        populateAttributeForRow(r, 0, user.getName());
        String username = user.getName();
        if (user.getDisplayName() != null) {
            username = user.getDisplayName() + " (" + username + ")";
        }
        populateAttributeForRow(r, 1, username);
        populateAttributeForRow(r, 2, user.getRoleName());

        setFetchPos(qc, pos + 1);
        return r;
    }

    /**
     * getQueryHitCount - overridden for custom java data source support.
     */
    public long getQueryHitCount(ViewRowSetImpl viewRowSet) {
        return (this.list == null ? -1 : this.list.size());
    }


    public void send() {
        runStatement("begin message_pkg.send_users(); end;", true);
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

    public static class Usr {

        private String name;
        private String displayName;
        private String roleName;

        public Usr(String name, String displayName, String roleName) {
            this.name = name;
            this.displayName = displayName;
            this.roleName = roleName;
        }

        public String getName() {
            return name;
        }

        public String getDisplayName() {
            return displayName;
        }

        public String getRoleName() {
            return roleName;
        }
        
        public String toString() {
            return "Usr [name=" + this.name +  ", displayName=" + this.getDisplayName() + ", roleName=" + roleName + "]";
        }
        
        

    }

    protected static class UserComparator implements Comparator<Usr> {
        @Override
        public int compare(Usr x, Usr y) {

            int comPr = x.getName().toLowerCase().compareTo(y.getName().toLowerCase());
            return comPr == 0 ? x.getRoleName().toLowerCase().compareTo(y.getRoleName().toLowerCase()) : comPr;
        }
    }
    
   //Added for IPMS-1018
    
    protected static class RoleIdentityComparator implements Comparator<Identity> {
      @Override
      public int compare(Identity x, Identity y) {
          try {             
            return x.getDisplayName().toLowerCase().compareTo(y.getDisplayName().toLowerCase());
          } catch (IMException exc) {
              return 0;
          }
      }
    }


}
