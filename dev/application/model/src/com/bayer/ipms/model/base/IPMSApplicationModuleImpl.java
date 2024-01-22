package com.bayer.ipms.model.base;

import com.redsam.audit.RedsamAuditAMImpl;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;

import java.util.ArrayList;
import java.util.Map;

import oracle.adf.share.ADFContext;
import oracle.adf.share.logging.ADFLogger;

import oracle.jbo.JboException;
import oracle.jbo.Session;
import oracle.jbo.server.TransactionEvent;


public class IPMSApplicationModuleImpl extends RedsamAuditAMImpl implements IPMSApplicationModule {
    protected final ADFLogger logger = ADFLogger.createADFLogger(getClass());

    public IPMSApplicationModuleImpl() {
        super();
    }

 

    @Override
    protected void prepareSession(Session session) {
        super.prepareSession(session);

        this.getDBTransaction().setClearCacheOnRollback(false);
    }

    @Override
    @SuppressWarnings("unchecked")
    public void beforeCommit(TransactionEvent p1) {

        Map session = ADFContext.getCurrent().getSessionScope();

        if (session.get("programId") == null) {
            session.put("programId", "");
        }
        if (session.get("projectId") == null) {
            session.put("projectId", "");
        }

        if (session.get("baCode") != null && !session.get("baCode").equals("")) {
            runStatement("begin ba_log_pkg.put_guid(?,?,?,?,?); end;", false, session.get("uuid").toString(),
                         ADFContext.getCurrent().getSecurityContext().getUserName(), session.get("baCode").toString(),
                         session.get("projectId").toString(), session.get("programId").toString());
        }

        super.beforeCommit(p1);
    }

    public void runStatement(String stt, boolean commit, String... args) {
        PreparedStatement st = null;
        try {
            st = getDBTransaction().createPreparedStatement(stt, 0);
            for (int i = 0; i < args.length; i++) {
                st.setString(i + 1, args[i]);
            }
            st.executeUpdate();

            if (commit) {
                getDBTransaction().commit();
            }
        } catch (SQLException e) {
            throw new JboException(e);
        } finally {
            try {
                st.close();
            } catch (Exception exc) {
                // nothing to do
            }
        }
    }

    public void runStatement(String stt, boolean commit, ArrayList<Map<String, Object>> pars) {
        
        CallableStatement st = this.getDBTransaction().createCallableStatement((stt), 0);

        try {

            for (int i = 0; i < pars.size(); i++) {
                if (pars.get(i).get("type").equals("in")) {
                    if (pars.get(i).get("datatype").equals("String")) {
                        st.setString(i + 1, (String)pars.get(i).get("value"));
                    }
                } else {
                    if (pars.get(i).get("datatype").equals("String")) {
                        st.registerOutParameter(i + 1, Types.VARCHAR);
                    }
                }
            }
            
            st.execute();
            
            for (int i = 0; i < pars.size(); i++) {
                if (pars.get(i).get("type").equals("out")) {
                    if (pars.get(i).get("datatype").equals("String")) {
                        pars.get(i).put("value", st.getString(i+1));
                    }
                }
            }

            if (commit) {
                getDBTransaction().commit();
            }

        } catch (SQLException e) {
            throw new JboException(e);
        } finally {
            try {
                st.close();
            } catch (Exception exc) {
                // nothing to do
            }
        }

    }
    
    public Object callStoredFunction(int sqlReturnType, String stmt, Object[] bindVars) {
            CallableStatement cst = null;
            try {

                cst = this.getDBTransaction().createCallableStatement("begin ? := " + stmt + ";end;", 0);
                cst.registerOutParameter(1, sqlReturnType);

                if (bindVars != null) {
                    for (int z = 0; z < bindVars.length; z++) {
                        cst.setObject(z + 2, bindVars[z]);
                    }
                }
                cst.executeUpdate();

                return cst.getObject(1);
            } catch (SQLException e) {
                throw new JboException(e.getMessage());
            } finally {
                if (cst != null) {
                    try {
                        cst.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
    }
}
