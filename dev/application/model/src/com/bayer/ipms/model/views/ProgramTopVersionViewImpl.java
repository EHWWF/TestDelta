
package com.bayer.ipms.model.views;

import com.bayer.ipms.model.base.IPMSViewObjectImpl;

import java.sql.Date;

import java.sql.PreparedStatement;

import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.jbo.AttributeList;
import oracle.jbo.JboException;
import oracle.jbo.Row;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue Sep 29 13:47:49 BST 2020
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ProgramTopVersionViewImpl extends IPMSViewObjectImpl {
    /**
     * This is the default constructor (do not remove).
     */
    public ProgramTopVersionViewImpl() {
        //showSql = true;
    }
    
   
    public void setProjectIdBindVar(String value) {
        setNamedWhereClauseParam("projectIdBindVar", value);
    }

   
    public String getProjectIdBindVar() {
        return (String) getNamedWhereClauseParam("projectIdBindVar");
    }
    
    
    public String retrieveExportURL(String projectId,  String programId, String version) {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String url = null;
        
        pstmt = this.getDBTransaction().createPreparedStatement("select program_top_pkg.get_pdf_export(?,?,?) as result from dual", 1);
        try {
            pstmt.setString(1, projectId);
            pstmt.setString(2, programId);
            pstmt.setString(3, version);
            
            rs = pstmt.executeQuery();
            while (rs.next()) {
                url = rs.getString(1);
            }
        } catch (SQLException sqle) {
            throw new JboException (sqle);
        }
        finally {
            try {
                if (rs != null)
                    rs.close();
                if (pstmt != null)
                    pstmt.close();
            } catch (SQLException sqle) {
                //do nothing, ignore
            }
        }
        
        return url;
        
        
    }

   


}

