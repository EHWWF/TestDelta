<?xml version = '1.0' encoding = 'UTF-8'?>
<xsl:stylesheet version="1.0"
                xmlns:xp20="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.Xpath20"
                xmlns:bpws="http://schemas.xmlsoap.org/ws/2003/03/business-process/"
                xmlns:bpel="http://docs.oasis-open.org/wsbpel/2.0/process/executable"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:bpm="http://xmlns.oracle.com/bpmn20/extensions"
                xmlns:ns0="http://schemas.xmlsoap.org/ws/2003/05/partner-link/"
                xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
                xmlns:tns="http://xmlns.oracle.com/Primavera/P6/WS/Role/V1"
                xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:ora="http://schemas.oracle.com/xpath/extension"
                xmlns:socket="http://www.oracle.com/XSL/Transform/java/oracle.tip.adapter.socket.ProtocolTranslator"
                xmlns:ns1="http://xmlns.bayer.com/ipms" xmlns:ns11="http://xmlns.bayer.com/ipms/soa"
                xmlns:intgfault="http://xmlns.oracle.com/Primavera/P6/WS/IntegrationFaultType/V1"
                xmlns:mhdr="http://www.oracle.com/XSL/Transform/java/oracle.tip.mediator.service.common.functions.MediatorExtnFunction"
                xmlns:oraext="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.ExtFunc"
                xmlns:dvm="http://www.oracle.com/XSL/Transform/java/oracle.tip.dvm.LookupValue"
                xmlns:client="http://xmlns.bayer.com/ipms/soa" xmlns:hwf="http://xmlns.oracle.com/bpel/workflow/xpath"
                xmlns:plnk="http://docs.oasis-open.org/wsbpel/2.0/plnktype"
                xmlns:med="http://schemas.oracle.com/mediator/xpath" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ids="http://xmlns.oracle.com/bpel/services/IdentityService/xpath"
                xmlns:xdk="http://schemas.oracle.com/bpel/extension/xpath/function/xdk"
                xmlns:xref="http://www.oracle.com/XSL/Transform/java/oracle.tip.xref.xpath.XRefXPathFunctions"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:bpmn="http://schemas.oracle.com/bpm/xpath"
                xmlns:ldap="http://schemas.oracle.com/xpath/extension/ldap"
                exclude-result-prefixes="xsi xsl ns0 soap tns wsdl ns1 intgfault client plnk xsd xp20 bpws bpel bpm ora socket mhdr oraext dvm hwf med ids xdk xref bpmn ldap"
                xmlns:oracle-xsl-mapper="http://www.oracle.com/xsl/mapper/schemas"
                xmlns:ns2="http://xmlns.bayer.com/ipms/cache" xmlns:oraxsl="http://www.oracle.com/XSL/Transform/java"
                xmlns:ns3="http://xmlns.bayer.com/ipms/qplan">
  <oracle-xsl-mapper:schema>
    <!--SPECIFICATION OF MAP SOURCES AND TARGETS, DO NOT MODIFY.-->
    <oracle-xsl-mapper:mapSources>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="../UpdateFunctions.wsdl"/>
        <oracle-xsl-mapper:rootElement name="update" namespace="http://xmlns.bayer.com/ipms/soa"/>
      </oracle-xsl-mapper:source>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="../ReadConfiguration.wsdl"/>
        <oracle-xsl-mapper:rootElement name="config" namespace="http://xmlns.bayer.com/ipms/soa"/>
        <oracle-xsl-mapper:param name="ReadCfgOut.payload"/>
      </oracle-xsl-mapper:source>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="oramds:/apps/com/oracle/xmlns/Primavera/P6/WS/Role/V1/RoleService.wsdl"/>
        <oracle-xsl-mapper:rootElement name="ReadRolesResponse"
                                       namespace="http://xmlns.oracle.com/Primavera/P6/WS/Role/V1"/>
        <oracle-xsl-mapper:param name="ReadRolesOut.result"/>
      </oracle-xsl-mapper:source>
    </oracle-xsl-mapper:mapSources>
    <oracle-xsl-mapper:mapTargets>
      <oracle-xsl-mapper:target type="WSDL">
        <oracle-xsl-mapper:schema location="oramds:/apps/com/oracle/xmlns/Primavera/P6/WS/Role/V1/RoleService.wsdl"/>
        <oracle-xsl-mapper:rootElement name="UpdateRoles" namespace="http://xmlns.oracle.com/Primavera/P6/WS/Role/V1"/>
      </oracle-xsl-mapper:target>
    </oracle-xsl-mapper:mapTargets>
    <oracle-xsl-mapper:mapShowPrefixes type="true"/>
    <!--GENERATED BY ORACLE XSL MAPPER 12.1.3.0.0(XSLT Build 140529.0700.0211) AT [MON JUN 01 10:43:33 CEST 2015].-->
  </oracle-xsl-mapper:schema>
  <!--User Editing allowed BELOW this line - DO NOT DELETE THIS LINE-->
  <xsl:param name="ReadCfgOut.payload"/>
  <xsl:param name="ReadRolesOut.result"/>
  <xsl:template match="/">
    <tns:UpdateRoles>
      <xsl:for-each select="$ReadRolesOut.result/tns:ReadRolesResponse/tns:Role">
        <xsl:variable name="P6RoleId" select="tns:Id"/>
        <xsl:variable name="IPMSRoleName"
                      select="/client:update/ns1:functions/ns1:function[ns1:code=$P6RoleId]/ns1:name"/>
        <xsl:if test='$IPMSRoleName != ""'>
          <tns:Role>
            <tns:Name>
              <xsl:value-of select="$IPMSRoleName"/>
            </tns:Name>
            <tns:ObjectId>
              <xsl:value-of select="tns:ObjectId"/>
            </tns:ObjectId>
            <xsl:choose>
              <xsl:when test='/client:update/ns1:functions/ns1:function[ns1:code=$P6RoleId]/@disabled = "false"'>
                <tns:ParentObjectId>
                  <xsl:value-of select="$ReadCfgOut.payload/ns11:config/ns11:role/ns11:groups/ns11:activeId"/>
                </tns:ParentObjectId>
              </xsl:when>
              <xsl:otherwise>
                <tns:ParentObjectId>
                  <xsl:value-of select="$ReadCfgOut.payload/ns11:config/ns11:role/ns11:groups/ns11:inactiveId"/>
                </tns:ParentObjectId>
              </xsl:otherwise>
            </xsl:choose>
          </tns:Role>
        </xsl:if>
      </xsl:for-each>
    </tns:UpdateRoles>
  </xsl:template>
</xsl:stylesheet>